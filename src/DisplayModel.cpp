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

    const DisplayObject* object = m_objects[index.row()];

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

    int row = index.row();
    DisplayObject* object = m_objects[row];

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
    updateObjects(DisplayObject::DisplayType::Player, playerObjects);

    QJsonObject ghostObjects = objectList["ghosts"].toObject();
    updateObjects(DisplayObject::DisplayType::Ghost, ghostObjects);
}

void DisplayModel::updateObjects(const DisplayObject::DisplayType& objectType, const QJsonObject& updatedObjects)
{
    QSet<QString> oldUuidSet;
    QSet<QString> newUuidSet;

    for (const DisplayObject* oldObject : qAsConst(m_objects)) {
        oldUuidSet.insert(oldObject->uuid());
    }

    for (const QJsonValue& newObject : updatedObjects) {
        QJsonObject jsonObj = newObject.toObject();
        QString uuid = jsonObj.value("uuid").toString();
        int style = jsonObj.value("style").toInt();
        int x = jsonObj.value("x").toInt();
        int y = jsonObj.value("y").toInt();
        QPoint position = QPoint(x, y);
        bool moving = jsonObj.value("moving").toBool();
        int direction = jsonObj.value("direction").toInt();

        newUuidSet.insert(uuid);

        bool exists = false;

        for (int i = 0; i < m_objects.count(); i++) {
            DisplayObject* object = m_objects[i];
            QString oldUuid = object->uuid();

            if (object->type() != objectType) {
                continue;
            }

            if (oldUuid == uuid) {
                exists = true;

                //                qDebug() << "Updating existing DisplayObject. Type:" << type << "| State:" << state << "| Uuid:" << uuid;

                setData(index(i, 0), style, StyleRole);
                setData(index(i, 0), position, PositionRole);
                setData(index(i, 0), moving, MovingRole);
                setData(index(i, 0), direction, DirectionRole);

                break;
            }
        }

        if (!exists) {
            DisplayObject* newObject = new DisplayObject();
            newObject->setUuid(uuid);

            int type = jsonObj.value("type").toInt();
            DisplayObject::DisplayType objectType = static_cast<DisplayObject::DisplayType>(type);
            newObject->setType(objectType);

            QString state = jsonObj.value("state").toString();
            newObject->setState(state);

            newObject->setStyle(style);
            newObject->setPosition(position);
            newObject->setDirection(direction);
            newObject->setMoving(moving);

            qDebug() << "Creating new DisplayObject. Type:" << type << "| State:" << state << "| Uuid:" << uuid;

            beginInsertRows(QModelIndex(), m_objects.count(), m_objects.count());
            m_objects += newObject;
            endInsertRows();
        }
    }

    QSet<QString> removedUuidSet = oldUuidSet - newUuidSet;

    for (const QString& removedUuid : qAsConst(removedUuidSet)) {

        for (DisplayObject* object : qAsConst(m_objects)) {
            QString uuid = object->uuid();

            if (uuid == removedUuid) {
                qDebug() << "Removing DisplayObject. Uuid:" << removedUuid;

                int i = m_objects.indexOf(object);
                beginRemoveRows(QModelIndex(), i, i);
                m_objects.removeAt(i);
                endRemoveRows();
            }
        }
    }
}
