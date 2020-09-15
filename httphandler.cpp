#include "httphandler.h"
#include <prp_common/consts.h>

#include <QJsonObject>
#include <QJsonDocument>
#include <QNetworkReply>

#include <QtGlobal>


HttpHandler::HttpHandler(const QUrl& server_url)
    : m_network_access_manager(new QNetworkAccessManager)
    , m_server_url(server_url)
{
    QObject::connect(m_network_access_manager.get(), &QNetworkAccessManager::finished, this, &HttpHandler::onFinished);
}

std::future<QString> HttpHandler::GetDisplayNameByLogin(const QString &login) const
{
    const auto request = GetRequest();
    QJsonObject json;
    json.insert(consts::METHOD, consts::methods::GET_DISPLAY_NAME);
    json.insert(consts::LOGIN, login);
    QJsonDocument jsonDoc(json);
    QByteArray jsonData = jsonDoc.toJson();
    return PostRequestAndReturnFuture<QString>(request, QJsonDocument(json).toJson());
}

std::future<QString> HttpHandler::GetUserStatus(const QString &login) const
{
    const auto request = GetRequest();
    QJsonObject json;
    json.insert(consts::METHOD, consts::methods::GET_USER_STATUS);
    json.insert(consts::LOGIN, login);
    return PostRequestAndReturnFuture<QString>(request, QJsonDocument(json).toJson());
}

std::future<bool> HttpHandler::ConfirmLogin(const QString &login, const QString &password) const
{
    const auto request = GetRequest();
    QJsonObject json;
    json.insert(consts::METHOD, consts::methods::LOGIN_USER);
    json.insert(consts::LOGIN, login);
    json.insert(consts::PASSWORD, password);
    return PostRequestAndReturnFuture<bool>(request, QJsonDocument(json).toJson());
}

std::future<QString> HttpHandler::RegisterUser(const QString &display_name, const QString &login, const QString &password, bool isFB, const QByteArray &image) const
{
    const auto request = GetRequest();
    QJsonObject json;
    if (isFB)
        json.insert(consts::METHOD, consts::methods::LOGIN_FB_USER);
    else
        json.insert(consts::METHOD, consts::methods::REGISTER_USER);
    json.insert(consts::LOGIN, login);
    json.insert(consts::PASSWORD, password);
    json.insert(consts::PASSWORD, display_name);
    return PostRequestAndReturnFuture<QString>(request, QJsonDocument(json).toJson());
}

void HttpHandler::onError(QNetworkReply::NetworkError code)
{
    qDebug() << "HttpHandler::onError, code=" << code;
}

void HttpHandler::onFinished(QNetworkReply* reply)
{
    if (!reply)
        return;
    std::lock_guard<std::mutex> lock (m_replies_mtx);
    const auto reply_it = m_replies.find(reply);
    switch(reply->error())
    {
    case QNetworkReply::NoError:
    {
        const auto jsonResponse = QJsonDocument::fromJson(reply->readAll());
        const auto method = jsonResponse[consts::METHOD].toString();
        if (method == consts::methods::GET_DISPLAY_NAME ||
            method == consts::methods::LOGIN_USER ||
            method == consts::methods::GET_USER_STATUS)
        {
            const auto res = jsonResponse[consts::RESULT].toString();
            Q_ASSERT(reply_it->canConvert<std::shared_ptr<string_promise_t>>() ||
                     reply_it->canConvert<std::shared_ptr<bool_promise_t>>());
            reply_it->setValue(std::move(res));
            m_replies.erase(reply_it);
        }
        break;
    }
    default:
        qDebug() << "HttpHandler::onFinished(): Error " << reply->errorString();
        break;
    }

}

QNetworkRequest HttpHandler::GetRequest() const
{
    QNetworkRequest request(m_server_url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    return request;
}

template<class T>
std::future<T> HttpHandler::PostRequestAndReturnFuture(const QNetworkRequest& request, const QByteArray &body) const
{
    auto dn_promise = std::make_shared<std::promise<T>>();
    QNetworkReply *reply = m_network_access_manager->post(request, body);
    {
        std::lock_guard<std::mutex> lock{m_replies_mtx};
        m_replies.insert(reply, QVariant::fromValue(dn_promise));
    }
    return dn_promise->get_future();
}
