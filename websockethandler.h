#ifndef WEBSOCKETHANDLER_H
#define WEBSOCKETHANDLER_H
#include "markermodel.h"
#include "sqlcontactmodel.h"
#include "sqlconversationmodel.h"

#include <memory>

#include <QDebug>
#include <QtWebSockets/QWebSocket>
#include <QUrl>

class WebsocketHandler
{
public:
    WebsocketHandler(const QUrl& server_url, std::shared_ptr<MarkerModel> marker_model,
    std::shared_ptr<SqlContactModel> sql_contact_model,
    std::shared_ptr<SqlConversationModel> sql_conversaton_model);
private:
    QWebSocket m_web_socket;
    std::shared_ptr<MarkerModel> m_marker_model;
    std::shared_ptr<SqlContactModel> m_sql_contact_model;
    std::shared_ptr<SqlConversationModel> m_sql_conversation_model;
private slots:
    void    onAboutToClose();
    void	onBinaryFrameReceived(const QByteArray &frame, bool isLastFrame);
    void	onBinaryMessageReceived(const QByteArray &message);
    void	onBytesWritten(qint64 bytes);
    void	onConnected();
    void	ondisconnected();
    void	onEerror(QAbstractSocket::SocketError error);
    void	onPong(quint64 elapsedTime, const QByteArray &payload);
    void	onPreSharedKeyAuthenticationRequired(QSslPreSharedKeyAuthenticator *authenticator);
    void	onProxyAuthenticationRequired(const QNetworkProxy &proxy, QAuthenticator *authenticator);
    void	onReadChannelFinished();
    void	onSslErrors(const QList<QSslError> &errors);
    void	onStateChanged(QAbstractSocket::SocketState state);
    void	onTextFrameReceived(const QString &frame, bool isLastFrame);
    void	onTextMessageReceived(const QString &message);
};

#endif // WEBSOCKETHANDLER_H
