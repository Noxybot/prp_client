#ifndef GUICONNECTOR_H
#define GUICONNECTOR_H
#include "requestmanager.h"

#include <QObject>

#include <memory>

class GuiConnector :  public QObject, public std::enable_shared_from_this<GuiConnector>
{
    Q_OBJECT
    std::shared_ptr<RequestManager> m_request_manager;
public:
    explicit GuiConnector(std::shared_ptr<RequestManager> request_manger, QObject *parent = nullptr);
    enum registrationResult
    {
        REGISTERED,
        USER_EXISTS,
        LOGGED_IN,
        NO_RESPONSE_FROM_SERVER,
    };
    Q_ENUM(GuiConnector::registrationResult);
    Q_INVOKABLE int registerUser(const QString &display_name, const QString &login, const QString &password, bool isFB, const QString &path_to_image) const;
    Q_INVOKABLE bool confirmLogin(const QString& login, const QString& password) const;
    Q_INVOKABLE QString getDisplayNameByLogin(const QString& login) const;
    Q_INVOKABLE QString getUserStatus(const QString &login) const;
    Q_INVOKABLE bool uploadMarkerImage(std::uint64_t id, const QString& image_path) const;
    Q_INVOKABLE bool uploadUserImage(const QString &login, const QString& image_path) const;

};
Q_DECLARE_METATYPE(GuiConnector::registrationResult)
#endif // GUICONNECTOR_H
