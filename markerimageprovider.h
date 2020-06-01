#ifndef MARKERIMAGEPROVIDER_H
#define MARKERIMAGEPROVIDER_H
#include <QQuickImageProvider>

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonObject>
#include <QJsonDocument>
#include <QNetworkAccessManager>
#include <QByteArray>
#include <mutex>
class MarkerImageProvider : public QObject, public QQuickImageProvider
{
    Q_OBJECT
public:
    ~MarkerImageProvider() {qDebug() << "MarkerImageProvider DELETED";}

    MarkerImageProvider(QString server_ip)
        : QQuickImageProvider(QQuickImageProvider::Pixmap)
        , m_web_ctrl(new QNetworkAccessManager(this))
        , m_server_ip(std::move(server_ip)) {}
    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize) override
    {
        Q_UNUSED(size);
        qDebug() << "requestPixmap for marker id: " << id << " size: " << requestedSize;
        auto img_it = m_marker_images.find(id.toInt());
        if (img_it != std::end(m_marker_images))
            return img_it.value().scaled(requestedSize, Qt::KeepAspectRatio);

        {
            std::lock_guard<std::mutex> lock_{m_replies_mtx};
            for (const auto& elem : m_replies)
            {
                if (elem == id) //already in progress
                    return {};
            }
        }
       //int width = 100;
      // int height = 50;
       QUrl server_url = QUrl("http://" + m_server_ip);

       QNetworkRequest request(server_url);

       QJsonObject json;
       json.insert("method", "get_marker_image");
       json.insert("id", id); //marker id
       QJsonDocument jsonDoc(json);
       QByteArray jsonData= jsonDoc.toJson();
       request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
       QNetworkReply *reply = m_web_ctrl->post(request, jsonData);
       {
            std::lock_guard<std::mutex> lock{m_replies_mtx};
            m_replies.insert(reply, id.toInt());
       }
       QObject::connect(reply, &QNetworkReply::finished, this, &MarkerImageProvider::markerImageFinished);
      // QObject::connect(reply, &QNetworkReply::readyRead, this, &MarkerImageProvider::markerImageDownloaded);
       //QObject::connect(reply, &QNetworkReply::errorOccurred, this, &MarkerImageProvider::error);


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
    void markerImageFinished()
    {
        QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
        switch(reply->error())
        {
        case QNetworkReply::NoError:
        {
            qDebug() << "markerImageFinished(): NoError";
            QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
            const int id = m_replies[reply];
            QJsonDocument jsonResponse = QJsonDocument::fromJson(reply->readAll());
            qDebug() << "receive image for marker: " << id ;//<< //", img: " << jsonResponse["result"].toString().toUtf8();
            QPixmap image;
            image.loadFromData(QByteArray::fromBase64(jsonResponse["result"].toString().toUtf8()));
            {
                std::lock_guard<std::mutex> lock{m_replies_mtx};
                m_replies.remove(reply);
            }

            std::lock_guard<std::mutex> lock{m_img_mtx};
            m_marker_images.insert(id, std::move(image));
        }
            break;

        default:
            qDebug() << "markerImageFinished(): Error " << reply->errorString();
            break;
        }
    }
    void markerDeleted(int id)
    {
        qDebug() << "Deleting img for id1: " << id;
        std::lock_guard<std::mutex> lock{m_img_mtx};
        qDebug() << "Deleting img for id: " << id << " success1";
        m_marker_images.remove(id);
        qDebug() << "Deleting img for id: " << id << " success";
    }
private:
    std::mutex m_replies_mtx;
    QMap<QNetworkReply*, int> m_replies; //reply -> marker id
    QNetworkAccessManager* m_web_ctrl;
    std::mutex m_img_mtx;
    QMap<int, QPixmap> m_marker_images;
    QString m_server_ip;
};

#endif // MARKERIMAGEPROVIDER_H
