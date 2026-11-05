pragma Singleton
import QtQuick

QtObject {
    id: theme
    
    // ===== RAW COLOR PALETTE (Design Tokens) =====
    // Single source of truth; passed to all themes
    readonly property ColorPalette colors: ColorPalette {}
    
    // ===== DESIGN TOKENS =====
    readonly property Spacing spacing: Spacing {}
    readonly property Typography typography: Typography {}
    
    // ===== THEME INSTANCES =====
    // Dark's colours in QML. The palette comes from ThemeStore (C++), whose
    // copy of Dark tst_ThemeRegistry holds equal to this one; this is the
    // palette only where there is no ThemeRegistry.
    property var darkTheme: DarkTheme { colors: theme.colors }

    // ThemeRegistry is C++, so it is missing when Logos.Theme is loaded from
    // the QML source tree (apps' scene tests do that). Then only Dark exists.
    readonly property bool _hasRegistry: typeof ThemeRegistry !== "undefined"

    // id -> { id, name, author, mode, builtin }
    readonly property var themeInfo: {
        var info = { "dark": { id: "dark", name: "Dark", author: "Logos", mode: "dark", builtin: true } }
        if (!_hasRegistry)
            return info
        var installed = ThemeRegistry.themes
        for (var i = 0; i < installed.length; ++i) {
            var t = installed[i]
            info[t.id] = { id: t.id, name: t.name, author: t.author, mode: t.mode, builtin: false }
        }
        return info
    }

    readonly property string currentTheme:
        _hasRegistry && themeInfo[ThemeRegistry.current] ? ThemeRegistry.current : "dark"

    // ===== CURRENT THEME (Semantic Palette) =====
    // ThemeStore resolves it (a theme's own colours, Dark's for the rest), so
    // a host painting in C++ gets the same colours. `colors` is kept on it
    // for apps that read Theme.palette.colors; Theme.colors is the same.
    readonly property var palette: {
        if (!_hasRegistry)
            return darkTheme
        // A copy: what C++ hands over is a wrapper that drops added keys.
        var p = Object.assign({}, ThemeRegistry.palette)
        p.colors = theme.colors
        return p
    }

    // ===== CONVENIENCE PROPERTIES =====
    readonly property bool isDark: themeInfo[currentTheme].mode === "dark"
    readonly property var themeNames: Object.keys(themeInfo)

    // Helper to check if a theme is available
    function isThemeAvailable(themeName) {
        return themeInfo.hasOwnProperty(themeName)
    }
}
