#include "markerimageprovider.h"


MarkerImageProvider::~MarkerImageProvider()
{
    qDebug() << "MarkerImageProvider DELETED";
}

MarkerImageProvider::MarkerImageProvider(QString server_ip)
    : QQuickImageProvider(QQuickImageProvider::Pixmap)
    , m_web_ctrl(new QNetworkAccessManager(this))
    , m_server_ip(std::move(server_ip)) {}

QPixmap MarkerImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    Q_UNUSED(size);
    qDebug() << "requestPixmap for marker id: " << id << " size: " << requestedSize;
    auto img_it = m_marker_images.find(id.toInt());
    if (img_it != std::end(m_marker_images))
        return img_it.value().scaled(requestedSize);//, Qt::KeepAspectRatio);

    {
        std::lock_guard<std::mutex> lock_{m_replies_mtx};
        for (const auto& elem : m_replies)
        {
            if (elem == id.toInt()) //already in progress
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

void MarkerImageProvider::error(QNetworkReply::NetworkError code)
{
    qDebug() << "error, QNetworkReply: " << code;

}

void MarkerImageProvider::markerImageFinished()
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

        QString image_str = jsonResponse["result"].toString();
        if(image_str == "no image")
        {
            image.load(":/images/empty.jpg");
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
        m_marker_images.insert(id, std::move(image));
    }
        break;

    default:
        qDebug() << "markerImageFinished(): Error " << reply->errorString();
        break;
    }
}

void MarkerImageProvider::markerDeleted(int id)
{
    qDebug() << "Deleting img for id1: " << id;
    std::lock_guard<std::mutex> lock{m_img_mtx};
    qDebug() << "Deleting img for id: " << id << " success1";
    m_marker_images.remove(id);
    qDebug() << "Deleting img for id: " << id << " success";
}


