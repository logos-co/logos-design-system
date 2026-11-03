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
    // Currently available themes - created first
    property var darkTheme: DarkTheme { colors: theme.colors }
    // Add new theme instances here as needed

    // ThemeRegistry is C++, so it is missing when Logos.Theme is loaded from
    // the QML source tree (apps' scene tests do that). Then only Dark exists.
    readonly property bool _hasRegistry: typeof ThemeRegistry !== "undefined"

    // ===== INSTALLED THEMES =====
    // Data-only theme files found on disk (see ThemeStore.h). A colour a
    // theme leaves out comes from darkTheme.
    function _resolvePalette(entry) {
        var resolved = {}
        var tokens = ThemeRegistry.paletteTokens
        for (var i = 0; i < tokens.length; ++i) {
            var token = tokens[i]
            resolved[token] = entry.palette[token] !== undefined
                ? entry.palette[token] : darkTheme[token]
        }
        return resolved
    }

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
    // Only the current theme's colours are built, not every installed one's.
    readonly property var palette: {
        if (currentTheme === "dark")
            return darkTheme
        var installed = ThemeRegistry.themes
        for (var i = 0; i < installed.length; ++i)
            if (installed[i].id === currentTheme)
                return _resolvePalette(installed[i])
        return darkTheme
    }

    // ===== CONVENIENCE PROPERTIES =====
    readonly property bool isDark: themeInfo[currentTheme].mode === "dark"
    readonly property var themeNames: Object.keys(themeInfo)

    // Helper to check if a theme is available
    function isThemeAvailable(themeName) {
        return themeInfo.hasOwnProperty(themeName)
    }
}
