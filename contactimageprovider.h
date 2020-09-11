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
    ~ContactImageProvider();


    ContactImageProvider(QString server_ip, std::shared_ptr<SqlContactModel> sql_contact_model);

    Q_INVOKABLE void setCurrentUserLogin(QString login);
    QPixmap requestPixmap(const QString &login, QSize *size, const QSize &requestedSize) override;


public slots:
    void error(QNetworkReply::NetworkError code);
    void userImageFinished();
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
