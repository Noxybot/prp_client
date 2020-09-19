#ifndef SQLCONTACTMODEL_H
#define SQLCONTACTMODEL_H

#include "requestmanager.h"

#include <QSqlQueryModel>
#include <QSqlRecord>
#include <QVariantList>
#include <QSqlDatabase>
#include <QSqlError>
#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QDebug>
#include <QMap>
#include <QNetworkAccessManager>
#include <QNetworkReply>

#include <mutex>
#include <unordered_set>

void connectToDatabase();


class SqlContactModel : public QSqlQueryModel
{
    Q_OBJECT
    QHash<int, QByteArray> hash;
    QString m_current_user_login;
    mutable std::mutex m_mtx;
    QMap<QString, bool> m_present_contacts; // login -> is online
    std::shared_ptr<RequestManager> m_request_manager;
public:
    SqlContactModel(std::shared_ptr<RequestManager>, QObject *parent = 0);
    Q_INVOKABLE void setCurrentUserLogin(QString login);
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    void updateContacts();

    void addUserImage(const QString &login, const QString& image);
    //Q_INVOKABLE bool userHasImage(const QString& login);
    QVector<QString> getContactsWithoutAvatar();
    QString getUserImageByLogin(const QString& login);
    const QString& getCurrentUserLogin() const;

    Q_INVOKABLE bool userPresent(const QString& login);
    Q_INVOKABLE void addContact(const QString &login, const QString& display_name);
    Q_INVOKABLE void loginUser(const QString& login);
    Q_INVOKABLE void logoutUser(const QString& login);
    Q_INVOKABLE bool isUserLoggedIn(const QString& login) const;

signals:
    void userLoggedIn(const QString& login);
    void userLogout(const QString& login);
};

#endif // SQLCONTACTMODEL_H
