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

    spacing: Theme.spacing.small
    opacity: enabled ? 1.0 : 0.5

    indicator: Rectangle {
        id: track
        implicitWidth: 36
        implicitHeight: 20
        x: root.leftPadding
        y: root.topPadding + (root.availableHeight - height) / 2
        radius: height / 2
        color: root.checked ? root.trackColorOn : root.trackColorOff
        border.color: Theme.palette.border
        Behavior on color { ColorAnimation { duration: 120 } }

        Rectangle {
            id: handle
            width: parent.height - 4
            height: width
            radius: height / 2
            color: root.handleColor
            x: root.checked ? parent.width - width - 2 : 2
            y: 2
            Behavior on x { NumberAnimation { duration: 120 } }
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
