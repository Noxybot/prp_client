#ifndef SQLCONTACTMODEL_H
#define SQLCONTACTMODEL_H

#include <QSqlQueryModel>
#include <QSqlRecord>
#include <QVariantList>
#include <unordered_set>

class SqlContactModel : public QSqlQueryModel
{
    Q_OBJECT
    QHash<int,QByteArray> hash;
    QString m_current_user_login;
    std::unordered_set<QString> present_contacts;
public:
    SqlContactModel(QObject *parent = 0);
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
    Q_INVOKABLE void updateContacts();

    Q_INVOKABLE void addContact(const QString &login, const QString& display_name);
    Q_INVOKABLE void addUserImage(const QString &login, const QString& image);
    //Q_INVOKABLE bool userHasImage(const QString& login);
    Q_INVOKABLE QVariantList getContactsWithoutAvatar();
    Q_INVOKABLE bool userPresent(const QString& login);
    Q_INVOKABLE QString getUserImageByLogin(const QString& login);

};

#endif // SQLCONTACTMODEL_H
