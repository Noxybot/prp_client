#include "httphandler.h"
#include <QJsonObject>
#include <QJsonDocument>
#include <QNetworkReply>

HttpHandler::HttpHandler(const QUrl& server_url)
    : m_network_access_manager(std::make_unique<QNetworkAccessManager>(this))
    , m_server_url(server_url)
{}

std::future<QVariant> HttpHandler::GetDisplayNameByLogin(const QString &login) const
{
    QNetworkRequest request(m_server_url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QJsonObject json;
    json.insert("method", "get_display_name");
    json.insert("login", login);
    QJsonDocument jsonDoc(json);
    QByteArray jsonData= jsonDoc.toJson();
    std::promise<QVariant> dn_promise;
    QNetworkReply *reply = m_network_access_manager->post(request, jsonData);
    {
        std::lock_guard<std::mutex> lock{m_replies_mtx};
        m_replies.insert(reply, dn_promise);
    }
    QObject::connect(reply, &QNetworkReply::finished, this, &HttpHandler::onGetDisplayNameByLoginFinished);
    return dn_promise.get_future();
}
