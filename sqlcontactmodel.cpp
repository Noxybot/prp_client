#include "sqlcontactmodel.h"

#include <QDebug>
#include <QSqlError>
#include <QSqlQuery>

static void createTable()
{
    if (QSqlDatabase::database().tables().contains(QStringLiteral("Contacts"))) {
        // The table already exists; we don't need to do anything.
        return;
    }

    QSqlQuery query;
    if (!query.exec(
        "CREATE TABLE IF NOT EXISTS 'Contacts' ("
        "   'contact_owner' TEXT NOT NULL," //owner login
        "   'login' TEXT NOT NULL,"
        "   'display_name' TEXT NOT NULL,"
        "   'image' TEXT,"
        "   PRIMARY KEY(contact_owner, login)"
        ")")) {
        qFatal("Failed to query database: %s", qPrintable(query.lastError().text()));
    }
}

SqlContactModel::SqlContactModel(QObject *parent) :
    QSqlQueryModel(parent)
{
    createTable();
    updateContacts();
    hash.insert(Qt::UserRole, "display_name");
    hash.insert(Qt::UserRole + 1, "image");
    hash.insert(Qt::UserRole + 2, "login");
}

void SqlContactModel::setCurrentUserLogin(QString login)
{
    m_current_user_login = std::move(login);
    updateContacts();
    QSqlQuery query;
    query.prepare("SELECT login FROM Contacts WHERE contact_owner=:owner");
    query.bindValue(":owner", m_current_user_login);
    if (!query.exec())
        qFatal("Contacts setCurrentUserLogin query failed: %s", qPrintable(query.lastError().text()));
    while (query.next()){
        present_contacts.insert(query.value(0).toString());
    }
    updateContacts();
}

void SqlContactModel::updateContacts()
{
    QSqlQuery query;
    query.prepare("SELECT display_name, image, login FROM Contacts WHERE contact_owner=:owner");
    query.bindValue(":owner", m_current_user_login);
    if (!query.exec())
        qFatal("Contacts updateContacts query failed: %s", qPrintable(query.lastError().text()));

    setQuery(query);
    if (lastError().isValid())
        qFatal("Cannot set query on SqlContactModel: %s", qPrintable(lastError().text()));
}

void SqlContactModel::addContact(const QString &login, const QString& display_name)
{
        QSqlQuery query;
        query.prepare("INSERT INTO Contacts(contact_owner, login, display_name) VALUES(:owner, :login, :dn)");
        query.bindValue(":owner", m_current_user_login);
        query.bindValue(":login", login);
        query.bindValue(":dn", display_name);
        if (!query.exec())
            qFatal("Contacts addContact query failed: %s", qPrintable(query.lastError().text()));
        updateContacts();
}

void SqlContactModel::addUserImage(const QString &login, const QString &image)
{
    QSqlQuery query;
    query.prepare("UPDATE Contacts SET image =:image WHERE login=:login");
    query.bindValue(":login", login);
    query.bindValue(":image", image);
    query.exec();
    if (!query.exec())
        qFatal("Contacts addUserImage query failed: %s", qPrintable(query.lastError().text()));
    updateContacts();
}

//bool SqlContactModel::userHasImage(const QString &login)
//{
//    QSqlQuery query;
//    query.prepare("SELECT image FROM Contacts WHERE login=:login AND image NOT NULL AND owner=:owner");
//    query.bindValue(":owner", m_current_user_login);
//    query.bindValue(":login", login);
//    query.exec();
//    QSqlRecord rec = query.record();
//    return rec.count() != 0;
//}

QVariantList SqlContactModel::getContactsWithoutAvatar()
{
    QVariantList res;
    QSqlQuery query;
    query.prepare("SELECT login FROM Contacts WHERE image IS NULL AND contact_owner=:owner");
    query.bindValue(":owner", m_current_user_login);
    if (!query.exec())
        qFatal("Contacts getContactsWithoutAvatar query failed: %s", qPrintable(query.lastError().text()));
    while(query.next())
    {
        QString login = query.value(0).toString();
        qDebug() << "user: " << login << " has no avatar";
        res.append(login);
    }
    return res;
}

bool SqlContactModel::userPresent(const QString &login)
{
    return present_contacts.find(login) != std::end(present_contacts);
}

QString SqlContactModel::getUserImageByLogin(const QString &login)
{
    QSqlQuery query;
    query.prepare("SELECT image FROM Contacts WHERE login=:login");
    query.bindValue(":login", login);
    if (!query.exec())
        qFatal("Contacts getUserImageByLogin query failed: %s", qPrintable(query.lastError().text()));
    if(query.next())
        return query.value(0).toString();
    return "";
}


