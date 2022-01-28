#include "ApplicationManager.h"
#include "DisplayModel.h"

#include <QQmlApplicationEngine>
#include <QGuiApplication>
#include <QQmlContext>

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    qmlRegisterUncreatableType<DisplayObject>("Enums",1,0,"DisplayType","Error: DisplayType is non-instantiable.");

    ApplicationManager *applicationManager = new ApplicationManager(&app);
    engine.rootContext()->setContextProperty("appManager", applicationManager);
    engine.rootContext()->setContextProperty("displayModel", applicationManager->displayModel());
    engine.rootContext()->setContextProperty("mapModel", applicationManager->mapModel());

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
