import QtQuick
import QtQuick.Controls

import Logos.Theme
import Logos.Controls

// Public API (in addition to CheckBox's text / checked / checkState / clicked()):
//     activeColor      Inner fill when checked      (default: Theme.palette.primary)
//     boxColor         Inner fill when unchecked    (default: Theme.palette.surface)
//     borderColor      Outer ring color             (default: Theme.palette.border)
//     checkmarkColor   Checkmark stroke color       (default: Theme.palette.text)
//
// Read-only inspection aliases: indicatorItem, labelItem.
//
// Example:
//     LogosCheckbox {
//         text: qsTr("I agree to the terms")
//         checked: true
//         onClicked: console.log("checked:", checked)
//     }
CheckBox {
    id: root

    property color activeColor: Theme.palette.primary
    property color boxColor: Theme.palette.surface
    property color borderColor: Theme.palette.border
    property color checkmarkColor: Theme.palette.text

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias indicatorItem: indicatorBox
    readonly property alias labelItem: labelText

    spacing: Theme.spacing.small
    padding: Theme.spacing.tiny

    opacity: enabled ? 1.0 : 0.5

    indicator: Item {
        id: indicatorBox

        implicitWidth: 24
        implicitHeight: 24
        x: root.leftPadding
        y: root.topPadding + (root.availableHeight - height) / 2

        // Outer ring
        Rectangle {
            anchors.fill: parent
            anchors.margins: parent.width * 0.10
            color: root.borderColor
            radius: Theme.spacing.radiusSmall
        }

        // Inner box 
        Rectangle {
            anchors.fill: parent
            anchors.margins: parent.width * 0.175
            color: root.checked ? root.activeColor : root.boxColor
            radius: Theme.spacing.radiusSmall

            Canvas {
                id: checkmarkCanvas

                anchors.fill: parent
                anchors.margins: parent.width * 0.18
                visible: root.checked
                property color strokeColor: root.checkmarkColor
                onStrokeColorChanged: requestPaint()

                onPaint: {
                    const ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.strokeStyle = strokeColor
                    ctx.lineWidth = Math.max(1.5, width * 0.2)
                    ctx.lineCap = "round"
                    ctx.lineJoin = "round"
                    ctx.beginPath()
                    ctx.moveTo(width * 0.05, height * 0.5)
                    ctx.lineTo(width * 0.4, height * 0.85)
                    ctx.lineTo(width * 0.95, height * 0.15)
                    ctx.stroke()
                }
            }
        }
    }

    contentItem: LogosText {
        id: labelText

        text: root.text
        font.pixelSize: Theme.typography.primaryText
        color: root.enabled ? Theme.palette.text : Theme.palette.textMuted
        verticalAlignment: Text.AlignVCenter
        leftPadding: root.indicator ? root.indicator.width + root.spacing : 0
    }
}
