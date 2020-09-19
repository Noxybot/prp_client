#include "guiconnector.h"
#include "helper_functions.h"
#include "prp_common/consts.h"

#include <QtDebug>

GuiConnector::GuiConnector(std::shared_ptr<RequestManager> request_manger,QObject *parent)
    : QObject(parent)
    , m_request_manager(std::move(request_manger))
{}

int GuiConnector::registerUser(const QString &display_name, const QString &login, const QString &password, bool isFB, const QString &path_to_image) const
{
    auto future = m_request_manager->RegisterUser(display_name, login, password, isFB);
    if (future.wait_for(std::chrono::seconds(5)) == std::future_status::ready)
    {
        qDebug() << "reg_res";
        try {
            const auto reg_res = future.get();
            qDebug() << "reg_res=" << reg_res;
            if (reg_res == consts::registration_result::LOGGED_IN)
                return registrationResult::LOGGED_IN;
            if (reg_res == consts::registration_result::REGISTERED)
                return registrationResult::REGISTERED;
            if (reg_res == consts::registration_result::USER_EXISTS)
                return registrationResult::USER_EXISTS;
        } catch (const std::future_error& e) {
            qDebug() << "Caught a future_error with code \"" << e.what();
        }
    }
    return registrationResult::NO_RESPONSE_FROM_SERVER;
}

bool GuiConnector::confirmLogin(const QString &login, const QString &password) const
{
    auto future = m_request_manager->ConfirmLogin(login, password);
    const auto login_result = future.get();
    if (login_result == consts::login_result::NOT_FOUND ||
        login_result == consts::login_result::WRONG_CREDENTIALS ||
        login_result == consts::login_result::ALREADY_LOGGED_IN)
        return false;
    return true;
}

QString GuiConnector::getDisplayNameByLogin(const QString &login) const
{
    return m_request_manager->GetDisplayNameByLogin(login).get();
}

QString GuiConnector::getUserStatus(const QString &login) const
{
    return m_request_manager->GetUserStatus(login).get();
}

bool GuiConnector::uploadMarkerImage(uint64_t id, const QString &image_path) const
{
    utils::scheduleToBase64(image_path, [this, id, self = shared_from_this()](const QByteArray& image)
    {
        m_request_manager->UploadMarkerImage(id, image);
    });
    return true;
}

bool GuiConnector::uploadUserImage(const QString &login, const QString& image_path) const
{
    utils::scheduleToBase64(image_path, [this, login, image_path, self = shared_from_this()](const QByteArray& image)
    {
        m_request_manager->UploadUserImage(login, image);
    });
    return true;
}
