#ifndef HTTPHANDLER_H
#define HTTPHANDLER_H
#include "requestmanager.h"

#include <QUrl>
#include <QNetworkAccessManager>
#include <QNetworkReply>

#include <future>
#include <memory>
#include <mutex>

class HttpHandler : public RequestManager, public QObject
{
public:
    using string_promise_t = std::promise<QString>;
    using bool_promise_t = std::promise<bool>;
    HttpHandler(const QUrl& server_url);
    std::future<QString> GetDisplayNameByLogin(const QString& login) const override;
public slots:
    void onError(QNetworkReply::NetworkError code);
    void onFinished(QNetworkReply* reply);
private:
    std::unique_ptr<QNetworkAccessManager> m_network_access_manager;
    QUrl m_server_url;
    mutable std::mutex m_replies_mtx;
    mutable QMap<QNetworkReply*, QVariant> m_replies;
};
Q_DECLARE_METATYPE(HttpHandler::string_promise_t);
Q_DECLARE_METATYPE(HttpHandler::bool_promise_t);
#endif // HTTPHANDLER_H
