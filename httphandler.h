#ifndef HTTPHANDLER_H
#define HTTPHANDLER_H
#include "requestmanager.h"
#include "taskexecutor.h"

#include <QUrl>
#include <QNetworkAccessManager>
#include <QNetworkReply>

#include <future>
#include <memory>
#include <mutex>

class HttpHandler : public QObject, public RequestManager, public std::enable_shared_from_this<HttpHandler>
{
    Q_OBJECT
    QNetworkAccessManager* m_network_access_manager;
    QUrl m_server_url;
    mutable std::mutex m_replies_mtx;
    mutable QMap<QNetworkReply*, QVariant> m_replies;
    mutable TaskExecutor m_tasks_exec;
public:
    using string_promise_t = std::promise<QString>;
    using bool_promise_t = std::promise<bool>;
    HttpHandler(const QUrl& server_url);
    ~HttpHandler();
    void PostConstruct();

    std::future<QString> GetDisplayNameByLogin(const QString& login) const override;
    std::future<QString> GetUserStatus(const QString &login) const override;
    std::future<QString> ConfirmLogin(const QString &login, const QString &password) const override;
    std::future<QString> RegisterUser(const QString &display_name, const QString &login, const QString &password, bool isFB, const QByteArray &image = {}) const override;
    std::future<bool> UploadMarkerImage(std::uint64_t id, const QByteArray &image) const override;
    std::future<bool> UploadUserImage(const QString &login, const QByteArray &image) const override;
private slots:
    void onError(QNetworkReply::NetworkError code);
    void onFinished(QNetworkReply* reply);
private:
    template<class T>
    std::future<T> PostRequestAndReturnFuture(QNetworkRequest request, QByteArray body) const;
    QNetworkRequest GetRequest() const;
};
Q_DECLARE_METATYPE(std::shared_ptr<HttpHandler::string_promise_t>);
Q_DECLARE_METATYPE(std::shared_ptr<HttpHandler::bool_promise_t>);
#endif // HTTPHANDLER_H
