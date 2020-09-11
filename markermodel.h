#ifndef MARKERMODEL_H
#define MARKERMODEL_H

#include <QAbstractListModel>
#include <QGeoCoordinate>
#include <QTime>
#include <QDebug>
#include <unordered_map>
#include <mutex>

template <typename T>
uint qHash(const std::shared_ptr<T>& ptr, uint seed = 0);
class MarkerModel : public QAbstractListModel
{
    Q_OBJECT
public:
    struct markerInfo;
    using markerPtr = std::shared_ptr<markerInfo>;
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

    struct markerInfo
    {
        QGeoCoordinate m_coordinate;
        QString m_creator_login;
        QString m_name;
        QString m_category;
        QString m_subcategory;
        QString m_from_time;
        QString m_to_time;
        QString m_expected_people_number;
        QString m_expected_expenses;
        QString m_description;
        QTime m_creation_time;
        int m_id;
        QString m_image_base64;
    };

    Q_INVOKABLE void addMarker(markerInfo markerInfo_);
    Q_INVOKABLE void addImage(int id, QString image);
    Q_INVOKABLE void removeMarker(int id, bool removeOnlyFromVisible = false);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QHash<int, QByteArray> roleNames() const override;

    bool containtsMarker(int id);
    Q_INVOKABLE bool markerHasImage(int id);
    Q_INVOKABLE void addVisibleSubcategory(const QString& subcat);
    Q_INVOKABLE void removeVisibleSubcategory(const QString& subcat);
    Q_INVOKABLE void applySearchPhrase(const QString& phrase);
    Q_INVOKABLE void hideALlMarkers();
    Q_INVOKABLE void restoreState();
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

    bool IsMarkerVisible(const markerPtr& marker);

    void ActualizeCoordinates();

};
#endif // MARKERMODEL_H
