import QtQuick
import QtQuick.Controls

import Logos.Theme
import Logos.Controls

// List / menu row delegate. Inherits from Qt's `ItemDelegate` so it
// gets the standard `text` / `pressed` / `hovered` / `highlighted`
// surface — the customisations are background coloring, an optional
// rounded corner, and theme-driven typography.
//
//     LogosItemDelegate {
//         text: "Settings"
//         font.pixelSize: Theme.typography.subtitleText
//         font.weight: Theme.typography.weightMedium
//         textColor: Theme.palette.textTertiary
//     }
//
// Public extension knobs:
//     hoverColor / pressedColor / highlightColor   surface colors per state
//     textColor                                    label color when enabled
//                                                  (disabled falls back to textMuted)
//     radius                                       background rounding (default 0)
//
// Read-only inspection aliases (tests / tooling):
//     backgroundItem    the background Rectangle (state-coloured surface)
//     labelItem         the LogosText content item (responds to `text` /
//                       `font` / `textColor`)
ItemDelegate {
    id: root

    property color hoverColor: Theme.palette.hover
    property color pressedColor: Theme.palette.pressed
    property color highlightColor: Theme.colors.getColor(Theme.palette.primary, 0.18)
    property color textColor: Theme.palette.text
    property real radius: 0

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias backgroundItem: bg
    readonly property alias labelItem: label

    implicitHeight: 36

    leftPadding: Theme.spacing.medium
    rightPadding: Theme.spacing.medium

    font.pixelSize: Theme.typography.primaryText
    font.weight: Theme.typography.weightRegular

    contentItem: LogosText {
        id: label
        text: root.text
        font: root.font
        verticalAlignment: Text.AlignVCenter
        color: root.enabled ? root.textColor : Theme.palette.textMuted
        elide: Text.ElideRight
    }

    background: Rectangle {
        id: bg
        radius: root.radius
        color: root.pressed
               ? root.pressedColor
               : (root.highlighted
                    ? root.highlightColor
                    : (root.hovered ? root.hoverColor : "transparent"))
    }
}
