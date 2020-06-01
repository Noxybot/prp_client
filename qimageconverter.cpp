#include "qimageconverter.h"
#include <QImage>
#include <QBuffer>
#include <QFileInfo>
#include <QDebug>
#include <thread>
#include "exif.h"

QImageConverter::QImageConverter()
{

}

void QImageConverter::toBase64Impl(QString login_or_marker_id, QString file_path, QString operation_type)
{
    file_path.replace("file:///", "");
    QImage image {file_path};
    QImage dstImg = image;
    /*QFile file(file_path);
    if (file.open(QIODevice::ReadOnly)){
    QByteArray data = file.readAll();
    easyexif::EXIFInfo info;
    if (int code = info.parseFrom((unsigned char *)data.data(), data.size())){
         qDebug() << "Error parsing EXIF: code " << code;
    }
         qDebug() << "Orientation         : " << info.Orientation;
         if(info.Orientation == 8) {
             qDebug()<<"Roating";
             QMatrix matrix;
             QPoint center = image.rect().center();
             matrix.translate(center.x(), center.y());
             matrix.rotate(270);

             dstImg = image.transformed(matrix);
         }
         qDebug()<<"Camera model         : \n"<< info.Model.c_str();
    } else
         qDebug() << "Can't open file:" << file_path;*/
    QByteArray byteArray;
    QBuffer buffer(&byteArray);
    qDebug() <<"width "<<dstImg.width()<<"height "<<dstImg.height();
    qDebug() << "before scale size: " << dstImg.sizeInBytes();
    //double proportion = dstImg.width()/dstImg.height();
    dstImg = dstImg.scaled(/*int(*/400/**proportion)*/, 400);
    qDebug() << "after scale size: " << dstImg.sizeInBytes();
    dstImg.save(&buffer, "PNG"); // writes the image in JPEG format inside the buffer
    QString iconBase64 = QString::fromLatin1(byteArray.toBase64().data());
    qDebug() << "size: " << iconBase64.size() << ", localpath: " << file_path << ", operation: " << operation_type;
    if (operation_type == "convert user image"){
        emit imageConveted_user(login_or_marker_id, iconBase64);
    }
    else if (operation_type == "convert marker image"){
        //QFile::remove(file_path);
        emit imageConveted_marker(login_or_marker_id, iconBase64);
    }
}
void QImageConverter::scheduleToBase64(QString login_or_marker_id, QString file_path, QString operation_type)
{
    std::thread t {&QImageConverter::toBase64Impl, this, std::move(login_or_marker_id), std::move(file_path), std::move(operation_type) };
    t.detach();
}

