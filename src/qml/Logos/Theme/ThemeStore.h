#pragma once

#include <QObject>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>

namespace Logos {

// The installed themes and the current one, once for the whole process.
// Every QML engine's Theme reads it through ThemeRegistry, so a switch or an
// install shows in every view at once.
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
    QString current() const { return m_current; }
    void setCurrent(const QString& id);
    bool hasTheme(const QString& id) const;
    static QVariantMap parseDocument(const QByteArray& data);

signals:
    void themesChanged();
    void currentChanged();

private:
    ThemeStore();

    QStringList m_dirs;
    QVariantList m_themes;
    QString m_current;
};

} // namespace Logos
