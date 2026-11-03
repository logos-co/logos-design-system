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

#include <QDebug>
#include <QQmlComponent>
#include <QQmlEngine>
#include <ThemeManager.h>
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

    Q_INVOKABLE QVariantMap parse(const QString& json, bool strict = false) const
    {
        return Logos::ThemeStore::parseDocument(json.toUtf8(), strict
            ? Logos::ThemeStore::Validation::Strict : Logos::ThemeStore::Validation::Lenient);
    }
    // Removes the installed themes, not the saved choice.
    Q_INVOKABLE void clearInstalled() const
    {
        const QDir dir(m_installDir);
        for (const QString& sub : dir.entryList(QDir::Dirs | QDir::NoDotAndDotDot))
            QDir(dir.filePath(sub)).removeRecursively();
        Logos::ThemeStore::instance()->rescan();
    }
    Q_INVOKABLE QString savedTheme() const
    {
        return QSettings(m_installDir + "/theme.ini", QSettings::IniFormat).value("theme").toString();
    }
    Q_INVOKABLE bool appSettingsHaveTheme() const
    {
        return !QSettings().allKeys().filter("theme", Qt::CaseInsensitive).isEmpty();
    }

    // `property` of Theme as seen from a second, independent QQmlEngine, the
    // way Basecamp has one engine per view.
    Q_INVOKABLE QVariant fromOtherEngine(const QString& property)
    {
        if (!m_otherView) {
            m_otherEngine = new QQmlEngine;
            QQmlComponent c(m_otherEngine);
            c.setData("import QtQuick\nimport Logos.Theme\nQtObject {\n"
                      "    property string current: Theme.currentTheme\n"
                      "    property color background: Theme.palette.background\n}\n",
                      QUrl());
            m_otherView = c.create();
            if (!m_otherView)
                qWarning() << c.errors();
        }
        return m_otherView ? m_otherView->property(property.toUtf8()) : QVariant();
    }

    // Must run before the app goes away; this helper is static.
    Q_INVOKABLE void closeOtherEngine()
    {
        delete m_otherView;
        m_otherView = nullptr;
        delete m_otherEngine;
        m_otherEngine = nullptr;
    }

private:
    QString m_installDir;
    QQmlEngine* m_otherEngine = nullptr;
    QObject* m_otherView = nullptr;
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
    static Logos::ThemeManager themeManager(installDir.path());
    static ThemeTestHelper themeTestHelper(installDir.path());
    qmlRegisterSingletonInstance("LogosTests", 1, 0, "ThemeManager", &themeManager);
    qmlRegisterSingletonInstance("LogosTests", 1, 0, "ThemeTestHelper", &themeTestHelper);

    const QByteArray sourceDirBytes = sourceDir.toUtf8();
    const char* sourceDirPtr = sourceDirBytes.isEmpty()
        ? nullptr : sourceDirBytes.constData();

    return quick_test_main(
        argc, argv, "LogosDesignSystemTests", sourceDirPtr);
}

#include "main.moc"
