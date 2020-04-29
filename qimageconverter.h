#ifndef QIMAGECONVERTER_H
#define QIMAGECONVERTER_H
#include <QObject>
#include <QString>

class QImageConverter : public QObject
{
    Q_OBJECT
public:
    QImageConverter();
    Q_INVOKABLE QString toBase64(const QString& file_path);
};

#endif // QIMAGECONVERTER_H
