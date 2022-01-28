#include "ApplicationManager.h"

ApplicationManager::ApplicationManager(QObject *parent) : QObject(parent)
{

}

void ApplicationManager::processMessage(const QJsonObject &message)
{
    m_displayModel->processMessage(message);
    m_mapModel->processMessage(message);
}
