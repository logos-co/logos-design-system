import QtQuick
import QtQuick.Controls

import Logos.Theme
import Logos.Controls

Switch {
    id: root

    property color trackColorOn: Theme.palette.primary
    property color trackColorOff: Theme.palette.surface
    property color handleColor: Theme.palette.text

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias indicatorItem: track
    readonly property alias handleItem: handle
    readonly property alias labelItem: label
    readonly property alias focusRingItem: focusRing

    spacing: Theme.spacing.small
    opacity: enabled ? 1.0 : 0.5

    focusPolicy: Qt.StrongFocus
    activeFocusOnTab: true

    indicator: Item {
        id: indicatorBox
        implicitWidth: 40
        implicitHeight: 24
        x: root.leftPadding
        y: root.topPadding + (root.availableHeight - height) / 2

        // Outer ring — solid focus color with a gap from the track so it stays
        // visible against both the dark off track and the primary on fill.
        Rectangle {
            id: focusRing
            anchors.fill: parent
            radius: height / 2
            color: "transparent"
            border.width: root.visualFocus ? 2 : 0
            border.color: Theme.palette.focus
        }

        Rectangle {
            id: track
            anchors.centerIn: parent
            width: 36
            height: 20
            radius: height / 2
            color: root.checked ? root.trackColorOn : root.trackColorOff
            border.color: Theme.palette.border
            border.width: 1
            Behavior on color { ColorAnimation { duration: 120 } }

            Rectangle {
                id: handle
                width: parent.height - Theme.spacing.tiny
                height: width
                radius: height / 2
                color: root.handleColor
                x: root.checked
                   ? parent.width - width - Theme.spacing.tiny / 2
                   : Theme.spacing.tiny / 2
                y: Theme.spacing.tiny / 2
                Behavior on x { NumberAnimation { duration: 120 } }
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
