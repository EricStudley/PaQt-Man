#pragma once

#include <QObject>

class MapObject
{
    Q_GADGET

public:
    enum MapType {
        Unknown = 0,
        Player,
        Ghost,
        Item
    };
    Q_ENUM(MapType)

    MapObject();

    MapType type() const { return m_type; }

    void setType(const MapType &type) { m_type = type; }

private:
    MapType m_type = Unknown;
};
