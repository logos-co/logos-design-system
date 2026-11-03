#include "ThemeManager.h"
#include "ThemeStore.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QSaveFile>

Logos::ThemeManager::ThemeManager(const QString& dir, QObject* parent)
    : QObject(parent)
    , m_dir(QDir::isAbsolutePath(dir) ? QDir::cleanPath(dir) : QString())
{
    if (m_dir.isEmpty())
        qWarning("ThemeManager: themes directory must be absolute: %s", qPrintable(dir));
    else {
        // Exists before anything is saved in it.
        QDir().mkpath(m_dir);
        ThemeStore::instance()->setChoiceFile(m_dir + QStringLiteral("/theme.ini"));
        ThemeStore::instance()->addDirectory(m_dir);
    }
}

QVariantMap Logos::ThemeManager::install(const QUrl& file) const
{
    QVariantMap out{ { "ok", false }, { "errors", QStringList{} }, { "warnings", QStringList{} } };
    auto fail = [&](const QString& why) {
        out.insert("errors", QStringList{ why });
        return out;
    };

    if (!file.isLocalFile())
        return fail(tr("Choose a file on this computer."));
    const QFileInfo src(file.toLocalFile());
    if (!src.isFile())
        return fail(tr("Not a file: %1").arg(src.filePath()));
    if (src.size() > ThemeStore::maxDocumentBytes)
        return fail(tr("The file is larger than 64 KiB."));
    QFile in(src.absoluteFilePath());
    if (!in.open(QIODevice::ReadOnly))
        return fail(tr("Can't read %1").arg(src.filePath()));
    // At most one byte past the limit; parseDocument refuses the rest.
    const QByteArray data = in.read(ThemeStore::maxDocumentBytes + 1);

    const QVariantMap parsed = ThemeStore::parseDocument(data, ThemeStore::Validation::Strict);
    out.insert("warnings", parsed.value("warnings"));
    if (!parsed.value("ok").toBool()) {
        out.insert("errors", parsed.value("errors"));
        return out;
    }
    const QVariantMap theme = parsed.value("theme").toMap();
    const QString id = theme.value("id").toString();   // validated: [a-z0-9_.-] only

    if (m_dir.isEmpty())
        return fail(tr("No themes directory."));
    // A copy in another directory would keep being shown instead of this one.
    const QString owner = ThemeStore::instance()->directoryOf(id);
    if (!owner.isEmpty() && owner != m_dir)
        return fail(tr("Another theme folder already provides the id \u201c%1\u201d.").arg(id));
    const QString dir = m_dir + QLatin1Char('/') + id;
    if (QFileInfo(dir).isSymLink() || !QDir().mkpath(dir))
        return fail(tr("Can't create %1").arg(dir));
    // Write the bytes that were validated; the source is never read again.
    QSaveFile outFile(dir + QStringLiteral("/theme.json"));
    if (!outFile.open(QIODevice::WriteOnly) || outFile.write(data) != data.size()
        || !outFile.commit())
        return fail(tr("Can't write %1").arg(outFile.fileName()));

    ThemeStore::instance()->addDirectory(m_dir);

    out.insert("ok", true);
    out.insert("id", id);
    out.insert("name", theme.value("name"));
    return out;
}

bool Logos::ThemeManager::select(const QString& id) const
{
    return ThemeStore::instance()->setCurrent(id);
}

QVariantMap Logos::ThemeManager::remove(const QString& id) const
{
    QVariantMap out{ { "ok", false }, { "id", id }, { "errors", QStringList{} } };
    auto fail = [&](const QString& why) {
        out.insert("errors", QStringList{ why });
        return out;
    };

    auto* store = ThemeStore::instance();
    QString name;
    for (const QVariant& t : store->themes())
        if (t.toMap().value("id").toString() == id)
            name = t.toMap().value("name").toString();
    if (name.isEmpty())
        return fail(tr("There is no installed theme \u201c%1\u201d.").arg(id));
    out.insert("name", name);
    // Ids are validated as [a-z0-9_.-], so this stays inside m_dir.
    if (m_dir.isEmpty() || store->directoryOf(id) != m_dir)
        return fail(tr("\u201c%1\u201d is built in and can't be removed.").arg(name));

    const QString dir = m_dir + QLatin1Char('/') + id;
    if (QFileInfo(dir).isSymLink() || !QDir(dir).removeRecursively())
        return fail(tr("Can't remove %1").arg(dir));

    if (store->current() == id)
        store->setCurrent(QStringLiteral("dark"));
    store->rescan();
    out.insert("ok", true);
    return out;
}
