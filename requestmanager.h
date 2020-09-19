#ifndef REQUESTMANAGER_H
#define REQUESTMANAGER_H

#include <QString>
#include <QByteArray>

#include <future>
#include <cstdint>

class RequestManager
{
public:

    virtual ~RequestManager() = default;
    virtual std::future<QString> GetDisplayNameByLogin(const QString& login) const = 0;
    virtual std::future<QString> ConfirmLogin(const QString& login, const QString& password) const = 0;
    virtual std::future<bool> UploadUserImage(const QString& login, const QByteArray& image) const = 0;
    virtual std::future<bool> UploadMarkerImage(std::uint64_t id, const QByteArray& image) const = 0;
    virtual std::future<QString> RegisterUser(const QString& display_name, const QString& login,
                                           const QString& password, bool isFB, const QByteArray& image = {}) const = 0;
    virtual std::future<QString> GetUserStatus(const QString& login) const = 0;

protected:
};

#endif // REQUESTMANAGER_H
