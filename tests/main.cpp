#include <QtQuickTest>
#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QLoggingCategory>
#include <QQuickStyle>
#include <QSettings>
#include <QStandardPaths>
#include <QTemporaryDir>
#include <QtQml/qqml.h>

#include <ThemeInstaller.h>
#include <ThemeStore.h>

#ifndef QUICK_TEST_SOURCE_DIR
#define QUICK_TEST_SOURCE_DIR ""
#endif

// C++-only theme API for tst_ThemeRegistry.qml.
class ThemeTestHelper : public QObject
{
    Q_OBJECT
public:
    explicit ThemeTestHelper(const QString& installDir) : m_installDir(installDir) {}

    Q_INVOKABLE QVariantMap parse(const QString& json) const
    {
        return Logos::ThemeStore::parseDocument(json.toUtf8());
    }
    Q_INVOKABLE void clearInstalled() const
    {
        QDir(m_installDir).removeRecursively();
        Logos::ThemeStore::instance()->rescan();
    }
    Q_INVOKABLE QString savedTheme() const
    {
        return QSettings().value("LogosDesignSystem/theme").toString();
    }

private:
    QString m_installDir;
};

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

    // tst_ThemeRegistry: themes from tests/fixtures/themes, installs into a
    // throwaway directory. The broken fixtures' warnings are muted.
    QLoggingCategory::setFilterRules(QStringLiteral("logos.theme.warning=false"));
    static QTemporaryDir installDir;
    Logos::ThemeStore::instance()->addDirectory(sourceDir + "/fixtures/themes");
    static Logos::ThemeInstaller themeInstaller(installDir.path());
    static ThemeTestHelper themeTestHelper(installDir.path());
    qmlRegisterSingletonInstance("LogosTests", 1, 0, "ThemeInstaller", &themeInstaller);
    qmlRegisterSingletonInstance("LogosTests", 1, 0, "ThemeTestHelper", &themeTestHelper);

    const QByteArray sourceDirBytes = sourceDir.toUtf8();
    const char* sourceDirPtr = sourceDirBytes.isEmpty()
        ? nullptr : sourceDirBytes.constData();

    return quick_test_main(
        argc, argv, "LogosDesignSystemTests", sourceDirPtr);
}

#include "main.moc"
