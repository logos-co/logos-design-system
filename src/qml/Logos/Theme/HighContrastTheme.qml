// The dark theme with stronger text and borders, for people who need more
// contrast: near-white text on black, light borders. Same names as DarkTheme.
import QtQuick

QtObject {
    property ColorPalette colors

    readonly property color background: "#000000"
    readonly property color backgroundSecondary: "#0A0A0A"
    readonly property color backgroundTertiary: "#0A0A0A"
    readonly property color backgroundElevated: colors.gray950
    readonly property color backgroundMuted: colors.gray550Opacity07
    readonly property color backgroundBlack: colors.black
    readonly property color backgroundInset: "#000000"
    readonly property color backgroundButton: colors.gray340
    readonly property color surface: "#1A1A1A"
    readonly property color surfaceRaised: "#111111"
    readonly property color surfaceInteractiveHover: colors.gray300
    readonly property color surfaceRecessed: colors.gray370
    readonly property color surfaceContrast: colors.gray355

    readonly property color text: colors.white
    readonly property color textSecondary: "#EDEDED"
    readonly property color textSubtle: "#E0E0E0"
    readonly property color textTertiary: "#D4D4D4"
    readonly property color textPlaceholder: "#BDBDBD"
    readonly property color textMuted: "#B0B0B0"

    readonly property color border: "#A0A0A0"
    readonly property color borderSecondary: "#8C8C8C"
    readonly property color borderTertiary: "#BDBDBD"
    readonly property color borderTertiaryMuted: Qt.rgba(borderTertiary.r, borderTertiary.g, borderTertiary.b, 0.2)
    readonly property color borderSubtle: "#8C8C8C"
    readonly property color borderHairline: "#6E6E6E"
    readonly property color borderGlyph: "#8C8C8C"
    readonly property color borderInteractive: "#B0B0B0"
    readonly property color borderDark: "#8C8C8C"
    readonly property color borderStrong: "#D0D0D0"

    readonly property color primary: colors.orange300
    readonly property color primaryHover: colors.orange500
    readonly property color primaryPressed: colors.orange800
    readonly property color primarySoft: colors.peach100

    readonly property color success: colors.green500
    readonly property color successHover: colors.green400
    readonly property color successPressed: colors.green600
    readonly property color successBorder: colors.green500Opacity40

    readonly property color error: colors.red500
    readonly property color errorHover: colors.red400
    readonly property color errorPressed: colors.red600
    readonly property color errorBorder: colors.red500Opacity40

    readonly property color warning: colors.yellow400
    readonly property color warningHover: colors.yellow500
    readonly property color warningBorder: colors.yellow400Opacity40

    readonly property color info: colors.blue400
    readonly property color primaryBorder: Qt.rgba(primary.r, primary.g, primary.b, 0.4)

    readonly property color notification: colors.red500
    readonly property color accentOrange: colors.orange300
    readonly property color accentOrangeMid: colors.orange350
    readonly property color accentOrangeDeep: colors.orange450
    readonly property color accentBurntOrange: colors.orange700
    readonly property color accentYellowSoft: colors.yellow300

    readonly property color hover: colors.gray700
    readonly property color pressed: colors.gray850
    readonly property color disabled: "#A8A8A8"
    readonly property color focus: colors.yellow400

    readonly property color glassOverlay: colors.gray550Opacity07
    readonly property color glassStrong: colors.gray550Opacity30
    readonly property color overlayDark: Qt.rgba(colors.gray875.r, colors.gray875.g, colors.gray875.b, 0.3)
    readonly property color overlayLight: colors.whiteOpacity06
    readonly property color overlayOrange: colors.orange400Opacity30
    readonly property color scrim: colors.blackOpacity50
}
