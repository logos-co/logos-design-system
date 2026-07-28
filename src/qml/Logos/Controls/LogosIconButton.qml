import QtQuick
import QtQuick.Controls
import QtQuick.Effects

import Logos.Theme

// Public API:
//     iconSource    URL of the icon image (PNG/SVG). Empty hides the icon.
//     iconColor     tint applied to the icon (default = textTertiary, matches
//                   the figma's #969696 chip spec)
//     size          outer width/height in px (default 40)
//     iconSize      icon width/height in px (default 20)
//     flat          hide the pill background/border — ghost icon button
//                   (default false)
//     pressed       read-only; true while the mouse is held down on the button.
//                   Non-flat pills use a distinct pressed fill (pressed wins
//                   over hover), matching LogosButton secondary.
//
// Read-only inspection aliases:
//     iconImage         the underlying Image element
//     backgroundItem    the pill Rectangle behind the icon
//     mouseAreaItem     the click target (used by tests)
//     _backgroundColor  d.backgroundColor; not for app use
//
// Signals:
//     clicked()
//
// Example:
//     LogosIconButton {
//         iconSource: Qt.resolvedUrl("icons/refresh-line.svg")
//         onClicked: backend.refresh()
//     }
Control {
    id: root

    property url   iconSource: ""
    property color iconColor: Theme.palette.textTertiary
    property int   size: 40
    property int   iconSize: 20
    property bool  flat: false

    readonly property bool pressed: mouseArea.containsPress
    readonly property bool isActive: enabled && (root.pressed || root.hovered || root.activeFocus)
    readonly property alias iconImage: iconImg
    readonly property alias backgroundItem: bg
    readonly property alias mouseAreaItem: mouseArea
    readonly property var _backgroundColor: d.backgroundColor

    signal clicked()

    QtObject {
        id: d
        function backgroundColor(enabled, pressed, hovered, focused) {
            if (!enabled)
                return Theme.palette.backgroundButton
            if (pressed)
                return Theme.palette.background
            if (hovered || focused)
                return Theme.palette.backgroundMuted
            return Theme.palette.backgroundButton
        }
    }

    implicitWidth: size
    implicitHeight: size
    hoverEnabled: true
    opacity: enabled ? 1.0 : 0.4

    background: Rectangle {
        id: bg
        visible: !root.flat
        color: d.backgroundColor(root.enabled, root.pressed, root.hovered, root.activeFocus)
        radius: Theme.spacing.radiusPill
        border.color: root.isActive ? Theme.palette.overlayOrange : Theme.palette.borderStrong
        border.width: 1
        antialiasing: true
    }

    contentItem: Item {
        Item {
            id: iconHolder
            anchors.centerIn: parent
            width: root.iconSize
            height: root.iconSize

            Image {
                id: iconImg
                anchors.fill: parent
                source: root.iconSource
                sourceSize: Qt.size(parent.width * 2, parent.height * 2)
                fillMode: Image.PreserveAspectFit
                visible: false
            }
            MultiEffect {
                anchors.fill: iconImg
                source: iconImg
                colorization: 1.0
                colorizationColor: root.iconColor
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
