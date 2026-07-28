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
// Read-only inspection aliases: indicatorItem, focusRingItem, labelItem.
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
    readonly property alias indicatorItem: box
    readonly property alias focusRingItem: focusRing
    readonly property alias labelItem: labelText

    spacing: Theme.spacing.small
    padding: Theme.spacing.tiny

    opacity: enabled ? 1.0 : 0.5

    focusPolicy: Qt.StrongFocus
    activeFocusOnTab: true

    indicator: Item {
        id: indicatorBox

        implicitWidth: 24
        implicitHeight: 24
        x: root.leftPadding
        y: root.topPadding + (root.availableHeight - height) / 2

        // Outer ring — solid focus color with a gap from the box so it stays
        // visible against both the surface unchecked fill and the primary
        // checked fill (overlayOrange on primary was effectively invisible).
        Rectangle {
            id: focusRing
            anchors.fill: parent
            radius: Theme.spacing.radiusSmall
            color: "transparent"
            border.width: root.visualFocus ? 2 : 0
            border.color: Theme.palette.focus
        }

        Rectangle {
            id: box
            anchors.centerIn: parent
            width: parent.width - Theme.spacing.tiny
            height: parent.height - Theme.spacing.tiny
            color: root.checked ? root.activeColor : root.boxColor
            border.color: root.borderColor
            border.width: 1
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
