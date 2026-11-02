#include "ThemeInstaller.h"
#include "ThemeStore.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QSaveFile>

Logos::ThemeInstaller::ThemeInstaller(const QString& dir, QObject* parent)
    : QObject(parent)
    , m_dir(QDir::cleanPath(dir))
{
}

QVariantMap Logos::ThemeInstaller::install(const QUrl& file) const
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

    const QVariantMap parsed = ThemeStore::parseDocument(data);
    out.insert("warnings", parsed.value("warnings"));
    if (!parsed.value("ok").toBool()) {
        out.insert("errors", parsed.value("errors"));
        return out;
    }
    const QVariantMap theme = parsed.value("theme").toMap();
    const QString id = theme.value("id").toString();   // validated: [a-z0-9_.-] only

    if (m_dir.isEmpty())
        return fail(tr("No themes directory."));
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
