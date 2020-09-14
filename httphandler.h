#ifndef HTTPHANDLER_H
#define HTTPHANDLER_H
#include "requestmanager.h"
#include <memory>
#include <mutex>
#include <QUrl>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class HttpHandler : public RequestManager
{
public:
    HttpHandler(const QUrl& server_url);
    std::future<QVariant> GetDisplayNameByLogin(const QString &login) const override;
public slots:
    void onError(QNetworkReply::NetworkError code);
    void onGetDisplayNameByLoginFinished();
private:
    std::unique_ptr<QNetworkAccessManager> m_network_access_manager;
    QUrl m_server_url;
    mutable std::mutex m_replies_mtx;
    mutable QMap<QNetworkReply*, std::promise<QVariant>> m_replies;
};

#endif // HTTPHANDLER_H
