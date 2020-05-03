#ifndef MARKERMODEL_H
#define MARKERMODEL_H

#include <QAbstractListModel>
#include <QGeoCoordinate>
#include <QTime>
#include <QDebug>
#include <unordered_map>

struct PlaceInfo
{
    int id;
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
    QString image_base64;
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
        imageRole = Qt::UserRole + 13,
    };

    Q_INVOKABLE void addMarker(const QGeoCoordinate &coordinate, QString creator_login, QString name,
                               QString category, QString subcategory, const QTime &from_time, const QTime &to_time,
                               QString expected_people_number, QString expected_expenses,
                               QString description, const QTime &creation_time, int id)
    {
        qDebug() << "addMarker id : " << id;
        beginInsertRows(QModelIndex(), rowCount(), rowCount());
        PlaceInfo info;
        info.id = id;
        info.coordinates = coordinate;
        info.creation_time = creation_time;
        info.creator_login = std::move(creator_login);
        info.name = std::move(name);
        info.category = std::move(category);
        info.subcategory = std::move(subcategory);
        info.from_time = from_time;
        info.to_time = to_time;
        info.expected_people_number = std::move(expected_people_number);
        info.expected_expenses = std::move(expected_expenses);
        info.description = std::move(description);
        m_coordinates.push_back(std::move(info));
        m_current_markers[id] = false;
        endInsertRows();
    }
    Q_INVOKABLE void addImage(int id, QString image)
    {
        for (int i = 0; i < m_coordinates.size(); ++i)
        {
            if (m_coordinates[i].id == id)
            {
              m_coordinates[i].image_base64 = std::move(image);
              m_current_markers[id] = true;
              return;
            }
        }
    }
    Q_INVOKABLE void removeMarker(int id)
    {
        for (int i = 0; i < m_coordinates.size(); ++i)
        {
            if (m_coordinates[i].id == id)
            {
                beginRemoveRows(QModelIndex(), i, i);
                m_current_markers.erase(m_coordinates[i].id);
                m_coordinates.remove(i);
                endRemoveRows();
                return;
            }
        }

    }

    int rowCount(const QModelIndex &parent = QModelIndex()) const override
    {
        Q_UNUSED(parent)
        return m_coordinates.size();
    }
    int columnCount(const QModelIndex &parent) const override
    {
        Q_UNUSED(parent)
        return 1;
    }

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override
    {
        if (index.row() < 0 || index.row() >= m_coordinates.size())
            return QVariant();
        const auto role_ = static_cast<MarkerRoles>(role);
        const auto &element = m_coordinates[index.row()];
        switch (role_)
        {
            case MarkerRoles::idRole: return QVariant::fromValue(element.id);
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
            case MarkerRoles::imageRole: return QVariant::fromValue(element.image_base64);
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
        roles[static_cast<int>(MarkerRoles::imageRole)] = "image";
        return roles;
    }

    Q_INVOKABLE bool containtsMarker(int id)
    {
        return m_current_markers.find(id) != std::end(m_current_markers);
    }
    Q_INVOKABLE bool markerHasImage(int id)
    {
        auto marker = m_current_markers.find(id);
        if (marker != std::end(m_current_markers))
            return marker->second;
        return false;
    }

private:
    std::unordered_map<int, bool> m_current_markers; //id -> has_image
    QVector<PlaceInfo> m_coordinates;
};

#endif // MARKERMODEL_H
