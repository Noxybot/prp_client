#ifndef MARKERMODEL_H
#define MARKERMODEL_H

#include <QAbstractListModel>
#include <QGeoCoordinate>


class MarkerModel : public QAbstractListModel
{
    Q_OBJECT

public:
    using QAbstractListModel::QAbstractListModel;
    enum MarkerRoles{
        positionRole = Qt::UserRole + 1,
        idRole = positionRole+1
    };

    Q_INVOKABLE void addMarker(const QGeoCoordinate &coordinate, int id){
        beginInsertRows(QModelIndex(), rowCount(), rowCount());
        m_coordinates[id] = coordinate;
        endInsertRows();
    }

    int rowCount(const QModelIndex &parent = QModelIndex()) const override{
        Q_UNUSED(parent)
        return m_coordinates.count();
    }

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override{
        if (index.row() < 0 || index.row() >= m_coordinates.count())
            return QVariant();
        if(role== MarkerModel::positionRole)
            return QVariant::fromValue((m_coordinates.begin() + index.row()).value());
        if(role==MarkerModel::idRole)
            return QVariant::fromValue((m_coordinates.begin() + index.row()).key());
        return QVariant();
    }

    QHash<int, QByteArray> roleNames() const override{
        QHash<int, QByteArray> roles;
        roles[positionRole] = "position";
        roles[idRole] = "markerId";
        return roles;
    }

private:
    QMap<int, QGeoCoordinate> m_coordinates;
};

#endif // MARKERMODEL_H
