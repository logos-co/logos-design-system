import QtQuick
import QtQuick.Controls

import Logos.Theme
import Logos.Controls

RadioButton {
    id: root

    property color activeColor: Theme.palette.primary
    property color borderColor: Theme.palette.border
    property color boxColor: Theme.palette.surface

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias indicatorItem: indicatorBox
    readonly property alias labelItem: label

    spacing: Theme.spacing.small
    opacity: enabled ? 1.0 : 0.5

    indicator: Rectangle {
        id: indicatorBox
        implicitWidth: 18
        implicitHeight: 18
        x: root.leftPadding
        y: root.topPadding + (root.availableHeight - height) / 2
        radius: width / 2
        color: root.boxColor
        border.color: root.checked ? root.activeColor : root.borderColor
        border.width: 1

        Rectangle {
            anchors.centerIn: parent
            width: 8
            height: 8
            radius: 4
            color: root.activeColor
            visible: root.checked
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
