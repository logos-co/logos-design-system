# Theme files

A theme is one JSON file, `theme.json`, that recolours anything drawn with
`Theme.palette.*`. It is data only: `ThemeRegistry` parses it in C++ against a
whitelist, and nothing in it is ever evaluated as QML or JavaScript.

```json
{
  "formatVersion": 1,
  "id": "yourname.sunset",
  "name": "Sunset",
  "author": "yourname",
  "mode": "light",
  "palette": {
    "background": "#FAF7F2",
    "text": "#1F1A15",
    "primary": "#C9512C"
  }
}
```

| Field | Rule |
|---|---|
| `formatVersion` | Required. `1`. A newer version still loads, reading the keys this one knows. |
| `id` | Required. `<author>.<name>`, lowercase `a-z 0-9 _ -`, at least one dot, up to 64 characters. `dark` is reserved. Installing a file with an existing `id` replaces it. |
| `name`, `author` | Required. 1 to 40 characters, without `<`, `>`, `&` or control characters. |
| `mode` | Required. `"dark"` or `"light"`; read by `Theme.isDark`. |
| `palette` | Optional. Any of the names in `DarkTheme.qml` (`ThemeRegistry.paletteTokens`), each `"#RRGGBB"` or `"#RRGGBBAA"` (alpha last). |

- A colour the theme leaves out, or gets wrong, comes from Dark. Only a bad
  required field rejects the whole file.
- `primaryBorder` and `borderTertiaryMuted` follow `primary` and
  `borderTertiary` unless the theme sets them.
- `spacing`, `radius` and `typography` are accepted but not applied yet.
  Other unknown keys are ignored with a warning.
- Files are limited to 64 KiB.

## Where themes live

The host decides. At startup it hands its themes directory to the
process-wide store; nothing is read until it does:

```cpp
#include <ThemeStore.h>
#include <ThemeInstaller.h>

const QString dir = /* e.g. <app data>/themes */;
Logos::ThemeStore::instance()->addDirectory(dir);
auto* installer = new Logos::ThemeInstaller(dir, this);
```

The store reads `<dir>/<any-name>/theme.json`, skipping symlinked folders and
files; for a repeated `id` the directory added first wins.

`installer->install(url)` validates a local file and copies it to
`<dir>/<id>/theme.json`; the store lists it at once. The installer is not a
QML type: the host hands it to its own UI only (Basecamp sets it as a context
property on its Settings view), so apps can read and switch themes but can't
install one.

## Switching

`Theme.setTheme(id)` switches every QML engine in the process; the store
saves the choice in the `LogosDesignSystem/theme` setting. `Theme.themeNames` lists Dark plus every installed theme, and
`Theme.themeInfo[id]` gives its `name`, `author` and `mode`.
