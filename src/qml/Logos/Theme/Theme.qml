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
    readonly property Sizes size: Sizes {}
    readonly property ControlTokens controls: ControlTokens {
        size: theme.size
        spacing: theme.spacing
        density: theme.density
        touch: theme.touch
    }
    readonly property LayoutTokens layouts: LayoutTokens { size: theme.size }

    // ===== DENSITY =====
    // "compact", "comfortable" or "touch"; the host chooses it (ThemeManager).
    // Comfortable where there is no ThemeRegistry.
    readonly property string density: _hasRegistry ? ThemeRegistry.density : "comfortable"
    // Every tappable part is at least size.touchTarget each way: at touch
    // density, and in a phone-width view at any density.
    readonly property bool touch: density === "touch" || viewClass === "phone"

    // ===== WIDTH CLASSES =====
    // Layout follows the width of the app's own area, not the screen:
    // phone < 600 ≤ tablet < 840 ≤ desktop (Android's window size classes).
    readonly property var breakpoints: ({ tablet: 600, desktop: 840 })
    function windowClass(width) {
        return width < breakpoints.tablet ? "phone"
             : width < breakpoints.desktop ? "tablet" : "desktop"
    }
    // This engine's view width, kept up to date by the host
    // (ThemeManager::followViewWidth). Until it is set the view is a desktop one.
    property real viewWidth: 0
    readonly property string viewClass: viewWidth > 0 ? windowClass(viewWidth) : "desktop"
    // The side margin of a page that is `width` wide.
    function pageMargin(width) {
        const cls = windowClass(width)
        return cls === "phone" ? spacing.large : cls === "tablet" ? spacing.xlarge : spacing.xxlarge
    }
    
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
