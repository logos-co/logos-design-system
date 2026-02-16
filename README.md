# Logos Design System

A comprehensive QML design system for Logos applications, providing theming, colors, spacing, and typography.

## Theme (`Logos.Theme`)

- 🎨 **Dark Theme** - Built-in dark theme with runtime extensibility
- 🎯 **Design Tokens** - Single source of truth for colors via ColorPalette
- 📐 **Spacing System** - Consistent spacing scale (4px to 40px)
- ✍️ **Typography** - Predefined text styles and font sizes
- 🔌 **Extensible** - Apps can add custom themes easily
- 💾 **Persistent** - Theme preference saved via Qt.labs.settings
- ⚡ **Fast** - Themes loaded at startup, instant switching

## Controls (`Logos.Controls`)

- 🧩 **Reusable components** - Themed UI controls that use Logos.Theme (e.g. LogosButton)
- Import `Logos.Controls` in your QML to use buttons and other controls

## How to Build

### Using Nix (Recommended)

#### Build the QML Module

```bash
# Build everything (default)
nix build

# Or explicitly
nix build '.#default'
```

The result will include:
- `lib/Logos/DesignSystem/` (QML module with `qmldir` + QML files)

#### Development Shell

```bash
# Enter development shell with all dependencies
nix develop
```

**Note:** In zsh, you need to quote the target (e.g., `'.#default'`) to prevent glob expansion.

If you don't have flakes enabled globally, add experimental flags:

```bash
nix build --extra-experimental-features 'nix-command flakes'
```

The compiled artifacts can be found at `result/`

## Usage

### 1. Ensure QML Import Path

Make sure the module install path (e.g. `result/lib`) is on your QML import path:

```cpp
engine.addImportPath("path/to/result/lib");
```

### 2. Import in QML

```qml
import QtQuick
import QtQuick.Controls
import Logos.Theme 1.0
import Logos.Controls 1.0

Rectangle {
    color: Theme.palette.background

    LogosText {
        text: "Hello World"
    }
}
```

## Requirements

- Qt 6.x
- CMake 3.16+
- C++17 compiler

## Contributing

Contributions welcome! Please ensure:
- New colors are added to ColorPalette first
- Both DarkTheme and LightTheme are updated
- Semantic naming is maintained
- Examples are provided for new features
