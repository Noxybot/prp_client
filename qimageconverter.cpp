#include "qimageconverter.h"
#include <QImage>
#include <QBuffer>
#include <QFileInfo>
#include <QDebug>
#include <thread>

QImageConverter::QImageConverter()
{

}

void QImageConverter::toBase64Impl(QString login_or_marker_id, QString file_path, QString operation_type)
{
    file_path.replace("file:///", "");
    QImage image {file_path};
    QByteArray byteArray;
    QBuffer buffer(&byteArray);
    qDebug() << "before scale size: " << image.sizeInBytes();
    image = image.scaled(100, 100);
    qDebug() << "after scale size: " << image.sizeInBytes();
    image.save(&buffer, "PNG"); // writes the image in JPEG format inside the buffer
    QString iconBase64 = QString::fromLatin1(byteArray.toBase64().data());
    qDebug() << "size: " << iconBase64.size() << ", localpath: " << file_path << ", operation: " << operation_type;
    if (operation_type == "convert user image"){
        QFile::remove(file_path);
        emit imageConveted_user(login_or_marker_id, iconBase64);
    }
    else if (operation_type == "convert marker image"){
        emit imageConveted_marker(login_or_marker_id, iconBase64);
    }
}
void QImageConverter::scheduleToBase64(QString login_or_marker_id, QString file_path, QString operation_type)
{
    std::thread t {&QImageConverter::toBase64Impl, this, std::move(login_or_marker_id), std::move(file_path), std::move(operation_type) };
    t.detach();
}

