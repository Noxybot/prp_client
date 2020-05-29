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
    Q_INVOKABLE void scheduleToBase64(QString login_or_marker_id, QString file_path, QString operation_type);
signals:
    void imageConveted_user(QString login, QString imageBase64);
    void imageConveted_marker(QString id, QString imageBase64);

private:
    void toBase64Impl(QString login_or_marker_id, QString file_path, QString operation_type);
};

#endif // QIMAGECONVERTER_H
