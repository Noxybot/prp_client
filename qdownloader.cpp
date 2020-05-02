#include "qdownloader.h"
#include <QDebug>
#include <QStandardPaths>
#include <QDir>
QDownloader::QDownloader(QObject *parent) :
    QObject(parent),
    webCtrl(new QNetworkAccessManager(this))
{

}

QDownloader::~QDownloader()
{
    delete webCtrl;
}

void QDownloader::downloadFile(QUrl url, QString login)
{
//    const auto writable_location = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
//    if (!QDir().mkpath(writable_location))
//        qDebug() << "mkpath failed";
//    else
//        qDebug() << "mkpath success";

//    QString path =  writable_location + '/' + id;
//    qDebug() << "Will try to save image at: " << path;

//    QFile *file = new QFile(path, this);
//    if(!file->open(QIODevice::WriteOnly))
//    {
//        qDebug() << "not open";
//        return;
//    }

    qDebug() << "downloadFile, login: " << login;
    QNetworkRequest request(url);
    request.setRawHeader("User-Agent", userAgent);

    QSslConfiguration sslConfiguration(QSslConfiguration::defaultConfiguration());
    sslConfiguration.setPeerVerifyMode(QSslSocket::VerifyNone);
    sslConfiguration.setProtocol(QSsl::AnyProtocol);
    request.setSslConfiguration(sslConfiguration);

    QNetworkReply *reply = webCtrl->get(request);
    replytologin.insert(reply, std::move(login));
    //replytopathid.insert(reply, QPair<QString, QString>(path, id));

    QObject::connect(reply, &QNetworkReply::finished, this, &QDownloader::fileDownloaded);
    QObject::connect(reply, &QNetworkReply::readyRead, this, &QDownloader::onReadyRead);
}

void QDownloader::fileDownloaded()
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
//    auto img_type = reply->header(QNetworkRequest::ContentTypeHeader);
//    QString full_image_path;
//    if (img_type.isValid())
//    {
//        auto& file = replytofile[reply];
//        auto mime_type = img_type.toString();
//        if (mime_type.endsWith("jpeg"))
//        {
//            full_image_path = file->fileName() + ".jpeg";
//            if (!file->rename(full_image_path)) //we aready have this FB user avatar
//                file->remove();
//        }
//        else if (mime_type.endsWith("jpg"))
//        {
//            full_image_path = file->fileName() + ".jpg";
//             if (!file->rename(full_image_path))
//                 file->remove();
//        }

//        else if (mime_type.endsWith("png"))
//        {
//            full_image_path = file->fileName() + ".png";
//             if (!file->rename(full_image_path))
//                file->remove();
//        }
//    }
//    if (replytofile[reply]->isOpen())
//    {
//        replytofile[reply]->close();
//        replytofile[reply]->deleteLater();
//    }

    switch(reply->error())
    {
    case QNetworkReply::NoError:
        break;

    default:
        emit error(reply->errorString().toLatin1());
        break;
    }

    //emit downloaded(full_image_path, replytopathid[reply].second);

//    replytofile.remove(reply);
//    replytopathid.remove(reply);
//    delete reply;
    qDebug() << "efileDownloaded";

}

void QDownloader::onReadyRead()
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
    emit downloaded(reply->readAll().toBase64(), replytologin[reply]);
    qDebug() << "emit downloaded";
}
