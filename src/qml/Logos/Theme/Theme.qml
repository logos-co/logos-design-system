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
        var installed = ThemeRegistry.themes
        for (var i = 0; i < installed.length; ++i) {
            var t = installed[i]
            info[t.id] = { id: t.id, name: t.name, author: t.author, mode: t.mode, builtin: false }
        }
        return info
    }

    // ===== AVAILABLE THEMES =====
    property var availableThemes: {
        var themes = { "dark": darkTheme }
        var installed = ThemeRegistry.themes
        for (var i = 0; i < installed.length; ++i)
            themes[installed[i].id] = _resolvePalette(installed[i])
        return themes
    }

    readonly property string currentTheme:
        availableThemes[ThemeRegistry.current] ? ThemeRegistry.current : "dark"

    // ===== CURRENT THEME (Semantic Palette) =====
    readonly property var palette: availableThemes[currentTheme]

    // ===== CONVENIENCE PROPERTIES =====
    readonly property bool isDark: themeInfo[currentTheme].mode === "dark"
    readonly property var themeNames: Object.keys(availableThemes)

    // Helper to check if a theme is available
    function isThemeAvailable(themeName) {
        return availableThemes.hasOwnProperty(themeName)
    }
}
