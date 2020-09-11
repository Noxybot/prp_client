#include "markermodel.h"

template<typename T>
uint qHash(const std::shared_ptr<T> &ptr, uint seed)
{
    return qHash(ptr.get(), seed);
}

void MarkerModel::addMarker(markerInfo markerInfo_)
{
    qDebug() << "addMarker id : " << markerInfo_.m_id;
    auto marker = std::make_shared<markerInfo>(std::move(markerInfo_));

    std::lock_guard<std::mutex> lock {m_mtx};
    //qDebug() << "addMarker lock";
    beginInsertRows(QModelIndex(), rowCount(), rowCount());

    if (m_visible_subcategories.find(marker->m_subcategory) != std::end(m_visible_subcategories) ||m_areAllMarkesVisible)
    {
        m_visible_coordinates.push_back(marker);
        m_all_coordinates.insert(std::move(marker));
    }
    else
        m_all_coordinates.insert(std::move(marker));
    m_current_markers[marker->m_id] = false;
    endInsertRows();
}



void MarkerModel::addImage(int id, QString image)
{
    //qDebug() << "addImage lock";
    std::lock_guard<std::mutex> lock {m_mtx};
    for (int i = 0; i < m_visible_coordinates.size(); ++i)
    {
        if (m_visible_coordinates[i]->m_id == id)
        {
            m_visible_coordinates[i]->m_image_base64 = std::move(image);
            m_current_markers[id] = true;
            return;
        }
    }
}

void MarkerModel::removeMarker(int id, bool removeOnlyFromVisible)
{
    std::lock_guard<std::mutex> lock {m_mtx};
    //qDebug() << "removeMarker lock";
    const auto markerIt = std::find_if(m_all_coordinates.begin(), m_all_coordinates.end(),
                                       [&](const markerPtr& marker){
        return marker->m_id == id;
    });
    if (markerIt == std::end(m_all_coordinates))
        return;
    if (!removeOnlyFromVisible)
    {
        m_current_markers.erase((*markerIt)->m_id);
        m_all_coordinates.erase(markerIt);
        emit markerDeleted(id);
    }
    for (int i = 0; i < m_visible_coordinates.size(); ++i)
    {
        if (m_visible_coordinates[i]->m_id == id)
        {
            beginRemoveRows(QModelIndex(), i, i);
            m_visible_coordinates.remove(i);
            endRemoveRows();
            break;
        }
    }

}

int MarkerModel::rowCount(const QModelIndex &parent) const
{
    //qDebug() << "rowCount lock";
    Q_UNUSED(parent)
    return m_visible_coordinates.size();
}

int MarkerModel::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return 1;
}

QVariant MarkerModel::data(const QModelIndex &index, int role) const
{
    std::lock_guard<std::mutex> lock {m_mtx};
    if (index.row() < 0 || index.row() >= m_visible_coordinates.size())
        return QVariant();
    const auto role_ = static_cast<MarkerRoles>(role);
    const auto &element = m_visible_coordinates[index.row()];
    switch (role_)
    {
    case MarkerRoles::idRole: return QVariant::fromValue(element->m_id);
    case MarkerRoles::positionRole: return QVariant::fromValue(element->m_coordinate);
    case MarkerRoles::creationTimeRole: return QVariant::fromValue(element->m_creation_time);
    case MarkerRoles::creatorLoginRole: return QVariant::fromValue(element->m_creator_login);
    case MarkerRoles::nameRole: return QVariant::fromValue(element->m_name);
    case MarkerRoles::categoryRole: return QVariant::fromValue(element->m_category);
    case MarkerRoles::subcategoryRole: return QVariant::fromValue(element->m_subcategory);
    case MarkerRoles::fromTimeRole: return QVariant::fromValue(element->m_from_time);
    case MarkerRoles::toTimeRole: return QVariant::fromValue(element->m_to_time);
    case MarkerRoles::expectedPeopleNumber: return QVariant::fromValue(element->m_expected_people_number);
    case MarkerRoles::expectedExpenses: return QVariant::fromValue(element->m_expected_expenses);
    case MarkerRoles::descriptionRole: return QVariant::fromValue(element->m_description);
    case MarkerRoles::imageRole: return QVariant::fromValue(element->m_image_base64);
    }
    return QVariant();
}

QHash<int, QByteArray> MarkerModel::roleNames() const
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

bool MarkerModel::containtsMarker(int id)
{
    std::lock_guard<std::mutex> lock {m_mtx};
    //qDebug() << "containtsMarker lock";
    return m_current_markers.find(id) != std::end(m_current_markers);
}

bool MarkerModel::markerHasImage(int id)
{
    std::lock_guard<std::mutex> lock {m_mtx};
    //qDebug() << "markerHasImage lock";
    auto marker = m_current_markers.find(id);
    if (marker != std::end(m_current_markers))
        return marker->second;
    return false;
}

void MarkerModel::addVisibleSubcategory(const QString &subcat)
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

void MarkerModel::removeVisibleSubcategory(const QString &subcat)
{
    qDebug() << "Removing visible subcategory: " << subcat << ", total size: " << m_visible_subcategories.size();
    m_visible_subcategories.remove(subcat);
    m_areAllMarkesVisible = m_visible_subcategories.empty();
    ActualizeCoordinates();
}

void MarkerModel::applySearchPhrase(const QString &phrase)
{
    ActualizeCoordinates();
    if (phrase.size() == 0)
        return;
    QVector<markerPtr> to_remove;
    {
        std::lock_guard<std::mutex> lock {m_mtx};
        for (auto& marker : m_visible_coordinates)
        {
            if (marker->m_name.contains(phrase, Qt::CaseInsensitive) ||
                    marker->m_category.contains(phrase, Qt::CaseInsensitive) ||
                    marker->m_subcategory.contains(phrase, Qt::CaseInsensitive) ||
                    marker->m_description.contains(phrase, Qt::CaseInsensitive))
                continue;
            to_remove.push_back(marker);
        }
    }
    for (auto& marker: to_remove)
        removeMarker(marker->m_id, true);
}

void MarkerModel::hideALlMarkers()
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
        removeMarker(marker->m_id, true);
}

void MarkerModel::restoreState()
{
    m_areAllMarkesVisible = m_visible_subcategories.empty();
    ActualizeCoordinates();
}

bool MarkerModel::IsMarkerVisible(const MarkerModel::markerPtr &marker)
{
    return m_visible_subcategories.find(marker->m_subcategory) != std::end(m_visible_subcategories);
}

void MarkerModel::ActualizeCoordinates()
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
            removeMarker(marker->m_id, true);
        }
    }
}
