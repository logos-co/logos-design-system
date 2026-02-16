pragma Singleton
import QtQuick
import QtCore

QtObject {
    id: theme
    
    // ===== SETTINGS PERSISTENCE =====
    property Settings settings: Settings {
        category: "LogosDesignSystem"
        property string theme: "dark"
    }
    
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
    
    // ===== AVAILABLE THEMES =====
    // Add new themes here as needed - defined after theme instances
    property var availableThemes: ({
        "dark": darkTheme
        // Add more themes here:
        // "light": lightTheme,
        // "custom": customTheme
    })
    
    // ===== CURRENT THEME (Semantic Palette) =====
    // Returns the current theme palette based on settings
    readonly property var palette: {
        if (settings && settings.theme && availableThemes[settings.theme]) {
            return availableThemes[settings.theme]
        }
        return darkTheme
    }
    
    // ===== CONVENIENCE PROPERTIES =====
    readonly property bool isDark: settings.theme === "dark"
    readonly property string currentTheme: settings.theme
    readonly property var themeNames: Object.keys(availableThemes)
    
    // ===== METHODS =====
    function switchTheme() {
        // Cycle through available themes
        var themes = Object.keys(availableThemes)
        var currentIndex = themes.indexOf(settings.theme)
        var nextIndex = (currentIndex + 1) % themes.length
        settings.theme = themes[nextIndex]
        console.log("Theme switched to:", settings.theme)
    }
    
    function setTheme(themeName) {
        if (!availableThemes[themeName]) {
            console.warn("Invalid theme:", themeName, ". Available themes:", Object.keys(availableThemes))
            return
        }
        settings.theme = themeName
        console.log("Theme set to:", settings.theme)
    }
    
    function setDark() {
        setTheme("dark")
    }
    
    // Helper to check if a theme is available
    function isThemeAvailable(themeName) {
        return availableThemes.hasOwnProperty(themeName)
    }
}
