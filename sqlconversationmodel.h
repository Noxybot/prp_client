#ifndef SQLCONVERSATIONMODEL_H
#define SQLCONVERSATIONMODEL_H

#include <QSqlTableModel>

class SqlConversationModel : public QSqlTableModel
{
    Q_OBJECT
    Q_PROPERTY(QString recipient READ recipient WRITE setRecipient NOTIFY recipientChanged)

public:
    SqlConversationModel(QObject *parent = 0);

    QString recipient() const;
    Q_INVOKABLE void setRecipient(const QString &recipient);

    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void sendMessage(const QString &author, const QString &recipient, const QString &message);

signals:
    void recipientChanged();

private:
    QString m_recipient;
};

#endif // SQLCONVERSATIONMODEL_H
