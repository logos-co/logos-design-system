#pragma once

#include <QObject>
#include <QString>
#include <QUrl>
#include <QVariantMap>

namespace Logos {

// The host's control over themes: install a user's theme.json into a
// directory the host chooses, and switch the theme for the whole process.
// Not a QML type; the host gives it to its own UI only.
class ThemeManager : public QObject
{
    Q_OBJECT

public:
    // `dir` must be absolute. ThemeStore reads themes from it, and the choice
    // is saved in <dir>/theme.ini.
    explicit ThemeManager(const QString& dir, QObject* parent = nullptr);

    // Validate the local file strictly and copy it to <dir>/<id>/theme.json,
    // replacing a theme with the same id installed there. Nothing is written
    // if it is invalid, or if another directory already provides the id.
    // On success the theme is listed at once.
    //
    // Returns { ok, id, name, errors: [string], warnings: [string] }.
    Q_INVOKABLE QVariantMap install(const QUrl& file) const;

    // Switch every view to `id` and save it. False for an unknown id.
    Q_INVOKABLE bool select(const QString& id) const;

private:
    QString m_dir;
};

} // namespace Logos
