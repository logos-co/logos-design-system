import QtQuick
import QtQuick.Controls
import QtQuick.Effects

import Logos.Theme
import Logos.Controls

// TabButton themed for use inside LogosTabBar.
//
// Public API (in addition to TabButton's own text/checked):
//     iconSource        URL of the leading icon (use this instead of icon.source)
//     activeColor       text + icon color when checked   (default: Theme.palette.primary)
//     inactiveColor     text + icon color when unchecked (default: Theme.palette.textTertiary)
TabButton {
    id: root

    property color activeColor: Theme.palette.primary
    property color inactiveColor: Theme.palette.textTertiary
    property url iconSource: ""

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias iconItem: iconHolder
    readonly property alias labelItem: labelText

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

    contentItem: Item {
        implicitWidth: contentRow.implicitWidth
        implicitHeight: contentRow.implicitHeight

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: root.spacing

            Item {
                id: iconHolder

                visible: root.iconSource.toString().length > 0
                width: root.icon.width
                height: root.icon.height
                anchors.verticalCenter: parent.verticalCenter

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
                    colorizationColor: root.checked ? root.activeColor : root.inactiveColor
                }
            }

            LogosText {
                id: labelText
                text: root.text
                font: root.font
                color: root.checked ? root.activeColor : root.inactiveColor
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    HoverHandler {
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
}
