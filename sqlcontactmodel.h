#ifndef SQLCONTACTMODEL_H
#define SQLCONTACTMODEL_H

#include <QSqlQueryModel>
#include <QSqlRecord>
#include <QVariantList>
#include <unordered_set>

#include <QSqlDatabase>
#include <QSqlError>
#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QDebug>
#include <QMap>
#include <mutex>
#include <QNetworkAccessManager>
#include <QNetworkReply>

void connectToDatabase();


class SqlContactModel : public QSqlQueryModel
{
    Q_OBJECT
    QHash<int,QByteArray> hash;
    QString m_current_user_login;
    mutable std::mutex m_mtx;
    std::mutex m_replies_mtx;
    QMap<QString, bool> m_present_contacts; // login -> is online
    QNetworkAccessManager* m_web_ctrl;
    QString m_server_ip;
    QMap<QNetworkReply*, QString> m_replies; //reply -> login
public:
    SqlContactModel(QString server_ip, QObject *parent = 0);
    Q_INVOKABLE void setCurrentUserLogin(QString login);
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override
    {
        if(role < Qt::UserRole)
        {
                  return QSqlQueryModel::data(index, role);
        }
        QSqlRecord r = record(index.row());
        return r.value(QString(hash.value(role))).toString();
    }
    QHash<int,QByteArray> roleNames() const override { return hash; }
    void updateContacts();

    void addUserImage(const QString &login, const QString& image);
    //Q_INVOKABLE bool userHasImage(const QString& login);
    QVector<QString> getContactsWithoutAvatar();
    QString getUserImageByLogin(const QString& login);

    Q_INVOKABLE bool userPresent(const QString& login);
    Q_INVOKABLE void addContact(const QString &login, const QString& display_name);
    Q_INVOKABLE void loginUser(const QString& login);
    Q_INVOKABLE void logoutUser(const QString& login);
    Q_INVOKABLE bool isUserLoggedIn(const QString& login) const;

signals:
    void userLoggedIn(const QString& login);
    void userLogout(const QString& login);

public slots:
    void userStatusResponseReceived();


};

#endif // SQLCONTACTMODEL_H
