#ifndef MARKERMODEL_H
#define MARKERMODEL_H

#include <QAbstractListModel>
#include <QGeoCoordinate>
#include <QTime>

struct PlaceInfo
{
    QGeoCoordinate coordinates;
    QString creator_login;
    QString name;
    QString category;
    QString subcategory;
    QTime from_time;
    QTime to_time;
    QString expected_people_number;
    QString expected_expenses;
    QString description;
    QTime creation_time;
};

class MarkerModel : public QAbstractListModel
{
    Q_OBJECT
public:
    using QAbstractListModel::QAbstractListModel;
    enum class MarkerRoles
    {
        positionRole = Qt::UserRole + 1,
        idRole = Qt::UserRole + 2,
        creationTimeRole = Qt::UserRole + 3,
        creatorLoginRole = Qt::UserRole + 4,
        nameRole = Qt::UserRole + 5,
        categoryRole = Qt::UserRole + 6,
        subcategoryRole = Qt::UserRole + 7,
        fromTimeRole = Qt::UserRole + 8,
        toTimeRole = Qt::UserRole + 9,
        expectedPeopleNumber = Qt::UserRole + 10,
        expectedExpenses = Qt::UserRole + 11,
        descriptionRole = Qt::UserRole + 12,
    };

    Q_INVOKABLE void addMarker(const QGeoCoordinate &coordinate, QString creator_login, QString name,
                               QString category, QString subcategory, const QTime &from_time, const QTime &to_time,
                               QString expected_people_number, QString expected_expenses,
                               QString description, const QTime &creation_time, int id)
    {
        beginInsertRows(QModelIndex(), rowCount(), rowCount());
        m_coordinates[id].coordinates = coordinate;
        m_coordinates[id].creation_time = creation_time;
        m_coordinates[id].creator_login = std::move(creator_login);
        m_coordinates[id].name = std::move(name);
        m_coordinates[id].category = std::move(category);
        m_coordinates[id].subcategory = std::move(subcategory);
        m_coordinates[id].from_time = from_time;
        m_coordinates[id].to_time = to_time;
        m_coordinates[id].expected_people_number = std::move(expected_people_number);
        m_coordinates[id].expected_expenses = std::move(expected_expenses);
        m_coordinates[id].description = std::move(description);
        endInsertRows();
    }

    int rowCount(const QModelIndex &parent = QModelIndex()) const override
    {
        Q_UNUSED(parent)
        return m_coordinates.count();
    }

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override
    {
        if (index.row() < 0 || index.row() >= m_coordinates.count())
            return QVariant();
        const auto role_ = static_cast<MarkerRoles>(role);
        const auto &element = (m_coordinates.begin() + index.row()).value();
        switch (role_)
        {
            case MarkerRoles::idRole: return QVariant::fromValue((m_coordinates.begin() + index.row()).key());
            case MarkerRoles::positionRole: return QVariant::fromValue(element.coordinates);
            case MarkerRoles::creationTimeRole: return QVariant::fromValue(element.creation_time);
            case MarkerRoles::creatorLoginRole: return QVariant::fromValue(element.creator_login);
            case MarkerRoles::nameRole: return QVariant::fromValue(element.name);
            case MarkerRoles::categoryRole: return QVariant::fromValue(element.category);
            case MarkerRoles::subcategoryRole: return QVariant::fromValue(element.subcategory);
            case MarkerRoles::fromTimeRole: return QVariant::fromValue(element.from_time);
            case MarkerRoles::toTimeRole: return QVariant::fromValue(element.to_time);
            case MarkerRoles::expectedPeopleNumber: return QVariant::fromValue(element.expected_people_number);
            case MarkerRoles::expectedExpenses: return QVariant::fromValue(element.expected_expenses);
            case MarkerRoles::descriptionRole: return QVariant::fromValue(element.description);
        }
        return QVariant();
    }

    QHash<int, QByteArray> roleNames() const override
    {
        QHash<int, QByteArray> roles;
        roles[static_cast<int>(MarkerRoles::idRole)] = "marker_id";
        roles[static_cast<int>(MarkerRoles::positionRole)] = "position";
        roles[static_cast<int>(MarkerRoles::creationTimeRole)] = "creation_time";
        roles[static_cast<int>(MarkerRoles::creatorLoginRole)] = "creator_login";
        roles[static_cast<int>(MarkerRoles::nameRole)] = "name";
        roles[static_cast<int>(MarkerRoles::categoryRole)] = "category";
        roles[static_cast<int>(MarkerRoles::subcategoryRole)] = "subcategory";
        roles[static_cast<int>(MarkerRoles::fromTimeRole)] = "from_time";
        roles[static_cast<int>(MarkerRoles::toTimeRole)] = "to_time";
        roles[static_cast<int>(MarkerRoles::expectedExpenses)] = "expected_expenses";
        roles[static_cast<int>(MarkerRoles::expectedPeopleNumber)] = "expected_people_number";
        roles[static_cast<int>(MarkerRoles::descriptionRole)] = "description";
        return roles;
    }

private:
    QMap<int, PlaceInfo> m_coordinates;
};

#endif // MARKERMODEL_H
