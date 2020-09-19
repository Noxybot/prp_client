#ifndef QIMAGECONVERTER_H
#define QIMAGECONVERTER_H
#include <QString>
#include <QByteArray>

#include <functional>
namespace utils
{
    void scheduleToBase64(QString file_path, std::function<void(QByteArray)> callback);
}

#endif // QIMAGECONVERTER_H
