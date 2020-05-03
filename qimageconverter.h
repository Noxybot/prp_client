#ifndef QIMAGECONVERTER_H
#define QIMAGECONVERTER_H
#include <QObject>
#include <QString>
#include <QUrl>

class QImageConverter : public QObject
{
    Q_OBJECT
public:
    QImageConverter();
    void toBase64Impl(QString id, QString file_path);
    Q_INVOKABLE void scheduleToBase64(QString id, QString file_path);
    Q_INVOKABLE void removeFile(const QString& file_path);
signals:
    void imageConveted(QString id, QString imageBase64);
};

#endif // QIMAGECONVERTER_H
