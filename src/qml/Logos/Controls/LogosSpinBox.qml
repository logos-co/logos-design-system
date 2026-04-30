import QtQuick
import QtQuick.Controls

import Logos.Theme
import Logos.Controls

SpinBox {
    id: root

    property color backgroundColor: Theme.palette.backgroundSecondary
    property color borderColor: Theme.palette.border
    property color buttonColor: Theme.palette.surface

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias backgroundItem: bg
    readonly property alias contentLabel: input

    implicitHeight: 32
    editable: true

    background: Rectangle {
        id: bg
        color: root.backgroundColor
        border.color: root.borderColor
        border.width: 1
        radius: Theme.spacing.radiusSmall
    }

    contentItem: TextInput {
        id: input
        text: root.displayText
        font.family: Theme.typography.publicSans
        font.pixelSize: Theme.typography.primaryText
        color: Theme.palette.text
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        leftPadding: Theme.spacing.small
        rightPadding: Theme.spacing.small
        readOnly: !root.editable
        validator: root.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        selectByMouse: true
    }

    up.indicator: Rectangle {
        x: parent.width - width
        height: parent.height
        implicitWidth: 28
        color: root.up.pressed ? Theme.palette.pressed : root.buttonColor
        radius: Theme.spacing.radiusSmall

        LogosText {
            anchors.centerIn: parent
            text: "+"
            color: Theme.palette.text
        }
    }

    down.indicator: Rectangle {
        x: 0
        height: parent.height
        implicitWidth: 28
        color: root.down.pressed ? Theme.palette.pressed : root.buttonColor
        radius: Theme.spacing.radiusSmall

        LogosText {
            anchors.centerIn: parent
            text: "−"
            color: Theme.palette.text
        }
    }
}
