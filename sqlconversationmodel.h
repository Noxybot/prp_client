#ifndef SQLCONVERSATIONMODEL_H
#define SQLCONVERSATIONMODEL_H

#include <QSqlTableModel>

class SqlConversationModel : public QSqlTableModel
{
    Q_OBJECT

public:
    SqlConversationModel(QObject *parent = 0);

    Q_INVOKABLE void setRecipient(const QString &recipient);
    Q_INVOKABLE void setCurrentUserLogin(const QString &login);

    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void sendMessage(const QString &author, const QString &recipient, const QString &message);

signals:

private:
    QString m_recipient;
    QString m_current_user_login;
};

#endif // SQLCONVERSATIONMODEL_H
