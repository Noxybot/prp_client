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
        "   'contact_owner' TEXT NOT NULL,"
        "   'name' TEXT NOT NULL,"
        "   PRIMARY KEY(contact_owner, name)"
        ")")) {
        qFatal("Failed to query database: %s", qPrintable(query.lastError().text()));
    }

    //query.exec("INSERT INTO Contacts VALUES('Albert Einstein')");
   // query.exec("INSERT INTO Contacts VALUES('Ernest Hemingway')");
    //query.exec("INSERT INTO Contacts VALUES('Hans Gude')");
}

SqlContactModel::SqlContactModel(QObject *parent) :
    QSqlQueryModel(parent)
{
    createTable();
    //updateContacts();
    hash.insert(Qt::UserRole, "name");
}

void SqlContactModel::setCurrentUserLogin(QString login)
{
    m_current_user_login = std::move(login);
    updateContacts();
}

void SqlContactModel::updateContacts()
{
    QSqlQuery query;
    query.prepare("SELECT name FROM Contacts WHERE contact_owner=:owner");
    query.bindValue(":owner", m_current_user_login);
    if (!query.exec())
        qFatal("Contacts SELECT query failed: %s", qPrintable(query.lastError().text()));

    setQuery(query);
    if (lastError().isValid())
        qFatal("Cannot set query on SqlContactModel: %s", qPrintable(lastError().text()));
}

void SqlContactModel::addContact(const QString &name)
{
        QSqlQuery query;
        query.prepare("INSERT INTO Contacts VALUES(:owner, :name)");
        query.bindValue(":owner", m_current_user_login);
        query.bindValue(":name", name);
        query.exec();
}
