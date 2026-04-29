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
//
// Read-only inspection aliases:
//     iconImage         the underlying Image element
//     backgroundItem    the pill Rectangle behind the icon
//     mouseAreaItem     the click target (used by tests)
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

    readonly property bool isActive: mouseArea.pressed || root.hovered

    readonly property alias iconImage: iconImg
    readonly property alias backgroundItem: bg
    readonly property alias mouseAreaItem: mouseArea

    signal clicked()

    implicitWidth: size
    implicitHeight: size
    hoverEnabled: true
    opacity: enabled ? 1.0 : 0.4

    background: Rectangle {
        id: bg
        color: Theme.palette.backgroundButton
        radius: Theme.spacing.radiusPill
        // Figma spec is rgba(150,150,150,0.2) which renders nearly invisible
        // on the dark chip — using borderStrong (#515151) for visibility while
        // staying in the same gray family.
        border.color: Theme.palette.borderStrong
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
