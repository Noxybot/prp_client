#include "sqlcontactmodel.h"

#include <QDebug>
#include <QSqlError>
#include <QSqlQuery>
void connectToDatabase()
{
    QSqlDatabase database = QSqlDatabase::database();
    if (!database.isValid()) {
        qDebug() << "adding new db";
        database = QSqlDatabase::addDatabase("QSQLITE");
        if (!database.isValid())
            qFatal("Cannot add database: %s", qPrintable(database.lastError().text()));
    }
    qDebug() << "not adding new db";

    const QDir writeDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (!writeDir.mkpath("."))
        qFatal("Failed to create writable directory at %s", qPrintable(writeDir.absolutePath()));

    // Ensure that we have a writable location on all devices.
    const QString fileName = writeDir.absolutePath() + "/chat-database.sqlite3";
    //QFile::remove(fileName);
    qDebug() << "DB FILENAME: " << fileName;
    // When using the SQLite driver, open() will create the SQLite database if it doesn't exist.
    database.setDatabaseName(fileName);
    if (!database.open()) {
        qFatal("Cannot open database: %s", qPrintable(database.lastError().text()));
        QFile::remove(fileName);
    }
}

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
    //hash.insert(Qt::UserRole + 1, "image");
    hash.insert(Qt::UserRole + 1, "login");
}

void SqlContactModel::setCurrentUserLogin(QString login)
{
    if (login.length() == 0)
    {
        present_contacts.clear();
        return;
    }
    m_current_user_login = std::move(login);
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
    query.prepare("SELECT display_name, login FROM Contacts WHERE contact_owner=:owner");
    query.bindValue(":owner", m_current_user_login);
    if (!query.exec())
        qFatal("Contacts updateContacts query failed: %s", qPrintable(query.lastError().text()));

    setQuery(query);
    if (lastError().isValid())
        qFatal("Cannot set query on SqlContactModel: %s", qPrintable(lastError().text()));
}

void SqlContactModel::addContact(const QString &login, const QString& display_name)
{
    qDebug() << "addCon: " << login << " dn " << display_name;
        QSqlQuery query;
        query.prepare("INSERT INTO Contacts(contact_owner, login, display_name) VALUES(:owner, :login, :dn)");
        query.bindValue(":owner", m_current_user_login);
        query.bindValue(":login", login);
        query.bindValue(":dn", display_name);
        if (!query.exec())
            qFatal("Contacts addContact query failed: %s", qPrintable(query.lastError().text()));
        else
            present_contacts.insert(login);
        updateContacts();
}

void SqlContactModel::addUserImage(const QString &login, const QString &image)
{
    qDebug() << "addUserImage::getUserImageByLogin()";
    connectToDatabase(); //mb called from another thread
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

QVector<QString> SqlContactModel::getContactsWithoutAvatar()
{
    if (m_current_user_login.size() == 0)
    {
        qDebug() << "SqlContactModel::getContactsWithoutAvatar: no current user";
        return {};
    }
    QVector<QString> res;
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
    qDebug() << "SqlContactModel::getUserImageByLogin()";
    connectToDatabase(); //mb called from another thread
    QSqlQuery query;
    query.prepare("SELECT image FROM Contacts WHERE login=:login");
    query.bindValue(":login", login);
    if (!query.exec())
        qFatal("Contacts getUserImageByLogin query failed: %s", qPrintable(query.lastError().text()));
    if(query.next())
        return query.value(0).toString();
    return "";
}


