#include "sqlconversationmodel.h"

#include <QDateTime>
#include <QDebug>
#include <QSqlError>
#include <QSqlRecord>
#include <QSqlQuery>
#include "sqlcontactmodel.h"


static const char *conversationsTableName = "Conversations";

static void createTable()
{
    if (QSqlDatabase::database().tables().contains(conversationsTableName)) {
        // The table already exists; we don't need to do anything.
        return;
    }

    QSqlQuery query;
    if (!query.exec(
        "CREATE TABLE IF NOT EXISTS 'Conversations' ("
        "'author' TEXT NOT NULL,"
        "'recipient' TEXT NOT NULL,"
        "'timestamp' TEXT NOT NULL,"
        "'message' TEXT NOT NULL,"
        "'owner' TEXT NOT NULL,"
        "FOREIGN KEY('author') REFERENCES Contacts ( name ),"
        "FOREIGN KEY('recipient') REFERENCES Contacts ( name ),"
        "FOREIGN KEY('owner') REFERENCES Contacts ( contact_owner )"
        ")")) {
        qFatal("Failed to query database: %s", qPrintable(query.lastError().text()));
    }
}

SqlConversationModel::SqlConversationModel(QObject *parent) :
    QSqlTableModel(parent)
{
    createTable();
    setTable(conversationsTableName);
    setSort(2, Qt::DescendingOrder);
    // Ensures that the model is sorted correctly after submitting a new row.
    setEditStrategy(QSqlTableModel::OnManualSubmit);
}

void SqlConversationModel::setRecipient(const QString &recipient)
{
    if (recipient == m_recipient)
        return;

    connectToDatabase();
    m_recipient = recipient;

    const QString filterString = QString::fromLatin1(
        "((recipient = '%1' AND author = 'Me') OR (recipient = 'Me' AND author='%1')) AND owner = '%2'").arg(m_recipient, m_current_user_login);
    setFilter(filterString);
    select();
}

void SqlConversationModel::setCurrentUserLogin(const QString &login)
{
    if (login.length() == 0)
    {
        return;
    }
    m_current_user_login = login;
    select();
}

QVariant SqlConversationModel::data(const QModelIndex &index, int role) const
{
    if (role < Qt::UserRole)
        return QSqlTableModel::data(index, role);

    const QSqlRecord sqlRecord = record(index.row());
    return sqlRecord.value(role - Qt::UserRole);
}

QHash<int, QByteArray> SqlConversationModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[Qt::UserRole] = "author";
    names[Qt::UserRole + 1] = "recipient";
    names[Qt::UserRole + 2] = "timestamp";
    names[Qt::UserRole + 3] = "message";
    return names;
}

void SqlConversationModel::sendMessage(const QString &author, const QString &recipient, const QString &message, int unix_time)
{
    qDebug() << "Sending message from: " << author << " to: " << recipient << " text: " << message;
    connectToDatabase();
    QDateTime timestamp;
    timestamp.setTime_t(unix_time);
    const QString timestamp_str = timestamp.toString(Qt::ISODate);

    QSqlRecord newRecord = record();
    newRecord.setValue("author", author);
    newRecord.setValue("recipient", recipient);
    newRecord.setValue("timestamp", timestamp);
    newRecord.setValue("message", message);
    newRecord.setValue("owner", m_current_user_login);
    if (!insertRecord(rowCount(), newRecord)) {
        qWarning() << "Failed to send message:" << lastError().text();
        return;
    }

    submitAll();
}
