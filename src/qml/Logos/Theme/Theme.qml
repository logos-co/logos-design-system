pragma Singleton
import QtQuick
import QtCore

QtObject {
    id: theme
    
    // ===== SETTINGS PERSISTENCE =====
    // One file for every window and app process, so a change made anywhere
    // (the View menu, Settings, an app) reaches all of them within a second.
    property Settings settings: Settings {
        location: StandardPaths.writableLocation(StandardPaths.GenericConfigLocation) + "/Logos/design-system.ini"
        category: "LogosDesignSystem"
        property string theme: "dark"
        // Text size multiplier (0.85 to 1.6), set with setTextScale.
        property real textScale: 1.0
    }

    // Other processes write the same file: pick their changes up.
    property Timer settingsWatch: Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            theme.settings.sync()
            var name = String(theme.settings.value("theme", "dark"))
            if (name !== theme.settings.theme && theme.availableThemes[name]) theme.settings.theme = name
            var scale = Number(theme.settings.value("textScale", 1.0))
            if (!isNaN(scale) && Math.abs(scale - theme.settings.textScale) > 0.001) theme.settings.textScale = scale
        }
    }

    // ===== RAW COLOR PALETTE (Design Tokens) =====
    // Single source of truth; passed to all themes
    readonly property ColorPalette colors: ColorPalette {}
    
    // ===== DESIGN TOKENS =====
    readonly property Spacing spacing: Spacing {}
    readonly property Typography typography: Typography { scale: theme.settings.textScale }
    
    // ===== THEME INSTANCES =====
    // Currently available themes - created first
    property var darkTheme: DarkTheme { colors: theme.colors }
    property var highContrastTheme: HighContrastTheme { colors: theme.colors }
    property var lightTheme: LightTheme { colors: theme.colors }
    // Add new theme instances here as needed
    
    // ===== AVAILABLE THEMES =====
    // Add new themes here as needed - defined after theme instances
    property var availableThemes: ({
        "dark": darkTheme,
        "light": lightTheme,
        "high-contrast": highContrastTheme
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
    readonly property bool isDark: settings.theme !== "light"
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
        settings.setValue("theme", themeName)   // at once, so the watch never reads the old one
        settings.theme = themeName
        settings.sync()
    }
    
    function setDark() {
        setTheme("dark")
    }
    
    // Text size: 1.0 is the design's own; clamped to 0.85-1.6.
    readonly property real textScale: settings.textScale
    function setTextScale(scale) {
        var value = Math.round(Math.max(0.85, Math.min(1.6, scale)) * 100) / 100
        settings.setValue("textScale", value)   // at once, so the watch never reads the old one
        settings.textScale = value
        settings.sync()
    }
    function biggerText() { setTextScale(textScale + 0.1) }
    function smallerText() { setTextScale(textScale - 0.1) }
    function actualSizeText() { setTextScale(1.0) }

    // Helper to check if a theme is available
    function isThemeAvailable(themeName) {
        return availableThemes.hasOwnProperty(themeName)
    }
}
