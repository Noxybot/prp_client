#include "helper_functions.h"
#include "exif.h"

#include <QImage>
#include <QBuffer>
#include <QFileInfo>
#include <QDebug>

#include <thread>

namespace utils
{
    void scheduleToBase64(QString file_path, std::function<void(QByteArray)> callback)
    {
        std::thread ([file_path = std::move(file_path), callback = std::move(callback)] () mutable
        {
            file_path.replace("file:///", "");
            QImage image {file_path};
            QImage dstImg = image;
            QFile file(file_path);

            if (file.open(QIODevice::ReadOnly)){
            QByteArray data = file.readAll();
            easyexif::EXIFInfo info;
            if (int code = info.parseFrom((unsigned char *)data.data(), data.size())){
                 qDebug() << "Error parsing EXIF: code " << code;
            }
                 qDebug() << "Orientation         : " << info.Orientation;
                 if(info.Orientation == 8 || info.Orientation == 7) {
                     qDebug()<<"Roating";
                     QMatrix matrix;
                     QPoint center = image.rect().center();
                     matrix.translate(center.x(), center.y());
                     matrix.rotate(270);
                    // qDebug()<<"before transformation "<<login_or_marker_id << " width "<<dstImg.width()<<" height "<<dstImg.height();
                     dstImg = image.transformed(matrix);
                   // qDebug()<<"after transformation "<<login_or_marker_id << " width "<<dstImg.width()<<" height "<<dstImg.height();
                 }
                 if(info.Orientation == 5 || info.Orientation == 6) {
                     qDebug()<<"Roating";
                     QMatrix matrix;
                     QPoint center = image.rect().center();
                     matrix.translate(center.x(), center.y());
                     matrix.rotate(90);
                   //  qDebug()<<"before transformation "<<login_or_marker_id << " width "<<dstImg.width()<<" height "<<dstImg.height();
                     dstImg = image.transformed(matrix);
                   //  qDebug()<<"after transformation "<<login_or_marker_id << " width "<<dstImg.width()<<" height "<<dstImg.height();
                 }
                 qDebug()<<"Camera model         : \n"<< info.Model.c_str();
            } else
                 qDebug() << "Can't open file:" << file_path;
            QByteArray byteArray;
            QBuffer buffer(&byteArray);
            qDebug() <<"width "<<dstImg.width()<<"height "<<dstImg.height();
        //    qDebug()<<"id "<<login_or_marker_id << " before scale size: " << dstImg.sizeInBytes();
            //double proportion = dstImg.width()/dstImg.height();
            //dstImg = dstImg.scaled(int(400*proportion), 400);
            dstImg = dstImg.scaled(400, 400);
            qDebug() << "after scale size: " << dstImg.sizeInBytes();
            dstImg.save(&buffer, "PNG"); // writes the image in JPEG format inside the buffer
           // QString iconBase64 = QString::fromLatin1(byteArray.toBase64().data());
            //qDebug() << "size: " << iconBase64.size() << ", localpath: " << file_path << ", operation: " << operation_type;
            callback(std::move(byteArray));
        }).detach();
    }
}
