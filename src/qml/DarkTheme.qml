import QtQuick

QtObject {
    property ColorPalette colors

    readonly property color background: colors.gray900
    readonly property color backgroundSecondary: colors.gray850
    readonly property color backgroundTertiary: colors.gray875
    readonly property color backgroundElevated: colors.gray950
    readonly property color backgroundMuted: colors.gray550Opacity07

    readonly property color text: colors.white
    readonly property color textSecondary: colors.gray400
    readonly property color textTertiary: colors.gray500
    readonly property color textPlaceholder: colors.gray600
    readonly property color textMuted: colors.gray700

    readonly property color border: colors.gray300
    readonly property color borderSecondary: colors.gray800
    readonly property color borderTertiary: colors.gray500
    readonly property color borderTertiaryMuted: Qt.rgba(borderTertiary.r, borderTertiary.g, borderTertiary.b, 0.2)

    readonly property color primary: colors.orange400
    readonly property color primaryHover: colors.orange500
    readonly property color primaryPressed: colors.orange600

    readonly property color success: colors.green500
    readonly property color successHover: colors.green400
    readonly property color successPressed: colors.green600

    readonly property color error: colors.red500
    readonly property color errorHover: colors.red400
    readonly property color errorPressed: colors.red600

    readonly property color warning: colors.yellow400
    readonly property color warningHover: colors.yellow500

    readonly property color info: colors.blue400

    readonly property color notification: colors.red500
    readonly property color accentOrange: colors.orange300
    readonly property color accentBurntOrange: colors.orange700
    readonly property color accentYellowSoft: colors.yellow300

    readonly property color hover: colors.gray700
    readonly property color pressed: colors.gray850
    readonly property color disabled: colors.gray500
    readonly property color focus: colors.orange400

    readonly property color glassOverlay: colors.gray550Opacity07
    readonly property color glassStrong: colors.gray550Opacity30
    readonly property color overlayLight: colors.whiteOpacity06
    readonly property color overlayOrange: colors.orange400Opacity30
}
