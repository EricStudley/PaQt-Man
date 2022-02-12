#include "DisplayModel.h"

#include <QDebug>
#include <QJsonObject>

DisplayModel::DisplayModel(QObject* parent) :
      QAbstractListModel(parent)
{
}

int DisplayModel::rowCount([[maybe_unused]] const QModelIndex& parent) const
{
    return m_objects.count();
}

QVariant DisplayModel::data(const QModelIndex& index, int role) const
{
    if (index.row() < 0 || index.row() >= m_objects.count())
        return {};

    const int row = index.row();
    const QString key = m_objectUuids.at(row);
    const DisplayObject* object = m_objects[key];

    if (role == UuidRole)
        return object->uuid();
    else if (role == TypeRole)
        return object->type();
    else if (role == StateRole)
        return object->state();
    else if (role == StyleRole)
        return object->style();
    else if (role == PositionRole)
        return object->position();
    else if (role == DirectionRole)
        return object->direction();
    else if (role == MovingRole)
        return object->moving();

    return {};
}

bool DisplayModel::setData(const QModelIndex& index, const QVariant& value, int role)
{
    if (!index.isValid())
        return false;

    const int row = index.row();
    const QString key = m_objectUuids.at(row);
    DisplayObject* object = m_objects[key];

    if (role == UuidRole)
        object->setUuid(value.toString());
    else if (role == TypeRole)
        object->setType(value.value<DisplayObject::DisplayType>());
    else if (role == StateRole)
        object->setState(value.toString());
    else if (role == StyleRole)
        object->setStyle(value.toInt());
    else if (role == PositionRole)
        object->setPosition(value.toPoint());
    else if (role == DirectionRole)
        object->setDirection(value.toInt());
    else if (role == MovingRole)
        object->setMoving(value.toBool());

    emit dataChanged(index, index);

    return true;
}

QHash<int, QByteArray> DisplayModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[UuidRole] = "role_uuid";
    roles[TypeRole] = "role_type";
    roles[StateRole] = "role_state";
    roles[StyleRole] = "role_style";
    roles[PositionRole] = "role_position";
    roles[MovingRole] = "role_moving";
    roles[DirectionRole] = "role_direction";
    return roles;
}

void DisplayModel::processMessage(const QJsonObject& message)
{
    QJsonValue objectList = message["objects"];

    QJsonObject playerObjects = objectList["players"].toObject();
    updateObjects(playerObjects);

    QJsonObject ghostObjects = objectList["ghosts"].toObject();
    updateObjects(ghostObjects);
}

void DisplayModel::updateObjects(const QJsonObject& updatedObjects)
{
    if (updatedObjects.isEmpty())
        return;

    QSet<QString> oldUuidSet;
    QSet<QString> newUuidSet;

    for (const QJsonValue& updatedValue : updatedObjects) {
        QJsonObject updatedObject = updatedValue.toObject();
        QString uuid = updatedObject.value("uuid").toString();
        int style = updatedObject.value("style").toInt();
        int x = updatedObject.value("x").toInt();
        int y = updatedObject.value("y").toInt();
        QPoint position = QPoint(x, y);
        bool moving = updatedObject.value("moving").toBool();
        int direction = updatedObject.value("direction").toInt();
        int type = updatedObject.value("type").toInt();
        QString state = updatedObject.value("state").toString();
        bool alive = updatedObject.value("is_alive").toBool();

        if (!alive) {

            if (m_objects.contains(uuid)) {
                oldUuidSet.insert(uuid);
            }
            continue;
        }

        if (m_objects.contains(uuid)) {
            oldUuidSet.insert(uuid);

            int objectIndex = m_objectUuids.indexOf(uuid);

            qDebug() << objectIndex << "Updating existing DisplayObject. Type:" << type << "| State:" << state << "| Uuid:" << uuid;

            setData(index(objectIndex, 0), style, StyleRole);
            setData(index(objectIndex, 0), position, PositionRole);
            setData(index(objectIndex, 0), moving, MovingRole);
            setData(index(objectIndex, 0), direction, DirectionRole);
        }
        else {
            DisplayObject* newObject = new DisplayObject();
            newObject->setUuid(uuid);
            newObject->setType(static_cast<DisplayObject::DisplayType>(type));
            newObject->setState(state);
            newObject->setStyle(style);
            newObject->setPosition(position);
            newObject->setDirection(direction);
            newObject->setMoving(moving);

            qDebug() << m_objectUuids.length() << "Creating new DisplayObject. Type:" << type << "| State:" << state << "| Uuid:" << uuid;

            beginInsertRows(QModelIndex(), m_objectUuids.length(), m_objectUuids.length());
            m_objects[uuid] = newObject;
            m_objectUuids.append(uuid);
            endInsertRows();
        }

        newUuidSet.insert(uuid);
    }

    const QSet<QString> removedUuidSet = oldUuidSet - newUuidSet;

    for (const QString& removedUuid : removedUuidSet) {
        int objectIndex = m_objectUuids.indexOf(removedUuid);
        beginRemoveRows(QModelIndex(), objectIndex, objectIndex);
        m_objects.remove(removedUuid);
        m_objectUuids.removeAll(removedUuid);
        endRemoveRows();

        qDebug() << objectIndex << "Removing DisplayObject. Uuid:" << removedUuid;
    }
}
