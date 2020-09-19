#include "httphandler.h"
#include <prp_common/consts.h>

#include <QJsonObject>
#include <QJsonDocument>
#include <QNetworkReply>

#include <QtGlobal>


HttpHandler::HttpHandler(const QUrl& server_url)
    : m_server_url(server_url)
{}

HttpHandler::~HttpHandler()
{
    m_tasks_exec.AddTask([this]
    {
       qDebug() << "~HttpHandler()";
       m_network_access_manager->deleteLater();
    });
}

void HttpHandler::PostConstruct()
{
    m_tasks_exec.AddTask([this, self = shared_from_this()]
    {
        m_network_access_manager = new QNetworkAccessManager;
        m_network_access_manager->connectToHost(m_server_url.host(), m_server_url.port(1337));
        QObject::connect(m_network_access_manager, &QNetworkAccessManager::finished, this, &HttpHandler::onFinished, Qt::ConnectionType::DirectConnection);
    });
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

std::future<QString> HttpHandler::ConfirmLogin(const QString &login, const QString &password) const
{
    const auto request = GetRequest();
    QJsonObject json;
    json.insert(consts::METHOD, consts::methods::LOGIN_USER);
    json.insert(consts::LOGIN, login);
    json.insert(consts::PASSWORD, password);
    return PostRequestAndReturnFuture<QString>(request, QJsonDocument(json).toJson());
}
#include <QThread>
std::future<QString> HttpHandler::RegisterUser(const QString &display_name, const QString &login, const QString &password, bool isFB, const QByteArray &image) const
{
     qDebug() << "RegisterUser th id: " << QThread::currentThreadId();
    const auto request = GetRequest();
    QJsonObject json;
    if (isFB)
        json.insert(consts::METHOD, consts::methods::LOGIN_FB_USER);
    else
        json.insert(consts::METHOD, consts::methods::REGISTER_USER);
    json.insert(consts::LOGIN, login);
    json.insert(consts::PASSWORD, password);
    json.insert(consts::DISPLAY_NAME, display_name);
    return PostRequestAndReturnFuture<QString>(std::move(request), QJsonDocument(json).toJson());
}

std::future<bool> HttpHandler::UploadMarkerImage(uint64_t id, const QByteArray &image) const
{
    return {};
}

std::future<bool> HttpHandler::UploadUserImage(const QString &login, const QByteArray &image) const
{
    return {};
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
        qDebug() << "HttpHandler::onFinished, reply=" << jsonResponse.toJson();
        if (method == consts::methods::GET_DISPLAY_NAME ||
            method == consts::methods::LOGIN_USER ||
            method == consts::methods::GET_USER_STATUS ||
            method == consts::methods::REGISTER_USER)
        {
            const auto res = jsonResponse[consts::RESULT].toString();
            qDebug() << "res=" << res << ", typename=" << reply_it->typeName();
            Q_ASSERT(reply_it->canConvert<std::shared_ptr<string_promise_t>>() ||
                     reply_it->canConvert<std::shared_ptr<bool_promise_t>>());
            if (reply_it->canConvert<std::shared_ptr<string_promise_t>>())
                reply_it->value<std::shared_ptr<string_promise_t>>()->set_value(std::move(res));
            else if (reply_it->canConvert<std::shared_ptr<bool_promise_t>>())
                //reply_it->value<std::shared_ptr<bool_promise_t>>()->set_value(res == consts::);
            m_replies.erase(reply_it);
            reply->deleteLater();
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
std::future<T> HttpHandler::PostRequestAndReturnFuture(QNetworkRequest request, QByteArray body) const
{

    auto dn_promise = std::make_shared<std::promise<T>>();
    auto future = dn_promise->get_future();
    m_tasks_exec.AddTask([this, self = shared_from_this(), dn_promise,
                         request = std::move(request), body = std::move(body)] () mutable
    {
        qDebug() << "posting " << body;
        QNetworkReply *reply = m_network_access_manager->post(request, body);
        {
            std::lock_guard<std::mutex> lock{m_replies_mtx};
            m_replies.insert(reply, QVariant::fromValue(dn_promise));
            QObject::connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error), this, &HttpHandler::onError);
        }
    });
    qDebug() << "return";
    return future;
}
