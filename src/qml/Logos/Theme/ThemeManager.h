#pragma once

#include <QObject>
#include <QString>
#include <QUrl>
#include <QVariantMap>

class QQuickItem;

namespace Logos {

// The host's control over themes: install a user's theme.json into a
// directory the host chooses, and switch the theme for the whole process.
// Not a QML type; the host gives it to its own UI only.
class ThemeManager : public QObject
{
    Q_OBJECT

public:
    // `dir` must be absolute. ThemeStore reads themes from it, and the choice
    // of theme and density is saved in <dir>/theme.ini.
    explicit ThemeManager(const QString& dir, QObject* parent = nullptr);

    // Validate the local file strictly and copy it to <dir>/<id>/theme.json,
    // replacing a theme with the same id installed there. Nothing is written
    // if it is invalid, or if another directory already provides the id.
    // On success the theme is listed at once.
    //
    // Returns { ok, id, name, errors: [string], warnings: [string] }.
    Q_INVOKABLE QVariantMap install(const QUrl& file) const;

    // Delete a theme installed in <dir>. Dark and themes from other
    // directories can't be removed. Removing the current theme switches to Dark.
    //
    // Returns { ok, id, name, errors: [string] }.
    Q_INVOKABLE QVariantMap remove(const QString& id) const;

    // Switch every view to `id` and save it. False for an unknown id.
    Q_INVOKABLE bool select(const QString& id) const;

    // Size every view's controls for `density` ("compact", "comfortable" or
    // "touch") and save it; "" goes back to the platform's default (touch on
    // phones and tablets). False for an unknown density.
    Q_INVOKABLE bool setDensity(const QString& density) const;

    // Keep the Theme in `viewRoot`'s engine told the view's width, so its
    // layouts and touch sizes follow it (Theme.viewWidth, Theme.viewClass).
    // Call once per view, with the root item the view sizes to.
    static void followViewWidth(QQuickItem* viewRoot);

private:
    QString m_dir;
};

} // namespace Logos
