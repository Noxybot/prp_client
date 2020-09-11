#include "sqlcontactmodel.h"

#include <QDebug>
#include <QSqlError>
#include <QSqlQuery>
#include <QThread>
#include <QJsonObject>
#include <QJsonDocument>
#include <atomic>
void connectToDatabase()
{
    static std::atomic<void*> last_thread_id;
    if (last_thread_id == QThread::currentThreadId())
    {
        //qDebug() << "connection for this thread already made";
        return;
    }

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
    last_thread_id = QThread::currentThreadId();
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

SqlContactModel::SqlContactModel(QString server_ip, QObject *parent)
    : QSqlQueryModel(parent)
    , m_web_ctrl(new QNetworkAccessManager(this))
    , m_server_ip(std::move(server_ip))
{
    createTable();
    updateContacts();
    hash.insert(Qt::UserRole, "display_name");
    hash.insert(Qt::UserRole + 1, "login");
    hash.insert(Qt::UserRole + 2, "last_message");
}

void SqlContactModel::setCurrentUserLogin(QString login)
{
    if (login.length() == 0)
    {
        std::lock_guard<std::mutex> lock{m_mtx};
        m_present_contacts.clear();
        return;
    }

    auto ask_user_state = [&] (const QString& login)
    {
        QUrl server_url = QUrl("http://" + m_server_ip);

        QNetworkRequest request(server_url);

        QJsonObject json;
        json.insert("method", "get_user_status");
        json.insert("login", login); //marker id
        QJsonDocument jsonDoc(json);
        QByteArray jsonData= jsonDoc.toJson();
        request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
        QNetworkReply *reply = m_web_ctrl->post(request, jsonData);
        {
             std::lock_guard<std::mutex> lock{m_replies_mtx};
             m_replies.insert(reply, login);
        }
        QObject::connect(reply, &QNetworkReply::finished, this, &SqlContactModel::userStatusResponseReceived);

    };

    connectToDatabase();

    m_current_user_login = std::move(login);
    QSqlQuery query;
    query.prepare("SELECT login FROM Contacts WHERE contact_owner=:owner");
    query.bindValue(":owner", m_current_user_login);
    if (!query.exec())
        qFatal("Contacts setCurrentUserLogin query failed: %s", qPrintable(query.lastError().text()));
    {
        std::lock_guard<std::mutex> lock{m_mtx};
        while (query.next())
        {
            QString login = query.value(0).toString();
            m_present_contacts.insert(login, false);
            ask_user_state(login);
        }
    }
    updateContacts();

   // QObject::connect(reply, &QNetworkReply::readyRead, this, &MarkerImageProvider::markerImageDownloaded);
    //QObject::connect(reply, &QNetworkReply::errorOccurred, this, &MarkerImageProvider::error);
}

void SqlContactModel::updateContacts()
{
    QSqlQuery query;
   /* query.prepare("SELECT DISTINCT display_name, login, message as last_message, c1.recipient FROM Contacts, Conversations c1 "
                  "WHERE author!=c1.recipient AND contact_owner=owner AND contact_owner=:c_owner AND owner=:c_owner AND login=c1.recipient AND timestamp >= "
                  "(SELECT MAX(timestamp) from Conversations c2 WHERE owner = :c_owner AND c2.recipient=c1.recipient)");*/
    query.prepare("SELECT display_name, login FROM Contacts WHERE contact_owner=:c_owner AND login!=:c_owner");
    query.bindValue(":c_owner", m_current_user_login);
    //qDebug() <<
    qDebug() <<":c_owner"<< m_current_user_login;
    if (!query.exec())
        qFatal("Contacts updateContacts query failed: %s", qPrintable(query.lastError().text()));

    setQuery(query);
    if (lastError().isValid())
        qFatal("Cannot set query on SqlContactModel: %s", qPrintable(lastError().text()));

}

void SqlContactModel::addContact(const QString &login, const QString& display_name)
{
    qDebug() << "addCon: " << login << " dn " << display_name;
    connectToDatabase();

    QSqlQuery query;
    query.prepare("INSERT INTO Contacts(contact_owner, login, display_name) VALUES(:owner, :login, :dn)");
    query.bindValue(":owner", m_current_user_login);
    query.bindValue(":login", login);
    query.bindValue(":dn", display_name);
    if (!query.exec())
        qFatal("Contacts addContact query failed: %s", qPrintable(query.lastError().text()));
    else{
        std::lock_guard<std::mutex> lock{m_mtx};
        m_present_contacts.insert(login, false);
    }
    /*auto ask_user_state = */[&] (const QString& login)
    {
        QUrl server_url = QUrl("http://" + m_server_ip);

        QNetworkRequest request(server_url);

        QJsonObject json;
        json.insert("method", "get_user_status");
        json.insert("login", login); //marker id
        QJsonDocument jsonDoc(json);
        QByteArray jsonData= jsonDoc.toJson();
        request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
        QNetworkReply *reply = m_web_ctrl->post(request, jsonData);
        {
             std::lock_guard<std::mutex> lock{m_replies_mtx};
             m_replies.insert(reply, login);
        }
        QObject::connect(reply, &QNetworkReply::finished, this, &SqlContactModel::userStatusResponseReceived);

    }(login);
    updateContacts();
}

void SqlContactModel::loginUser(const QString &login)
{
     {
        std::unique_lock<std::mutex>lock {m_mtx};
        auto user_it = m_present_contacts.find(login);
        if (user_it != std::end(m_present_contacts))
        {
            *user_it = true;
            lock.unlock();
            emit userLoggedIn(login);
        }

     }
}

void SqlContactModel::logoutUser(const QString &login)
{
    {
        std::unique_lock<std::mutex>lock {m_mtx};
        auto user_it = m_present_contacts.find(login);
        if (user_it != std::end(m_present_contacts))
        {
            *user_it = false;
            lock.unlock();
            emit userLogout(login);
        }
    }
}

bool SqlContactModel::isUserLoggedIn(const QString &login) const
{
    std::lock_guard<std::mutex> lock{m_mtx};
    auto it = m_present_contacts.find(login);
    if (it == std::end(m_present_contacts))
    {
        qDebug() << "SqlContactModel::isUserLoggedIn: no such user: " << login;
        return false;
    }
    return it.value();
}

void SqlContactModel::userStatusResponseReceived()
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
    switch(reply->error())
    {
    case QNetworkReply::NoError:
    {
        qDebug() << "userStatusResponseReceived(): NoError";
        QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
        const QString login = m_replies[reply];
        QJsonDocument jsonResponse = QJsonDocument::fromJson(reply->readAll());
        const QString result = jsonResponse["result"].toString();
        qDebug() << "status response for user: " << login << ", res: " << result;
        {
            std::lock_guard<std::mutex> lock{m_replies_mtx};
            m_replies.remove(reply);
            std::lock_guard<std::mutex> lock_{m_mtx};
            m_present_contacts[login] = result == "online" ? true : false;
        }
    }
        break;

    default:
        qDebug() << "userStatusResponseReceived(): Error " << reply->errorString();
        break;
    }
}

void SqlContactModel::addUserImage(const QString &login, const QString &image)
{
    qDebug() << "addUserImage::getUserImageByLogin()";
    connectToDatabase();//mb called from another thread
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
    std::lock_guard<std::mutex> {m_mtx};
    return m_present_contacts.find(login) != std::end(m_present_contacts);
}

QString SqlContactModel::getUserImageByLogin(const QString &login)
{
    qDebug() << "SqlContactModel::getUserImageByLogin()";
    connectToDatabase();//mb called from another thread
    QSqlQuery query;
    query.prepare("SELECT image FROM Contacts WHERE login=:login");
    query.bindValue(":login", login);
    if (!query.exec())
        qFatal("Contacts getUserImageByLogin query failed: %s", qPrintable(query.lastError().text()));
    if(query.next())
        return query.value(0).toString();
    return "";
}

const QString &SqlContactModel::getCurrentUserLogin() const
{
    return m_current_user_login;
}


