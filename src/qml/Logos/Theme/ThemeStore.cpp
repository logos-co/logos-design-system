#include "ThemeStore.h"

#include <QColor>
#include <QCoreApplication>
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

#include <cmath>

Q_LOGGING_CATEGORY(lcTheme, "logos.theme")

namespace {

constexpr int kFormatVersion = 1;
constexpr int kMaxLabelLength = 40;
constexpr int kMaxIdLength = 64;

const QStringList kBuiltinIds = { QStringLiteral("dark") };

// Dark, the built-in theme, and with it the colours a theme may set. Each is
// DarkTheme.qml's value, which tst_ThemeRegistry checks: hex plus alpha, so
// an alpha like 0.07 stays exact rather than rounding to 8 bits.
struct DarkColour { const char* token; const char* hex; double alpha; };
const DarkColour kDark[] = {
    { "background", "#171717", 1 },
    { "backgroundSecondary", "#262626", 1 },
    { "backgroundTertiary", "#1C1C1C", 1 },
    { "backgroundElevated", "#0E121B", 1 },
    { "backgroundMuted", "#808080", 0.07 },
    { "backgroundBlack", "#000000", 1 },
    { "backgroundInset", "#141414", 1 },
    { "backgroundButton", "#2F2F2F", 1 },
    { "surface", "#343434", 1 },
    { "surfaceRaised", "#232323", 1 },
    { "surfaceInteractiveHover", "#434343", 1 },
    { "surfaceRecessed", "#1F1F1F", 1 },
    { "surfaceContrast", "#595959", 1 },
    { "text", "#FFFFFF", 1 },
    { "textSecondary", "#A4A4A4", 1 },
    { "textSubtle", "#A9A9A9", 1 },
    { "textTertiary", "#969696", 1 },
    { "textPlaceholder", "#717784", 1 },
    { "textMuted", "#5C5C5C", 1 },
    { "border", "#434343", 1 },
    { "borderSecondary", "#2B303B", 1 },
    { "borderTertiary", "#969696", 1 },
    { "borderTertiaryMuted", "#969696", 0.2 },
    { "borderSubtle", "#333333", 1 },
    { "borderHairline", "#808080", 0.2 },
    { "borderGlyph", "#969696", 0.35 },
    { "borderInteractive", "#434343", 1 },
    { "borderDark", "#2F2F2F", 1 },
    { "borderStrong", "#515151", 1 },
    { "primary", "#ED7B58", 1 },
    { "primaryHover", "#F55702", 1 },
    { "primaryPressed", "#8F3C03", 1 },
    { "primarySoft", "#FFD5C0", 1 },
    { "primaryForeground", "#FFFFFF", 1 },
    { "success", "#49F563", 1 },
    { "successHover", "#6CCC93", 1 },
    { "successPressed", "#19C332", 1 },
    { "successBorder", "#49F563", 0.4 },
    { "error", "#FB3748", 1 },
    { "errorHover", "#FF736A", 1 },
    { "errorPressed", "#F44336", 1 },
    { "errorBorder", "#FB3748", 0.4 },
    { "warning", "#FEBC2E", 1 },
    { "warningHover", "#FFA726", 1 },
    { "warningBorder", "#FEBC2E", 0.4 },
    { "info", "#4A90E2", 1 },
    { "primaryBorder", "#ED7B58", 0.4 },
    { "notification", "#FB3748", 1 },
    { "accentOrange", "#ED7B58", 1 },
    { "accentOrangeMid", "#FF6F42", 1 },
    { "accentOrangeDeep", "#FF4911", 1 },
    { "accentBurntOrange", "#BF5104", 1 },
    { "accentYellowSoft", "#EEF083", 1 },
    { "hover", "#5C5C5C", 1 },
    { "pressed", "#262626", 1 },
    { "disabled", "#969696", 1 },
    { "focus", "#FF8800", 1 },
    { "glassOverlay", "#808080", 0.07 },
    { "glassStrong", "#808080", 0.3 },
    { "overlayDark", "#1C1C1C", 0.3 },
    { "overlayLight", "#FFFFFF", 0.06 },
    { "overlayOrange", "#FF8800", 0.3 },
    { "scrim", "#000000", 0.5 },
};

const QVariantMap& darkPalette()
{
    static const QVariantMap v = [] {
        QVariantMap m;
        for (const DarkColour& d : kDark) {
            QColor c(QLatin1String(d.hex));
            c.setAlphaF(d.alpha);
            m.insert(QLatin1String(d.token), c);
        }
        return m;
    }();
    return v;
}

const QStringList& paletteTokenList()
{
    static const QStringList v = [] {
        QStringList l;
        for (const DarkColour& d : kDark)
            l << QLatin1String(d.token);
        return l;
    }();
    return v;
}

// Colours DarkTheme.qml derives from another one. A theme that sets the
// source but not the derived colour gets it re-derived, not dark's.
struct Derived { const char* token; const char* source; double alpha; };
const Derived kDerived[] = {
    { "primaryBorder", "primary", 0.4 },
    { "borderTertiaryMuted", "borderTertiary", 0.2 },
};

// Black or white, whichever reads better on `background` (WCAG contrast).
QColor readableOn(const QColor& background)
{
    auto linear = [](double c) {
        return c <= 0.03928 ? c / 12.92 : std::pow((c + 0.055) / 1.055, 2.4);
    };
    const double l = 0.2126 * linear(background.redF()) + 0.7152 * linear(background.greenF())
                   + 0.0722 * linear(background.blueF());
    // Contrast with black is (l + 0.05) / 0.05, with white 1.05 / (l + 0.05).
    return (l + 0.05) * (l + 0.05) > 0.05 * 1.05 ? QColor(Qt::black) : QColor(Qt::white);
}

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
    const double raw = fv.toDouble();
    const int version = fv.isDouble() && raw >= 1 && raw <= 1000 && raw == std::floor(raw)
                        ? int(raw) : 0;
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

// Valid colours by token, plus derived ones. A bad value for a known colour is
// an error when strict (installing), else dropped with a warning; unknown
// names are always warnings, so a newer theme still installs.
QVariantMap readPalette(const QJsonObject& doc, bool strict, QStringList& errors,
                        QStringList& warnings)
{
    QVariantMap palette;
    const QJsonValue pv = doc.value("palette");
    if (!pv.isUndefined() && !pv.isObject()) {
        if (strict)
            errors << QStringLiteral("'palette' is not an object");
        else
            warnings << QStringLiteral("'palette' is not an object; ignored");
    }
    const QJsonObject pobj = pv.toObject();
    const QStringList& tokens = paletteTokenList();
    for (auto it = pobj.begin(); it != pobj.end(); ++it) {
        if (!tokens.contains(it.key())) {
            warnings << QStringLiteral("unknown colour 'palette.%1' ignored").arg(it.key());
            continue;
        }
        QColor c;
        if (!it.value().isString() || !parseColor(it.value().toString(), &c)) {
            const QString msg = QStringLiteral("'palette.%1' is not #RRGGBB or #RRGGBBAA").arg(it.key());
            (strict ? errors : warnings) << (strict ? msg : msg + QStringLiteral("; ignored"));
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
    // Dark's white would be unreadable on a light primary.
    if (!palette.contains("primaryForeground") && palette.contains("primary"))
        palette.insert("primaryForeground", readableOn(palette.value("primary").value<QColor>()));
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

const QString kChoiceKey = QStringLiteral("theme");

} // namespace

Logos::ThemeStore* Logos::ThemeStore::instance()
{
    static ThemeStore* store = new ThemeStore;   // lives for the process
    // A second copy of the design system in the process would have its own
    // store, and its views would stop following theme changes. Checked once an
    // application exists, which may be after the first call.
    static bool registered = false;
    if (!registered) {
        if (auto* app = QCoreApplication::instance()) {
            registered = true;
            const QVariant other = app->property("_logos_theme_store");
            if (other.isValid() && other.value<QObject*>() != store)
                qCCritical(lcTheme, "two copies of the Logos design system are linked into this "
                                    "process; link it once, or themes will not stay in step");
            else
                app->setProperty("_logos_theme_store", QVariant::fromValue<QObject*>(store));
        }
    }
    return store;
}

Logos::ThemeStore::ThemeStore()
    : m_saved(QStringLiteral("dark"))
    , m_palette(darkPalette())
{
}

void Logos::ThemeStore::settle(const QString& shownBefore)
{
    if (current() != shownBefore)
        emit currentChanged();
    const QVariantMap now = palette(current());
    if (now != m_palette) {
        m_palette = now;
        emit paletteChanged();
    }
}

QVariantMap Logos::ThemeStore::palette(const QString& id) const
{
    QVariantMap resolved = darkPalette();
    for (const QVariant& t : m_themes) {
        const QVariantMap theme = t.toMap();
        if (theme.value("id").toString() != id)
            continue;
        const QVariantMap own = theme.value("palette").toMap();
        for (auto it = own.cbegin(); it != own.cend(); ++it)
            resolved.insert(it.key(), it.value());
        break;
    }
    return resolved;
}

void Logos::ThemeStore::setChoiceFile(const QString& path)
{
    if (path == m_choiceFile)
        return;
    const QString shownBefore = current();
    m_choiceFile = path;
    m_saved = path.isEmpty()
        ? QStringLiteral("dark")
        : QSettings(path, QSettings::IniFormat).value(kChoiceKey, QStringLiteral("dark")).toString();
    settle(shownBefore);
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

QString Logos::ThemeStore::current() const
{
    return hasTheme(m_saved) ? m_saved : QStringLiteral("dark");
}

QString Logos::ThemeStore::directoryOf(const QString& id) const
{
    return m_sources.value(id);
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

bool Logos::ThemeStore::setCurrent(const QString& id)
{
    if (!hasTheme(id))
        return false;
    const QString shownBefore = current();
    m_saved = id;
    if (!m_choiceFile.isEmpty()) {
        QSettings settings(m_choiceFile, QSettings::IniFormat);
        settings.setValue(kChoiceKey, id);
        settings.sync();
        // Still switched for this run; it just won't survive a restart.
        if (settings.status() != QSettings::NoError)
            qCWarning(lcTheme, "couldn't save the theme choice to %s", qPrintable(m_choiceFile));
    }
    settle(shownBefore);
    return true;
}

void Logos::ThemeStore::rescan()
{
    const QString shownBefore = current();
    QVariantList found;
    QHash<QString, QString> sources;
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
            // <dir>/<id>/ only: installing and removing address a theme by id.
            if (sub.fileName() != id) {
                qCWarning(lcTheme, "skipping %s: its folder must be named after its id '%s'",
                         qPrintable(doc.absoluteFilePath()), qPrintable(id));
                continue;
            }
            if (sources.contains(id)) {
                qCWarning(lcTheme, "duplicate theme id '%s' at %s ignored",
                         qPrintable(id), qPrintable(doc.absoluteFilePath()));
                continue;
            }
            sources.insert(id, root);
            found << theme;
        }
    }

    m_themes = found;
    m_sources = sources;
    emit themesChanged();
    settle(shownBefore);
}

QVariantMap Logos::ThemeStore::parseDocument(const QByteArray& data, Validation validation)
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
    const QVariantMap palette = readPalette(doc, validation == Validation::Strict,
                                            errors, warnings);
    // Gaps are filled from Dark, which would be unreadable in a light theme.
    if (theme.value("mode") == QLatin1String("light")) {
        QStringList missing;
        for (const QString& token : paletteTokenList())
            if (!palette.contains(token))
                missing << token;
        if (!missing.isEmpty())
            errors << QStringLiteral("a light theme must set every colour; missing: %1")
                          .arg(missing.join(QStringLiteral(", ")));
    }
    theme.insert("palette", palette);
    return result(theme);
}
