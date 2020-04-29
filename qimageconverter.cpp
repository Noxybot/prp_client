#include "qimageconverter.h"
#include <QImage>
#include <QBuffer>
#include <QFileInfo>
#include <QDebug>
QImageConverter::QImageConverter()
{

}

QString QImageConverter::toBase64(const QString &file_path)
{
    QImage image {file_path};
    QByteArray byteArray;
    QBuffer buffer(&byteArray);
    image.save(&buffer, QFileInfo(file_path).suffix().toStdString().c_str()); // writes the image in JPEG format inside the buffer
    QString iconBase64 = QString::fromLatin1(byteArray.toBase64().data());
    qDebug() << "file format: " << QFileInfo(file_path).suffix() << ", data: " <<  iconBase64;
    return iconBase64;
}
