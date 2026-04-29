#include <QtQuickTest>
#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QObject>
#include <QQmlEngine>
#include <QQuickStyle>

#ifndef LOGOS_DS_QML_DIR
#define LOGOS_DS_QML_DIR ""
#endif
#ifndef QUICK_TEST_SOURCE_DIR
#define QUICK_TEST_SOURCE_DIR ""
#endif

// First existing directory from `candidates`, else empty.
static QString firstExisting(const QStringList& candidates)
{
    for (const QString& p : candidates) {
        if (!p.isEmpty() && QDir(p).exists())
            return p;
    }
    return {};
}

// Adds Logos.Theme / Logos.Controls import paths to every test engine, trying
// the source tree first then the install layout next to the binary.
class TestSetup : public QObject
{
    Q_OBJECT
public slots:
    void qmlEngineAvailable(QQmlEngine* engine)
    {
        const QString binDir = QFileInfo(
            QCoreApplication::applicationFilePath()).absolutePath();
        const QStringList candidates = {
            qEnvironmentVariable("LOGOS_DS_QML"),
            QString::fromUtf8(LOGOS_DS_QML_DIR),
            binDir + "/../lib",
        };
        for (const QString& p : candidates) {
            if (!p.isEmpty() && QDir(p).exists())
                engine->addImportPath(p);
        }
    }
};

int main(int argc, char* argv[])
{
    // Required by `Settings` (used in Theme.qml) — must be set before any
    // QGuiApplication / QQmlEngine is constructed.
    QCoreApplication::setOrganizationName("Logos");
    QCoreApplication::setOrganizationDomain("logos.co");
    QCoreApplication::setApplicationName("LogosDesignSystemTests");
    QQuickStyle::setStyle("Basic");

    TestSetup setup;

    // Resolve where tst_*.qml files live, in priority order:
    //   1. QUICK_TEST_SOURCE_DIR env var (manual override)
    //   2. compile-time path (set by CMake; valid during in-tree build & ctest)
    //   3. install layout (set by the flake's installPhase; valid post-install)
    const QString binDir = QFileInfo(
        QString::fromUtf8(argv[0])).absolutePath();
    const QString sourceDir = firstExisting({
        qEnvironmentVariable("QUICK_TEST_SOURCE_DIR"),
        QString::fromUtf8(QUICK_TEST_SOURCE_DIR),
        binDir + "/../share/logos-design-system-tests",
    });

    const QByteArray sourceDirBytes = sourceDir.toUtf8();
    const char* sourceDirPtr = sourceDirBytes.isEmpty()
        ? nullptr : sourceDirBytes.constData();

    return quick_test_main_with_setup(
        argc, argv, "LogosDesignSystemTests", sourceDirPtr, &setup);
}

#include "main.moc"
