import QtQuick
import QtQuick.Controls

import Logos.Theme
import Logos.Controls

// Public API (in addition to RadioButton's text / checked / clicked()):
//     activeColor   Inner fill when checked      (default: Theme.palette.primary)
//     boxColor      Outer circle fill            (default: Theme.palette.surface)
//     borderColor   Outer ring color             (default: Theme.palette.border)
//
// Read-only inspection aliases: indicatorItem, focusRingItem, labelItem.
//
// Example:
//     LogosRadioButton {
//         text: qsTr("Option A")
//         checked: true
//         onClicked: console.log("checked:", checked)
//     }
RadioButton {
    id: root

    property color activeColor: Theme.palette.primary
    property color borderColor: Theme.palette.border
    property color boxColor: Theme.palette.surface

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias indicatorItem: indicatorBox
    readonly property alias focusRingItem: focusRing
    readonly property alias labelItem: label

    spacing: Theme.spacing.small
    padding: Theme.spacing.tiny
    opacity: enabled ? 1.0 : 0.5

    focusPolicy: Qt.StrongFocus
    activeFocusOnTab: true

    indicator: Item {
        implicitWidth: 22
        implicitHeight: 22
        x: root.leftPadding
        y: root.topPadding + (root.availableHeight - height) / 2

        // Outer ring — solid focus color with a gap from the circle so it stays
        // visible against both the surface unchecked fill and the primary
        // checked fill (overlayOrange on surface was effectively invisible).
        Rectangle {
            id: focusRing
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.width: root.visualFocus ? 2 : 0
            border.color: Theme.palette.focus
        }

        Rectangle {
            id: indicatorBox
            anchors.centerIn: parent
            width: parent.width - Theme.spacing.tiny
            height: parent.height - Theme.spacing.tiny
            radius: width / 2
            color: root.boxColor
            border.color: root.checked ? root.activeColor : root.borderColor
            border.width: 1

            Rectangle {
                anchors.centerIn: parent
                width: 8
                height: 8
                radius: Theme.spacing.tiny
                color: root.activeColor
                visible: root.checked
            }
        }
    }

    contentItem: LogosText {
        id: label
        leftPadding: root.indicator.width + root.spacing
        verticalAlignment: Text.AlignVCenter
        text: root.text
        color: root.enabled ? Theme.palette.text : Theme.palette.textMuted
    }
}
