#include "httphandler.h"

#include <QJsonObject>
#include <QJsonDocument>
#include <QNetworkReply>


HttpHandler::HttpHandler(const QUrl& server_url)
    : m_network_access_manager(new QNetworkAccessManager)
    , m_server_url(server_url)
{
    QObject::connect(m_network_access_manager.get(), &QNetworkAccessManager::finished, this, &HttpHandler::onFinished);
}

std::future<QString> HttpHandler::GetDisplayNameByLogin(const QString &login) const
{
    QNetworkRequest request(m_server_url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QJsonObject json;
    json.insert("method", "get_display_name");
    json.insert("login", login);
    QJsonDocument jsonDoc(json);
    QByteArray jsonData= jsonDoc.toJson();
    std::promise<QString> dn_promise;
    QNetworkReply *reply = m_network_access_manager->post(request, jsonData);
    {
        std::lock_guard<std::mutex> lock{m_replies_mtx};
        m_replies.insert(reply, QVariant::fromValue(dn_promise));
    }
    return dn_promise.get_future();
}

void HttpHandler::onFinished(QNetworkReply *reply)
{
    if (!reply)
        return;
    switch(reply->error())
    {
    case QNetworkReply::NoError:
    {
        QJsonDocument jsonResponse = QJsonDocument::fromJson(reply->readAll());
        const QString method = jsonResponse["method"].toString();
        break;
    }
    default:
        qDebug() << "HttpHandler::onFinished(): Error " << reply->errorString();
        break;
    }

}
