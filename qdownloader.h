#ifndef QDONWLOADER_H
#define QDONWLOADER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QFile>
#include <QStringList>

class QDownloader : public QObject
{
    Q_OBJECT

public:
    explicit QDownloader(QObject *parent = nullptr);
    virtual ~QDownloader();
    Q_INVOKABLE void downloadFile(QUrl url, QString id);

signals:
    // emits error string
    void error(QString);
    // Emits path to img on disk and id
    void downloaded(QString image, QString login);

private slots:
    void fileDownloaded();
    void onReadyRead();

private:
    QNetworkAccessManager *webCtrl;
    QMap<QNetworkReply*, QString> replytologin;
    //QMap<QNetworkReply*, QPair<QString, QString> > replytopathid;

    const QByteArray userAgent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36";
};

#endif // QDONWLOADER_H
