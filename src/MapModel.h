#pragma once

#include "MapObject.h"

#include <QAbstractListModel>

class MapModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit MapModel(QObject *parent = nullptr);

    enum MapRoles {
        TypeRole = Qt::UserRole + 1
    };

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;
    bool setData(const QModelIndex &index, const QVariant &value, int role);

    void processMessage(const QJsonObject &message);

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<MapObject*> m_map;
};
