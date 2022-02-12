#pragma once

#include "DisplayModel.h"
#include "MapModel.h"

#include <QObject>

class ApplicationManager : public QObject
{
    Q_OBJECT

public:
    explicit ApplicationManager(QObject *parent = nullptr);

    Q_INVOKABLE void processMessage(const QJsonObject &message);

    DisplayModel* displayModel() { return m_displayModel; }
    MapModel* mapModel() { return m_mapModel; }

private:
    DisplayModel* m_displayModel = new DisplayModel(this);
    MapModel* m_mapModel = new MapModel(this);
};
