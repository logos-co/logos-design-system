pragma Singleton
import QtQuick

QtObject {
    id: theme
    
    // ===== RAW COLOR PALETTE (Design Tokens) =====
    // Single source of truth; passed to all themes
    readonly property ColorPalette colors: ColorPalette {}
    
    // ===== DESIGN TOKENS =====
    readonly property Spacing spacing: Spacing {}
    readonly property Typography typography: Typography {
        phone: theme.viewClass === "phone"
        touch: theme.touch
    }
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

    // ===== WHAT COVERS THE WINDOW'S EDGES =====
    // The phone's safe area (notch, home indicator), kept up to date by the
    // host (ThemeManager::followViewWidth, Qt 6.9 and later), and the on-screen
    // keyboard. 0 on a desktop.
    property real safeAreaTop: 0
    property real safeAreaBottom: 0
    property real keyboardHeight: Qt.inputMethod.visible ? Qt.inputMethod.keyboardRectangle.height : 0
    // How much of `item`'s top or bottom they cover, from where it is in its
    // window: 0 for an item away from the edge.
    function topInset(item) {
        if (!item || !item.Window.window)
            return 0
        return Math.max(0, safeAreaTop - item.mapToItem(null, 0, 0).y)
    }
    function bottomInset(item) {
        return Math.max(keyboardInset(item), _below(item, safeAreaBottom))
    }
    // The keyboard's part of bottomInset: what is to be lifted above it.
    function keyboardInset(item) {
        return _below(item, keyboardHeight)
    }
    function _below(item, cover) {
        const window = item ? item.Window.window : null
        if (!window)
            return 0
        return Math.max(0, cover - (window.height - item.mapToItem(null, 0, item.height).y))
    }
    // Scrolls the Flickable that holds `item` so the item shows clear of the
    // keyboard: for the field with focus, if it is inside `within`.
    function scrollIntoView(item, within) {
        let inside = item
        while (inside && inside !== within)
            inside = inside.parent
        let flick = inside ? item.parent : null
        while (flick && !(flick instanceof Flickable))
            flick = flick.parent
        if (!flick)
            return
        const top = item.mapToItem(flick.contentItem, 0, 0).y - spacing.medium
        const bottom = top + item.height + 2 * spacing.medium
        const shown = flick.height - keyboardInset(flick)
        if (top < flick.contentY)
            flick.contentY = Math.max(0, top)
        else if (bottom > flick.contentY + shown)
            flick.contentY = Math.min(bottom - shown, Math.max(0, flick.contentHeight - flick.height))
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
