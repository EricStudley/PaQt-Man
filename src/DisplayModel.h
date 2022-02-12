#pragma once

#include "DisplayObject.h"

#include <QAbstractListModel>

class DisplayModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit DisplayModel(QObject *parent = nullptr);

    enum DisplayRoles {
        UuidRole = Qt::UserRole + 1,
        TypeRole,
        StateRole,
        StyleRole,
        PositionRole,
        MovingRole,
        DirectionRole
    };

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;
    bool setData(const QModelIndex &index, const QVariant &value, int role);

    void processMessage(const QJsonObject &message);

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    void updateObjects(const QJsonObject &updatedObjects);

    QMap<QString, DisplayObject*> m_objects;
    QStringList m_objectUuids;
};
