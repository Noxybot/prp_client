#ifndef CONTACTIMAGEPROVIDER_H
#define CONTACTIMAGEPROVIDER_H

#include <QQuickImageProvider>

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonObject>
#include <QJsonDocument>
#include <QNetworkAccessManager>
#include <QByteArray>
#include <mutex>
#include <thread>
#include "sqlcontactmodel.h"
#include <QQuickImageResponse>
#include <QBuffer>


class ContactImageProvider : public QObject, public QQuickImageProvider
        //,public std::enable_shared_from_this<ContactImageProvider>
{
    Q_OBJECT
public:
    ~ContactImageProvider() {qDebug() << "ContactImageProvider DELETED";}


    ContactImageProvider(QString server_ip, std::shared_ptr<SqlContactModel> sql_contact_model)
        : QQuickImageProvider(QQuickImageProvider::Pixmap)
        , m_web_ctrl(new QNetworkAccessManager(this))
        , m_server_ip(std::move(server_ip))
        , m_sql_contact_model(std::move(sql_contact_model))
    {}

    Q_INVOKABLE void setCurrentUserLogin(QString login)
    {
        if (login.length() == 0)
        {
            qDebug() << "ContactImageProvider: clearing cached images";
            std::lock_guard<std::mutex> lock{m_replies_mtx};
            m_replies.clear();
            std::lock_guard<std::mutex> lock_{m_img_mtx};
            m_contact_images.clear();
            return;
        }
        m_current_user_login = std::move(login);
    }

    QPixmap requestPixmap(const QString &login, QSize *size, const QSize &requestedSize) override
    {
        Q_UNUSED(size);
        qDebug() << "requestPixmap for user login: " << login << " size: " << m_contact_images.size() <<  "req size: " << requestedSize;
        std::unique_lock<std::mutex> lock{m_img_mtx};
        auto img_it = m_contact_images.find(login);
        if (img_it != std::end(m_contact_images))
            //*size = requestedSize;
            return img_it.value().scaled(requestedSize);
        lock.unlock();
        const auto img = m_sql_contact_model->getUserImageByLogin(login);
        if (img.size() != 0)
        {
            qDebug() << "requestPixmap for user login: " << login << ", forund in DB";
            QPixmap image;
            image.loadFromData(QByteArray::fromBase64(img.toUtf8()));
            std::lock_guard<std::mutex> lock{m_img_mtx};
            auto res = m_contact_images.insert(login, std::move(image));
            return res->scaled(requestedSize);
        }
        std::lock_guard<std::mutex> lock_{m_replies_mtx};
        for (const auto& elem : m_replies)
        {
            if (elem == login) //already in progress
                return {};
        }

        QUrl server_url = QUrl("http://" + m_server_ip);

        QNetworkRequest request(server_url);

        QJsonObject json;
        json.insert("method", "get_user_image");
        json.insert("login", login); //marker id
        QJsonDocument jsonDoc(json);
        QByteArray jsonData= jsonDoc.toJson();
        request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
        QNetworkReply *reply = m_web_ctrl->post(request, jsonData);
        m_replies.insert(reply, login);
        QObject::connect(reply, &QNetworkReply::finished, this, &ContactImageProvider::userImageFinished);
       // QObject::connect(reply, &QNetworkReply::readyRead, this, &MarkerImageProvider::markerImageDownloaded);
       // QObject::connect(reply, &QNetworkReply::errorOccurred, this, &ContactImageProvider::error);
       return {};
    }

public slots:
    void error(QNetworkReply::NetworkError code)
    {
        qDebug() << "error, QNetworkReply: " << code;

    }
    void markerImageDownloaded()
    {


    }
    void userImageFinished()
    {
        QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
        switch(reply->error())
        {
        case QNetworkReply::NoError:
        {
            qDebug() << "userImageFinished(): NoError";
            QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
            const auto login = m_replies[reply];
            QJsonDocument jsonResponse = QJsonDocument::fromJson(reply->readAll());
            qDebug() << "receive image for user: " << login ;//<< //", img: " << jsonResponse["result"].toString().toUtf8();
            QPixmap image;
            QString image_str = jsonResponse["result"].toString();
            qDebug()<<"image_str: "<<image_str;
            if(image_str == "no image")
            {
                image.load(":/images/profile.png");
                qDebug()<<"image is null: "<<image.isNull();
                QByteArray byteArray;
                QBuffer buffer(&byteArray);
                image.save(&buffer, "PNG"); // writes the image in JPEG format inside the buffer
                image_str = QString::fromLatin1(byteArray.toBase64().data());
            }
            else{
                image.loadFromData(QByteArray::fromBase64(image_str.toUtf8()));
            }

            {
                std::lock_guard<std::mutex> lock{m_replies_mtx};
                m_replies.remove(reply);
            }

            std::lock_guard<std::mutex> lock{m_img_mtx};
            m_contact_images.insert(login, std::move(image));
            m_sql_contact_model->addUserImage(login, std::move(image_str));
        }
            break;

        default:
            qDebug() << "markerImageFinished(): Error " << reply->errorString();
            break;
        }
    }
private:
    std::mutex m_replies_mtx;
    QMap<QNetworkReply*, QString> m_replies; //reply -> login
    QNetworkAccessManager* m_web_ctrl;
    std::mutex m_img_mtx;
    QMap<QString, QPixmap> m_contact_images;
    QString m_server_ip;
    std::shared_ptr<SqlContactModel> m_sql_contact_model;
    QString m_current_user_login;
};

#endif // CONTACTIMAGEPROVIDER_H
