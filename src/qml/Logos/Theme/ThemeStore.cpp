#include "ThemeStore.h"

#include <QColor>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QLoggingCategory>
#include <QRegularExpression>
#include <QSet>
#include <QSettings>

Q_LOGGING_CATEGORY(lcTheme, "logos.theme")

namespace {

constexpr int kFormatVersion = 1;
constexpr int kMaxLabelLength = 40;
constexpr int kMaxIdLength = 64;

const QStringList kBuiltinIds = { QStringLiteral("dark") };

// Colours a theme may set
const QStringList& paletteTokenList()
{
    static const QStringList v = {
        "background", "backgroundSecondary", "backgroundTertiary", "backgroundElevated",
        "backgroundMuted", "backgroundBlack", "backgroundInset", "backgroundButton",
        "surface", "surfaceRaised", "surfaceInteractiveHover", "surfaceRecessed",
        "surfaceContrast",
        "text", "textSecondary", "textSubtle", "textTertiary", "textPlaceholder", "textMuted",
        "border", "borderSecondary", "borderTertiary", "borderTertiaryMuted", "borderSubtle",
        "borderHairline", "borderGlyph", "borderInteractive", "borderDark", "borderStrong",
        "primary", "primaryHover", "primaryPressed", "primarySoft",
        "success", "successHover", "successPressed", "successBorder",
        "error", "errorHover", "errorPressed", "errorBorder",
        "warning", "warningHover", "warningBorder",
        "info", "primaryBorder", "notification",
        "accentOrange", "accentOrangeMid", "accentOrangeDeep", "accentBurntOrange",
        "accentYellowSoft",
        "hover", "pressed", "disabled", "focus",
        "glassOverlay", "glassStrong", "overlayDark", "overlayLight", "overlayOrange", "scrim",
    };
    return v;
}

// Colours DarkTheme.qml derives from another one. A theme that sets the
// source but not the derived colour gets it re-derived, not dark's.
struct Derived { const char* token; const char* source; double alpha; };
const Derived kDerived[] = {
    { "primaryBorder", "primary", 0.4 },
    { "borderTertiaryMuted", "borderTertiary", 0.2 },
};

// "#RRGGBB" or "#RRGGBBAA" (CSS order; Qt's own string form is #AARRGGBB).
bool parseColor(const QString& s, QColor* out)
{
    static const QRegularExpression re(QStringLiteral("^#([0-9A-Fa-f]{6})([0-9A-Fa-f]{2})?$"));
    const auto m = re.match(s);
    if (!m.hasMatch())
        return false;
    QColor c(QLatin1Char('#') + m.captured(1));
    if (m.hasCaptured(2))
        c.setAlpha(m.captured(2).toInt(nullptr, 16));
    *out = c;
    return true;
}

// Names and authors can end up in text that opts in to markup, so markup
// characters are refused rather than escaped at every call site.
QString requireLabel(const QJsonObject& doc, const char* key, QStringList& errors)
{
    static const QRegularExpression unsafe(QStringLiteral("[<>&\\p{Cc}]"));
    const QJsonValue v = doc.value(QLatin1String(key));
    const QString s = v.toString().trimmed();
    if (!v.isString() || s.isEmpty())
        errors << QStringLiteral("'%1' must be a non-empty string").arg(QLatin1String(key));
    else if (s.size() > kMaxLabelLength)
        errors << QStringLiteral("'%1' is longer than %2 characters").arg(QLatin1String(key)).arg(kMaxLabelLength);
    else if (unsafe.match(s).hasMatch())
        errors << QStringLiteral("'%1' may not contain <, > or &").arg(QLatin1String(key));
    return s;
}

// Required fields: { id, name, author, mode }. Problems go to `errors`.
QVariantMap readIdentity(const QJsonObject& doc, QStringList& errors, QStringList& warnings)
{
    // A newer format still loads, reading only the keys this one knows.
    const QJsonValue fv = doc.value("formatVersion");
    const int version = fv.isDouble() ? qRound(fv.toDouble()) : 0;
    if (version < 1)
        errors << QStringLiteral("'formatVersion' must be an integer >= 1");
    else if (version > kFormatVersion)
        warnings << QStringLiteral("made for a newer format (v%1); unknown keys ignored").arg(version);

    static const QRegularExpression idRe(QStringLiteral("^[a-z0-9_-]+(\\.[a-z0-9_-]+)+$"));
    const QString id = doc.value("id").toString();
    if (!idRe.match(id).hasMatch() || id.size() > kMaxIdLength)
        errors << QStringLiteral("'id' must look like <author>.<name> using [a-z0-9_-], max %1 chars").arg(kMaxIdLength);
    else if (kBuiltinIds.contains(id))
        errors << QStringLiteral("'id' %1 is reserved").arg(id);

    const QString name = requireLabel(doc, "name", errors);
    const QString author = requireLabel(doc, "author", errors);

    const QString mode = doc.value("mode").toString();
    if (mode != QLatin1String("dark") && mode != QLatin1String("light"))
        errors << QStringLiteral("'mode' must be \"dark\" or \"light\"");

    return { { "id", id }, { "name", name }, { "author", author }, { "mode", mode } };
}

// Valid colours by token, plus derived ones. Bad entries are dropped with a warning.
QVariantMap readPalette(const QJsonObject& doc, QStringList& warnings)
{
    QVariantMap palette;
    const QJsonValue pv = doc.value("palette");
    if (!pv.isUndefined() && !pv.isObject())
        warnings << QStringLiteral("'palette' is not an object; ignored");
    const QJsonObject pobj = pv.toObject();
    const QStringList& tokens = paletteTokenList();
    for (auto it = pobj.begin(); it != pobj.end(); ++it) {
        if (!tokens.contains(it.key())) {
            warnings << QStringLiteral("unknown colour 'palette.%1' ignored").arg(it.key());
            continue;
        }
        QColor c;
        if (!it.value().isString() || !parseColor(it.value().toString(), &c)) {
            warnings << QStringLiteral("'palette.%1' is not #RRGGBB or #RRGGBBAA; ignored").arg(it.key());
            continue;
        }
        palette.insert(it.key(), c);
    }
    for (const Derived& d : kDerived) {
        const QString token = QLatin1String(d.token), source = QLatin1String(d.source);
        if (!palette.contains(token) && palette.contains(source)) {
            QColor c = palette.value(source).value<QColor>();
            c.setAlphaF(d.alpha);
            palette.insert(token, c);
        }
    }
    return palette;
}

void warnUnknownKeys(const QJsonObject& doc, QStringList& warnings)
{
    static const QSet<QString> known = {
        "$schema", "formatVersion", "id", "name", "author", "mode", "palette",
    };
    static const QSet<QString> notApplied = { "spacing", "radius", "typography" };
    for (const QString& key : doc.keys()) {
        if (notApplied.contains(key))
            warnings << QStringLiteral("'%1' isn't supported yet; ignored").arg(key);
        else if (!known.contains(key))
            warnings << QStringLiteral("unknown key '%1' ignored").arg(key);
    }
}

const QString kSettingsKey = QStringLiteral("LogosDesignSystem/theme");

} // namespace

