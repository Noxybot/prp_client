#ifndef MARKERMODEL_H
#define MARKERMODEL_H

#include <QAbstractListModel>
#include <QGeoCoordinate>
#include <QTime>
#include <QDebug>
#include <unordered_map>
#include <mutex>

struct PlaceInfo
{
    int id;
    QGeoCoordinate coordinates;
    QString creator_login;
    QString name;
    QString category;
    QString subcategory;
    QString from_time;
    QString to_time;
    QString expected_people_number;
    QString expected_expenses;
    QString description;
    QTime creation_time;
    QString image_base64;
};

template <typename T>
uint qHash(const std::shared_ptr<T>& ptr, uint seed = 0)
{
    return qHash(ptr.get(), seed);
}
class MarkerModel : public QAbstractListModel
{
    Q_OBJECT
public:
    using markerPtr = std::shared_ptr<PlaceInfo>;
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
                               QString category, QString subcategory,  QString from_time,  QString to_time,
                               QString expected_people_number, QString expected_expenses,
                               QString description, const QTime &creation_time, int id)
    {
        qDebug() << "addMarker id : " << id;
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
        auto marker = std::make_shared<PlaceInfo>(std::move(info));

        std::lock_guard<std::mutex> lock {m_mtx};
        //qDebug() << "addMarker lock";
        beginInsertRows(QModelIndex(), rowCount(), rowCount());

        if (m_visible_subcategories.find(marker->subcategory) != std::end(m_visible_subcategories) ||m_areAllMarkesVisible)
        {
            m_visible_coordinates.push_back(marker);
            m_all_coordinates.insert(std::move(marker));
        }
        else
            m_all_coordinates.insert(std::move(marker));
        m_current_markers[id] = false;
        endInsertRows();
    }
    Q_INVOKABLE void addImage(int id, QString image)
    {
        //qDebug() << "addImage lock";
        std::lock_guard<std::mutex> lock {m_mtx};
        for (int i = 0; i < m_visible_coordinates.size(); ++i)
        {
            if (m_visible_coordinates[i]->id == id)
            {
              m_visible_coordinates[i]->image_base64 = std::move(image);
              m_current_markers[id] = true;
              return;
            }
        }
    }
    Q_INVOKABLE void removeMarker(int id, bool removeOnlyFromVisible = false)
    {
        std::lock_guard<std::mutex> lock {m_mtx};
        //qDebug() << "removeMarker lock";
        const auto markerIt = std::find_if(m_all_coordinates.begin(), m_all_coordinates.end(),
                                     [&](const markerPtr& marker){
            return marker->id == id;
        });
        if (markerIt == std::end(m_all_coordinates))
            return;
        if (!removeOnlyFromVisible)
        {
            m_current_markers.erase((*markerIt)->id);
            m_all_coordinates.erase(markerIt);
            emit markerDeleted(id);
        }
        for (int i = 0; i < m_visible_coordinates.size(); ++i)
        {
            if (m_visible_coordinates[i]->id == id)
            {
                beginRemoveRows(QModelIndex(), i, i);
                m_visible_coordinates.remove(i);
                endRemoveRows();
                break;
            }
        }

    }

    int rowCount(const QModelIndex &parent = QModelIndex()) const override
    {
        //qDebug() << "rowCount lock";
        Q_UNUSED(parent)
        return m_visible_coordinates.size();
    }
    int columnCount(const QModelIndex &parent) const override
    {
        Q_UNUSED(parent)
        return 1;
    }

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override
    {
        std::lock_guard<std::mutex> lock {m_mtx};
        if (index.row() < 0 || index.row() >= m_visible_coordinates.size())
            return QVariant();
        const auto role_ = static_cast<MarkerRoles>(role);
        const auto &element = m_visible_coordinates[index.row()];
        switch (role_)
        {
            case MarkerRoles::idRole: return QVariant::fromValue(element->id);
            case MarkerRoles::positionRole: return QVariant::fromValue(element->coordinates);
            case MarkerRoles::creationTimeRole: return QVariant::fromValue(element->creation_time);
            case MarkerRoles::creatorLoginRole: return QVariant::fromValue(element->creator_login);
            case MarkerRoles::nameRole: return QVariant::fromValue(element->name);
            case MarkerRoles::categoryRole: return QVariant::fromValue(element->category);
            case MarkerRoles::subcategoryRole: return QVariant::fromValue(element->subcategory);
            case MarkerRoles::fromTimeRole: return QVariant::fromValue(element->from_time);
            case MarkerRoles::toTimeRole: return QVariant::fromValue(element->to_time);
            case MarkerRoles::expectedPeopleNumber: return QVariant::fromValue(element->expected_people_number);
            case MarkerRoles::expectedExpenses: return QVariant::fromValue(element->expected_expenses);
            case MarkerRoles::descriptionRole: return QVariant::fromValue(element->description);
            case MarkerRoles::imageRole: return QVariant::fromValue(element->image_base64);
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
        std::lock_guard<std::mutex> lock {m_mtx};
        //qDebug() << "containtsMarker lock";
        return m_current_markers.find(id) != std::end(m_current_markers);
    }
    Q_INVOKABLE bool markerHasImage(int id)
    {
        std::lock_guard<std::mutex> lock {m_mtx};
        //qDebug() << "markerHasImage lock";
        auto marker = m_current_markers.find(id);
        if (marker != std::end(m_current_markers))
            return marker->second;
        return false;
    }
    Q_INVOKABLE void addVisibleSubcategory(const QString& subcat)
    {
        qDebug() << "Adding visible subcategory: " << subcat << ", total size: " << m_visible_subcategories.size();
        if (m_areAllMarkesVisible)
        {
            m_visible_subcategories.clear();
            m_areAllMarkesVisible = false;
        }
        m_visible_subcategories.insert(subcat);
        ActualizeCoordinates();

    }
    Q_INVOKABLE void removeVisibleSubcategory(const QString& subcat)
    {
        qDebug() << "Removing visible subcategory: " << subcat << ", total size: " << m_visible_subcategories.size();
        m_visible_subcategories.remove(subcat);
        m_areAllMarkesVisible = m_visible_subcategories.empty();
        ActualizeCoordinates();
    }
    Q_INVOKABLE void applySearchPhrase(const QString& phrase)
    {
        ActualizeCoordinates();
        if (phrase.size() == 0)
            return;
        QVector<markerPtr> to_remove;
        {
            std::lock_guard<std::mutex> lock {m_mtx};
            for (auto& marker : m_visible_coordinates)
            {
                if (marker->name.contains(phrase, Qt::CaseInsensitive) ||
                    marker->category.contains(phrase, Qt::CaseInsensitive) ||
                    marker->subcategory.contains(phrase, Qt::CaseInsensitive) ||
                    marker->description.contains(phrase, Qt::CaseInsensitive))
                    continue;
                to_remove.push_back(marker);
            }
        }
        for (auto& marker: to_remove)
            removeMarker(marker->id, true);
    }
    Q_INVOKABLE void hideALlMarkers()
    {
        QVector<markerPtr> to_remove;
        {
            std::lock_guard<std::mutex> lock {m_mtx};
            for (auto& marker : m_visible_coordinates)
            {
                to_remove.push_back(marker);
            }
        }
        for (auto& marker: to_remove)
            removeMarker(marker->id, true);
    }
    Q_INVOKABLE void restoreState()
    {
        m_areAllMarkesVisible = m_visible_subcategories.empty();
        ActualizeCoordinates();
    }
signals:
    void markerDeleted(int id);

private:
    mutable std::mutex m_mtx;
    std::unordered_map<int, bool> m_current_markers; //id -> has_image
    QSet<QString> m_visible_subcategories;
    QSet<markerPtr> m_all_coordinates;
    QVector<markerPtr> m_visible_coordinates;
    //QString m_search_phrase;
    bool m_areAllMarkesVisible = true;

    bool IsMarkerVisible(const markerPtr& marker)
    {
        return m_visible_subcategories.find(marker->subcategory) != std::end(m_visible_subcategories);
    }

    void ActualizeCoordinates()
    {
        for (auto& marker : m_all_coordinates)
        {
            if (m_areAllMarkesVisible || IsMarkerVisible(marker))
            {
                if (!m_visible_coordinates.contains(marker))
                {
                    qDebug() << "adding marker, use_count: " << marker.use_count();
                    std::lock_guard<std::mutex> lock {m_mtx};
                    beginInsertRows(QModelIndex(), rowCount(), rowCount());
                    m_visible_coordinates.push_back(marker);
                    endInsertRows();
                }
            }
            else
            {
                qDebug() << "removing marker, use_count: " << marker.use_count();
                removeMarker(marker->id, true);
            }
        }
    }

};

#endif // MARKERMODEL_H
