#ifndef REQUESTMANAGER_H
#define REQUESTMANAGER_H

#include <QVariant>
#include <future>

class RequestManager
{
public:
    virtual ~RequestManager() = default;
    virtual std::future<QVariant> GetDisplayNameByLogin(const QString& login) const = 0;
};

#endif // REQUESTMANAGER_H
