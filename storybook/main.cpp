#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QStyleHints>
#include <QFileSystemWatcher>
#include <QTimer>
#include <QDir>
#include <QDirIterator>
#include <QObject>

#ifndef STORYBOOK_PAGES_DIR
#define STORYBOOK_PAGES_DIR ""
#endif

// Watches QML source dirs and asks the engine to drop its component cache, then
// signals QML to re-instantiate the current page Loader. Manual `reload()` is
// also exposed for the toolbar button — useful when the watcher misses changes
// (some editors save via rename/replace which can break inotify on the file).
class HotReloader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString pagesDir READ pagesDir CONSTANT)

public:
    HotReloader(QQmlApplicationEngine* engine,
                const QString& pagesDir,
                const QStringList& extraDirs,
                QObject* parent = nullptr)
        : QObject(parent)
        , m_engine(engine)
        , m_pagesDir(pagesDir)
        , m_watcher(new QFileSystemWatcher(this))
    {
        m_debounce.setSingleShot(true);
        m_debounce.setInterval(150);
        connect(&m_debounce, &QTimer::timeout, this, &HotReloader::reload);

        connect(m_watcher, &QFileSystemWatcher::fileChanged,
                this, [this]() { m_debounce.start(); });
        connect(m_watcher, &QFileSystemWatcher::directoryChanged,
                this, [this](const QString& dir) {
                    addQmlFiles(dir);
                    m_debounce.start();
                });

        QStringList allDirs = extraDirs;
        if (!pagesDir.isEmpty())
            allDirs.prepend(pagesDir);
        for (const QString& dir : std::as_const(allDirs)) {
            if (!QDir(dir).exists())
                continue;
            m_watcher->addPath(dir);
            addQmlFiles(dir);
        }
    }

    QString pagesDir() const { return m_pagesDir; }

public slots:
    void reload()
    {
        if (m_engine)
            m_engine->clearComponentCache();
        emit reloadRequested();
    }

signals:
    void reloadRequested();

private:
    void addQmlFiles(const QString& dir)
    {
        QDirIterator it(dir, {"*.qml"}, QDir::Files,
                        QDirIterator::Subdirectories);
        while (it.hasNext())
            m_watcher->addPath(it.next());
    }

    QQmlApplicationEngine* m_engine = nullptr;
    QString m_pagesDir;
    QFileSystemWatcher* m_watcher = nullptr;
    QTimer m_debounce;
};

// First existing directory from `candidates`, else empty string.
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
    QGuiApplication app(argc, argv);
    app.setOrganizationName("Logos");
    app.setOrganizationDomain("logos.co");
    app.setApplicationName("Logos Storybook");
    app.styleHints()->setTabFocusBehavior(Qt::TabFocusAllControls);
    QQuickStyle::setStyle("Basic");

    const QString binDir = QCoreApplication::applicationDirPath();

    // Logos.Theme/.Controls/.Icons are STATIC-linked into this binary via
    // Logos::DesignSystem and register into the process qrc at load time —
    // no import-path lookup needed for the design system.

    // Pages dir: env override → dev-build path → install layout
    // ($out/bin → $out/lib/pages) → macOS .app after mkMacOSApp relocation.
    const QStringList pagesCandidates = {
        qEnvironmentVariable("LOGOS_STORYBOOK_PAGES"),
        QString::fromUtf8(STORYBOOK_PAGES_DIR),
        binDir + "/../lib/pages",
        binDir + "/../Resources/qt/qml/pages",
    };
    const QString pagesDir = firstExisting(pagesCandidates);

    if (pagesDir.isEmpty()) {
        qCritical() << "LogosStorybook: could not locate pages dir.\n"
                    << "  tried: " << pagesCandidates;
        return -1;
    }

    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:/");

    // HotReloader still watches pages for on-the-fly edits (the raison d'être
    // of the storybook). Logos.* files are STATIC-embedded so their hot-reload
    // path went away — editing a control now needs a rebuild + relaunch.
    HotReloader hot(&engine, pagesDir, /*extraDirs=*/{});
    engine.rootContext()->setContextProperty("Hot", &hot);

    const QUrl url("qrc:/main.qml");
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, &app,
        [url](QObject* obj, const QUrl& objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}

#include "main.moc"
