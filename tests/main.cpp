#include <QtQuickTest>
#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QQuickStyle>
#include <QSettings>
#include <QStandardPaths>

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

int main(int argc, char* argv[])
{
    // Required by `Settings` (used in Theme.qml) — must be set before any
    // QGuiApplication / QQmlEngine is constructed.
    QCoreApplication::setOrganizationName("Logos");
    QCoreApplication::setOrganizationDomain("logos.co");
    QCoreApplication::setApplicationName("LogosDesignSystemTests");
    QSettings::setPath(QSettings::IniFormat, QSettings::UserScope,
                       QStandardPaths::writableLocation(QStandardPaths::TempLocation));
    QSettings::setDefaultFormat(QSettings::IniFormat);

    QQuickStyle::setStyle("Basic");

    // Logos.Theme/.Controls/.Icons are STATIC-linked via logos_design_system
    // and register into the process qrc at load time, so tst_*.qml files can
    // `import Logos.*` without the engine needing an addImportPath call.

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

    return quick_test_main(
        argc, argv, "LogosDesignSystemTests", sourceDirPtr);
}
