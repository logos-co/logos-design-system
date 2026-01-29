#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QDebug>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    
    // Set application metadata
    app.setOrganizationName("Logos");
    app.setOrganizationDomain("logos.co");
    app.setApplicationName("Design System Demo");
    
    QQmlApplicationEngine engine;

    // Add import paths for the design system
    engine.addImportPath("qrc:/");
    
    // Add filesystem import path for the plugin
    QString qmlModulePath = QCoreApplication::applicationDirPath() + "/qml";
    engine.addImportPath(qmlModulePath);
    
    // Load the demo application
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl) {
                QCoreApplication::exit(-1);
            }
        },
        Qt::QueuedConnection
    );
    
    engine.load(url);
    
    if (engine.rootObjects().isEmpty()) {
        qWarning() << "Failed to load QML file";
        return -1;
    }
    
    qDebug() << "Design System Demo started successfully!";
    qDebug() << "- Click the theme button to toggle between light and dark modes";
    qDebug() << "- Explore different examples using the tabs";
    
    return app.exec();
}
