import QtQuick
import QtQuick.Controls
import QtQuick.Effects

import Logos.Theme
import Logos.Controls

// TabButton themed for use inside LogosTabBar.
//
// Public API (in addition to TabButton's own text/checked/icon group):
//     icon.source       leading icon (uses AbstractButton's icon group property)
//     activeColor       text + icon color when checked   (default: Theme.palette.primary)
//     inactiveColor     text + icon color when unchecked (default: Theme.palette.textTertiary)
//
// The active-state underline is owned by LogosTabBar — this button does not draw it.
// Using this button outside LogosTabBar means no indicator will be rendered.
TabButton {
    id: root

    property color activeColor: Theme.palette.primary
    property color inactiveColor: Theme.palette.textTertiary

    implicitHeight: 40
    spacing: 6
    leftPadding: 8
    rightPadding: 8
    topPadding: 4
    bottomPadding: 4

    font.pixelSize: Theme.typography.primaryText
    font.weight: Theme.typography.weightMedium

    icon.width: 20
    icon.height: 20

    background: Item {}

    contentItem: Row {
        spacing: root.spacing

        Item {
            id: iconHolder

            visible: root.icon.source.toString().length > 0
            width: root.icon.width
            height: root.icon.height
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: iconImg
                anchors.fill: parent
                source: root.icon.source
                sourceSize: Qt.size(parent.width * 2, parent.height * 2)
                fillMode: Image.PreserveAspectFit
                visible: false
            }

            MultiEffect {
                anchors.fill: iconImg
                source: iconImg
                colorization: 1.0
                colorizationColor: root.checked ? root.activeColor : root.inactiveColor
            }
        }

        LogosText {
            text: root.text
            font: root.font
            color: root.checked ? root.activeColor : root.inactiveColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
