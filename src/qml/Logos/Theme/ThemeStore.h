#pragma once

#include <QColor>
#include <QHash>
#include <QObject>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>

namespace Logos {

// The installed themes and the current one, once for the whole process.
// Every QML engine's Theme reads it through ThemeRegistry, so a switch or an
// install shows in every view at once. Only the host switches (ThemeManager).
// Link the design system once per process: a second copy has its own store.
class ThemeStore : public QObject
{
    Q_OBJECT

public:
    static ThemeStore* instance();

    static constexpr qint64 maxDocumentBytes = 64 * 1024;
    QVariantList themes() const { return m_themes; }
    static QStringList paletteTokens();
    void addDirectory(const QString& dir);
    void rescan();
    // Where the choice is saved, an ini file the host picks; unset, it isn't saved.
    void setChoiceFile(const QString& path);
    // The saved choice, or "dark" while that theme isn't installed.
    QString current() const;
    bool setCurrent(const QString& id);
    bool hasTheme(const QString& id) const;
    QString directoryOf(const QString& id) const;
    QVariantMap palette(const QString& id) const;
    QVariantMap palette() const { return m_palette; }
    QColor color(const QString& token) const { return m_palette.value(token).value<QColor>(); }

    // Theme's sizes for C++ (QSS, widgets): "spacing.small", "size.controlLarge",
    // "typography.primaryText". Only those the same in every view: a phone's
    // titles and touch's badge text are QML's. 0 for an unknown token.
    static QStringList metricTokens();
    static int metric(const QString& token);

    // How big controls are: "compact", "comfortable" or "touch". The saved
    // choice, or the platform's default (touch on phones and tablets).
    static QStringList densities();
    static QString defaultDensity();
    QString density() const;
    // "" goes back to the platform's default. False for an unknown density.
    bool setDensity(const QString& density);

    // Strict (installing): a bad colour value is an error, not a warning.
    enum class Validation { Lenient, Strict };
    static QVariantMap parseDocument(const QByteArray& data,
                                     Validation validation = Validation::Lenient);

signals:
    void themesChanged();
    void currentChanged();
    void paletteChanged();
    void densityChanged();

private:
    ThemeStore();
    void settle(const QString& shownBefore);

    QStringList m_dirs;
    QVariantList m_themes;
    QHash<QString, QString> m_sources;   // id -> directory
    QString m_choiceFile;
    QString m_saved;
    QString m_density;   // "" = the platform's default
    QVariantMap m_palette;
};

} // namespace Logos
