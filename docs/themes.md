# Theme files

A theme is one JSON file, `theme.json`, that recolours anything drawn with
`Theme.palette.*`. It is data only: `ThemeStore` parses it in C++ against a
whitelist, and nothing in it is ever evaluated as QML or JavaScript.

```json
{
  "formatVersion": 1,
  "id": "yourname.ocean",
  "name": "Ocean",
  "author": "yourname",
  "mode": "dark",
  "palette": {
    "background": "#0B1E2D",
    "text": "#E6F1FA",
    "primary": "#14786E"
  }
}
```

| Field | Rule |
|---|---|
| `formatVersion` | Required. The whole number `1`. A newer version still loads, reading the keys this one knows. |
| `id` | Required. `<author>.<name>`, lowercase `a-z 0-9 _ -`, at least one dot, up to 64 characters. `dark` is reserved. |
| `name`, `author` | Required. 1 to 40 characters, without `<`, `>`, `&` or control characters. |
| `mode` | Required. `"dark"` or `"light"`; read by `Theme.isDark`. |
| `palette` | Any of Dark's colour names (`ThemeRegistry.paletteTokens`), each `"#RRGGBB"` or `"#RRGGBBAA"` (alpha last). |

- A dark theme may set only some colours; the rest come from Dark.
- A light theme must set every colour, since Dark's would not fit it.
  `primaryBorder` and `borderTertiaryMuted` can be left out: unless set, they
  follow `primary` and `borderTertiary`.
- `primaryForeground` is the colour of text and icons on `primary` (a primary
  button's label, a checkmark). Unless set, a theme that sets `primary` gets
  black or white, whichever reads better on it.
- Installing is strict: a bad value for a known colour fails it. A file that
  is already installed loads leniently: such a colour is dropped with a
  warning and comes from Dark.
- Unknown colour names and keys are ignored with a warning, so a theme made
  for a newer format still installs. `spacing`, `radius` and `typography` are
  accepted but not applied yet.
- Files are limited to 64 KiB.

## Hosting themes

Themes are the host's business; QML can read them but not change them. The
host creates one `Logos::ThemeManager` with its themes directory and gives it
to its own UI only. Basecamp sets it as a context property on its Settings
view; apps' views import `Logos.Theme` too, but never get it.

```cpp
#include <ThemeManager.h>

auto* themes = new Logos::ThemeManager(/* absolute, e.g. <app data>/themes */, this);
view->rootContext()->setContextProperty("themeManager", themes);
```

- `themes->install(url)` validates a local file and copies it to
  `<dir>/<id>/theme.json`, replacing a theme with that id installed there.
  It refuses an id another theme directory already provides, since that copy
  would keep being shown. The theme is listed at once.
- `themes->remove(id)` deletes a theme installed in `<dir>`; themes from other
  directories and Dark can't be removed. Removing the current theme switches
  to Dark.
- `themes->select(id)` switches every QML engine in the process and saves the
  choice in `<dir>/theme.ini` (a failed save is logged; the switch still holds
  until restart), so an isolated instance with its own directory
  keeps its own choice.

`Logos::ThemeStore` holds the themes and the current one once per process.
More directories can be added with `ThemeStore::instance()->addDirectory()`;
for a repeated id the directory added first wins. Each theme lives in a folder
named after its id, `<dir>/<id>/theme.json`; other folders, and symlinked
folders and files, are skipped.

### Reading colours in C++

Widget chrome QML doesn't draw (QSS, `QPalette`, a `QQuickWidget`'s clear
colour) reads the same colours as `Theme.palette`, from the store:

```cpp
#include <ThemeStore.h>

auto* store = Logos::ThemeStore::instance();
auto apply = [w, store] { w->setClearColor(store->color("background")); };
apply();
QObject::connect(store, &Logos::ThemeStore::paletteChanged, w, apply);
```

- `color(token)` is the current theme's colour, Dark's where the theme leaves
  it out; invalid for an unknown token. `palette()` is all of them.
- `palette(id)` resolves any theme the same way, current or not.
- `paletteChanged()` fires on a switch and when the current theme is
  reinstalled with other colours.

Link the design system once per process: a second copy has its own store, so
its views would not follow theme changes. The store detects that and logs a
critical `logos.theme` error.

## Reading the theme in QML

- `Theme.palette` is the current theme's colours; `Theme.currentTheme` its id.
  It is resolved by `ThemeStore`, so it always matches C++'s `color()`.
  Raw colours are `Theme.colors` (`Theme.palette.colors` is the same).
- `ThemeRegistry.paletteOf(id)` is a theme's colours without switching to it,
  for previews.
- `Theme.themeNames` lists Dark plus every installed theme, and
  `Theme.themeInfo[id]` gives its `name`, `author` and `mode`.
- If the saved theme is no longer installed, Dark is shown; the choice is
  kept, so the theme comes back with its file.