Logos::ThemeStore* Logos::ThemeStore::instance()
{
    static ThemeStore* store = new ThemeStore;   // lives for the process
    return store;
}

Logos::ThemeStore::ThemeStore()
    : m_current(QSettings().value(kSettingsKey, QStringLiteral("dark")).toString())
{
}

QStringList Logos::ThemeStore::paletteTokens()
{
    return paletteTokenList();
}

void Logos::ThemeStore::addDirectory(const QString& dir)
{
    const QString clean = QDir::cleanPath(dir);
    if (!clean.isEmpty() && !m_dirs.contains(clean))
        m_dirs << clean;
    rescan();
}

bool Logos::ThemeStore::hasTheme(const QString& id) const
{
    if (kBuiltinIds.contains(id))
        return true;
    for (const QVariant& t : m_themes)
        if (t.toMap().value("id").toString() == id)
            return true;
    return false;
}

void Logos::ThemeStore::setCurrent(const QString& id)
{
    if (id == m_current || !hasTheme(id))
        return;
    m_current = id;
    QSettings().setValue(kSettingsKey, id);
    emit currentChanged();
}

void Logos::ThemeStore::rescan()
{
    QVariantList found;
    QSet<QString> seen;
    for (const QString& root : std::as_const(m_dirs)) {
        const QDir dir(root);
        if (!dir.exists())
            continue;
        const auto entries = dir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name);
        for (const QFileInfo& sub : entries) {
            const QFileInfo doc(sub.absoluteFilePath() + QStringLiteral("/theme.json"));
            // No symlinks: a theme may only read the file inside its own folder.
            if (sub.isSymLink() || doc.isSymLink() || !doc.isFile())
                continue;
            QFile f(doc.absoluteFilePath());
            if (doc.size() > maxDocumentBytes || !f.open(QIODevice::ReadOnly)) {
                qCWarning(lcTheme, "skipping %s (unreadable or larger than 64 KiB)",
                         qPrintable(doc.absoluteFilePath()));
                continue;
            }
            const QVariantMap result = parseDocument(f.read(maxDocumentBytes + 1));
            if (!result.value("ok").toBool()) {
                qCWarning(lcTheme, "rejected %s: %s", qPrintable(doc.absoluteFilePath()),
                         qPrintable(result.value("errors").toStringList().join(QStringLiteral("; "))));
                continue;
            }
            const QVariantMap theme = result.value("theme").toMap();
            const QString id = theme.value("id").toString();
            if (seen.contains(id)) {
                qCWarning(lcTheme, "duplicate theme id '%s' at %s ignored",
                         qPrintable(id), qPrintable(doc.absoluteFilePath()));
                continue;
            }
            seen.insert(id);
            found << theme;
        }
    }

    m_themes = found;
    emit themesChanged();
}

QVariantMap Logos::ThemeStore::parseDocument(const QByteArray& data)
{
    QStringList errors, warnings;
    auto result = [&](const QVariantMap& theme = {}) {
        return QVariantMap{
            { "ok", errors.isEmpty() }, { "errors", errors }, { "warnings", warnings },
            { "theme", errors.isEmpty() ? theme : QVariantMap{} },
        };
    };

    if (data.size() > maxDocumentBytes) {
        errors << QStringLiteral("document is larger than 64 KiB");
        return result();
    }
    QJsonParseError perr;
    const QJsonDocument jd = QJsonDocument::fromJson(data, &perr);
    if (perr.error != QJsonParseError::NoError)
        errors << QStringLiteral("invalid JSON: %1").arg(perr.errorString());
    else if (!jd.isObject())
        errors << QStringLiteral("document must be a JSON object");
    if (!errors.isEmpty())
        return result();

    const QJsonObject doc = jd.object();
    QVariantMap theme = readIdentity(doc, errors, warnings);
    warnUnknownKeys(doc, warnings);
    theme.insert("palette", readPalette(doc, warnings));
    return result(theme);
}
