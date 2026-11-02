#pragma once

#include <QObject>
#include <QString>
#include <QUrl>
#include <QVariantMap>

namespace Logos {

// Installs a user's theme.json into a directory the host chooses.
class ThemeInstaller : public QObject
{
    Q_OBJECT

public:
    explicit ThemeInstaller(const QString& dir, QObject* parent = nullptr);

    // Validate the local file and copy it to <dir>/<id>/theme.json, replacing
    // an installed theme with the same id; nothing is written if it is
    // invalid. On success ThemeStore lists it at once.
    //
    // Returns { ok, id, name, errors: [string], warnings: [string] }.
    Q_INVOKABLE QVariantMap install(const QUrl& file) const;

private:
    QString m_dir;
};

} // namespace Logos
