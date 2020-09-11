#ifndef MARKERIMAGEPROVIDER_H
#define MARKERIMAGEPROVIDER_H
#include <QQuickImageProvider>

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonObject>
#include <QJsonDocument>
#include <QNetworkAccessManager>
#include <QByteArray>
#include <mutex>
#include <QBuffer>
class MarkerImageProvider : public QObject, public QQuickImageProvider
{
    Q_OBJECT
public:
    ~MarkerImageProvider();

    MarkerImageProvider(QString server_ip);
    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize) override;

public slots:
    void error(QNetworkReply::NetworkError code);
    void markerImageFinished();
    void markerDeleted(int id);
private:
    std::mutex m_replies_mtx;
    QMap<QNetworkReply*, int> m_replies; //reply -> marker id
    QNetworkAccessManager* m_web_ctrl;
    std::mutex m_img_mtx;
    QMap<int, QPixmap> m_marker_images;
    QString m_server_ip;
};

#endif // MARKERIMAGEPROVIDER_H
