#include "qimageconverter.h"
#include <QImage>
#include <QBuffer>
#include <QFileInfo>
#include <QDebug>
#include <thread>

QImageConverter::QImageConverter()
{

}

void QImageConverter::toBase64Impl(QString id, QString file_path)
{
    file_path.replace("file:///", "");
    QImage image {file_path};
    QByteArray byteArray;
    QBuffer buffer(&byteArray);
    image.save(&buffer, "PNG"); // writes the image in JPEG format inside the buffer
    QString iconBase64 = QString::fromLatin1(byteArray.toBase64().data());
    qDebug() << "size: " << iconBase64.size() << ", localpath: " << file_path;
    imageConveted(std::move(id), std::move(iconBase64));
}

void QImageConverter::scheduleToBase64(QString id, QString file_path)
{
    std::thread t {&QImageConverter::toBase64Impl, this, std::move(id), std::move(file_path) };
    t.detach();
}

void QImageConverter::removeFile(const QString &file_path)
{
    QFile::remove(file_path);
}
