#ifndef SQLCONTACTMODEL_H
#define SQLCONTACTMODEL_H

#include <QSqlQueryModel>
#include <QSqlRecord>

class SqlContactModel : public QSqlQueryModel
{
    Q_OBJECT
    QHash<int,QByteArray> hash;
    QString m_current_user_login;
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

    Q_INVOKABLE void addContact(const QString& name);

};

#endif // SQLCONTACTMODEL_H
