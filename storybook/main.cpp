#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFileSystemWatcher>
#include <QTimer>
#include <QDir>
#include <QDirIterator>
#include <QObject>

#ifndef STORYBOOK_PAGES_DIR
#define STORYBOOK_PAGES_DIR ""
#endif
#ifndef LOGOS_DS_QML_DIR
#define LOGOS_DS_QML_DIR ""
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

    const QString binDir = QCoreApplication::applicationDirPath();

    // Resolve QML import roots in priority order: env override, dev-build path
    // baked at compile time, post-build copy next to binary, install layout
    // ($out/bin → $out/lib).
    const QStringList qmlImportCandidates = {
        qEnvironmentVariable("LOGOS_DS_QML"),
        QString::fromUtf8(LOGOS_DS_QML_DIR),
        binDir + "/qml",
        binDir + "/../lib",
    };
    QStringList watchableImports;
    for (const QString& p : qmlImportCandidates) {
        if (!p.isEmpty() && QDir(p).exists())
            watchableImports << p;
    }

    // Pages dir: env override → dev-build path → install layout
    // ($out/bin → $out/share/logos-storybook/pages).
    const QString pagesDir = firstExisting({
        qEnvironmentVariable("LOGOS_STORYBOOK_PAGES"),
        QString::fromUtf8(STORYBOOK_PAGES_DIR),
        binDir + "/../share/logos-storybook/pages",
    });

    if (pagesDir.isEmpty() || watchableImports.isEmpty()) {
        qCritical() << "LogosStorybook: could not locate pages or QML modules.\n"
                    << "  pages tried:    " << QStringList{
                        qEnvironmentVariable("LOGOS_STORYBOOK_PAGES"),
                        QString::fromUtf8(STORYBOOK_PAGES_DIR),
                        binDir + "/../share/logos-storybook/pages"
                       }
                    << "\n  qml tried:      " << qmlImportCandidates;
        return -1;
    }

    QQmlApplicationEngine engine;
    for (const QString& p : watchableImports)
        engine.addImportPath(p);
    engine.addImportPath("qrc:/");

    HotReloader hot(&engine, pagesDir, watchableImports);
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
