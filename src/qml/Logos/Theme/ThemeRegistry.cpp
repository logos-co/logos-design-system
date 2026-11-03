#include "ThemeRegistry.h"
#include "ThemeStore.h"

ThemeRegistry::ThemeRegistry(QObject* parent)
    : QObject(parent)
{
    auto* store = Logos::ThemeStore::instance();
    connect(store, &Logos::ThemeStore::themesChanged, this, &ThemeRegistry::themesChanged);
    connect(store, &Logos::ThemeStore::currentChanged, this, &ThemeRegistry::currentChanged);
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
