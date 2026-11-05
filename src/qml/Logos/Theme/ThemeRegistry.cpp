#include "ThemeRegistry.h"
#include "ThemeStore.h"

ThemeRegistry::ThemeRegistry(QObject* parent)
    : QObject(parent)
{
    auto* store = Logos::ThemeStore::instance();
    connect(store, &Logos::ThemeStore::themesChanged, this, &ThemeRegistry::themesChanged);
    connect(store, &Logos::ThemeStore::currentChanged, this, &ThemeRegistry::currentChanged);
    connect(store, &Logos::ThemeStore::paletteChanged, this, &ThemeRegistry::paletteChanged);
}

QVariantList ThemeRegistry::themes() const
{
    return Logos::ThemeStore::instance()->themes();
}

QStringList ThemeRegistry::paletteTokens() const
{
    return Logos::ThemeStore::paletteTokens();
}

QString ThemeRegistry::current() const
{
    return Logos::ThemeStore::instance()->current();
}

QVariantMap ThemeRegistry::palette() const
{
    return Logos::ThemeStore::instance()->palette();
}

QVariantMap ThemeRegistry::paletteOf(const QString& id) const
{
    return Logos::ThemeStore::instance()->palette(id);
}
