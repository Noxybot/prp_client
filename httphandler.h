#ifndef HTTPHANDLER_H
#define HTTPHANDLER_H
#include "requestmanager.h"

#include <QUrl>
#include <QNetworkAccessManager>
#include <QNetworkReply>

#include <future>
#include <memory>
#include <mutex>

class HttpHandler : public QObject, public RequestManager
{
    Q_OBJECT
    std::unique_ptr<QNetworkAccessManager> m_network_access_manager;
    QUrl m_server_url;
    mutable std::mutex m_replies_mtx;
    mutable QMap<QNetworkReply*, QVariant> m_replies;
public:
    using string_promise_t = std::promise<QString>;
    using bool_promise_t = std::promise<bool>;
    HttpHandler(const QUrl& server_url);
    std::future<QString> GetDisplayNameByLogin(const QString& login) const override;
    std::future<QString> GetUserStatus(const QString &login) const override;
    std::future<bool>    ConfirmLogin(const QString &login, const QString &password) const override;
    std::future<QString> RegisterUser(const QString &display_name, const QString &login, const QString &password, bool isFB, const QByteArray &image = {}) const override;
private slots:
    void onError(QNetworkReply::NetworkError code);
    void onFinished(QNetworkReply* reply);
private:
    template<class T>
    std::future<T> PostRequestAndReturnFuture(const QNetworkRequest& request, const QByteArray& body) const;
    QNetworkRequest GetRequest() const;

};
Q_DECLARE_METATYPE(std::shared_ptr<HttpHandler::string_promise_t>);
Q_DECLARE_METATYPE(std::shared_ptr<HttpHandler::bool_promise_t>);
#endif // HTTPHANDLER_H
