#include "MapModel.h"

#include <QDebug>
#include <QJsonObject>
#include <QJsonArray>

MapModel::MapModel(QObject *parent) :
    QAbstractListModel(parent)
{
}

int MapModel::rowCount(const QModelIndex &) const
{
    return m_map.count();
}

QVariant MapModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_map.count())
        return {};

    const MapObject *object = m_map[index.row()];

    if (role == TypeRole)
        return object->type();

    return {};
}

bool MapModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid())
        return false;

    int row = index.row();
    MapObject *object = m_map[row];

    if (role == TypeRole)
        object->setType(value.value<MapObject::MapType>());

    emit dataChanged(index, index);

    return true;
}

void MapModel::processMessage(const QJsonObject &message)
{
    if (!m_map.isEmpty()) {
        return;
    }

    QJsonArray map = message["maps"].toObject()["old school"].toArray();

    for (int i = 0; i < map.count(); i++) {
        QJsonArray array = map[i].toArray();

        for (int j = 0; j < array.count(); j++) {

            // TEST CODE TO FIX PACKET MISMATCH
            int type = 0;
            QString s = array[j].toString();

            if (s == " ") {
                type = 23;
            }
            // TEST CODE TO FIX PACKET MISMATCH

//          int type = map.value(i).toInt();
            MapObject *newObject = new MapObject();
            MapObject::MapType objectType = static_cast<MapObject::MapType>(type);

            newObject->setType(objectType);

//          qDebug() << "Creating new MapObject. Type:" << type;

            beginInsertRows(QModelIndex(), m_map.count(), m_map.count());
            m_map += newObject;
            endInsertRows();
        }
    }
}

QHash<int, QByteArray> MapModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[TypeRole] = "role_type";
    return roles;
}
