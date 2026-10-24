// Day: the light theme. Paper-white content on a sand frame, near-black ink,
// and one accent, Logos orange darkened to read as text on white (4.9:1).
// Same names as DarkTheme.
import QtQuick

QtObject {
    property ColorPalette colors

    readonly property color background: "#FBFAF7"
    readonly property color backgroundSecondary: "#F1EDE4"
    readonly property color backgroundTertiary: "#E9E4D8"
    readonly property color backgroundElevated: "#FFFFFF"
    readonly property color backgroundMuted: Qt.rgba(0.11, 0.1, 0.09, 0.04)
    readonly property color backgroundBlack: "#EFEBE2"
    readonly property color backgroundInset: "#F5F2EB"
    readonly property color backgroundButton: "#E8E2D6"
    readonly property color surface: "#FFFFFF"
    readonly property color surfaceRaised: "#FFFFFF"
    readonly property color surfaceInteractiveHover: "#F4EFE6"
    readonly property color surfaceRecessed: "#F5F2EB"
    readonly property color surfaceContrast: "#D9D2C4"

    readonly property color text: "#1B1A17"
    readonly property color textSecondary: "#55514A"
    readonly property color textSubtle: "#5E5A52"
    readonly property color textTertiary: "#6E695F"
    readonly property color textPlaceholder: "#9A9488"
    readonly property color textMuted: "#A8A296"

    readonly property color border: "#DED8CC"
    readonly property color borderSecondary: "#E6E1D6"
    readonly property color borderTertiary: "#B8B1A3"
    readonly property color borderTertiaryMuted: Qt.rgba(borderTertiary.r, borderTertiary.g, borderTertiary.b, 0.2)
    readonly property color borderSubtle: "#E9E4DA"
    readonly property color borderHairline: Qt.rgba(0.11, 0.1, 0.09, 0.08)
    readonly property color borderGlyph: Qt.rgba(0.11, 0.1, 0.09, 0.2)
    readonly property color borderInteractive: "#CFC8BA"
    readonly property color borderDark: "#C4BCAD"
    readonly property color borderStrong: "#A39B8C"

    readonly property color primary: "#C8460F"
    readonly property color primaryHover: "#A93A0C"
    readonly property color primaryPressed: "#8C300A"
    readonly property color primarySoft: "#FBE6DA"

    readonly property color success: "#2E7D32"
    readonly property color successHover: "#256B29"
    readonly property color successPressed: "#1C5520"
    readonly property color successBorder: colors.green500Opacity40

    readonly property color error: "#C62828"
    readonly property color errorHover: "#A82121"
    readonly property color errorPressed: "#8A1B1B"
    readonly property color errorBorder: colors.red500Opacity40

    readonly property color warning: "#A15C00"
    readonly property color warningHover: "#844B00"
    readonly property color warningBorder: colors.yellow400Opacity40

    readonly property color info: "#2563C9"
    readonly property color primaryBorder: Qt.rgba(primary.r, primary.g, primary.b, 0.4)

    readonly property color notification: colors.red500
    readonly property color accentOrange: "#C8460F"
    readonly property color accentOrangeMid: "#D9531A"
    readonly property color accentOrangeDeep: "#A93A0C"
    readonly property color accentBurntOrange: "#8C300A"
    readonly property color accentYellowSoft: "#8A6A00"

    readonly property color hover: Qt.rgba(0.11, 0.1, 0.09, 0.05)
    readonly property color pressed: Qt.rgba(0.11, 0.1, 0.09, 0.09)
    readonly property color disabled: "#B3AC9F"
    readonly property color focus: "#C8460F"

    readonly property color glassOverlay: Qt.rgba(0.11, 0.1, 0.09, 0.03)
    readonly property color glassStrong: Qt.rgba(0.11, 0.1, 0.09, 0.1)
    readonly property color overlayDark: Qt.rgba(0.11, 0.1, 0.09, 0.06)
    readonly property color overlayLight: Qt.rgba(0.11, 0.1, 0.09, 0.03)
    readonly property color overlayOrange: Qt.rgba(0.78, 0.27, 0.06, 0.14)
    readonly property color scrim: Qt.rgba(0.11, 0.1, 0.09, 0.35)
}
