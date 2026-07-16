import QtQuick
import QtQuick.Controls

import Logos.Theme
import Logos.Controls

Control {
    id: root

    // --- Public API ---
    property alias text: input.text
    property string placeholderText: ""
    property color placeholderTextColor: Theme.palette.textTertiary
    property int echoMode: TextInput.Normal
    property alias validator: input.validator
    property alias readOnly: input.readOnly

    /** Expose the inner TextInput for advanced use (cursorPosition, select, etc.) */
    readonly property alias textInput: input

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias placeholderItem: placeholder
    readonly property alias backgroundItem: bg

    implicitWidth: 200
    implicitHeight: 40
    leftPadding: 12
    rightPadding: 12
    clip: true

    background: Rectangle {
        id: bg
        radius: Theme.spacing.radiusSmall
        color: Theme.palette.backgroundSecondary
        border.width: 1
        border.color: {
            if (input.validator && input.text.length > 0 && !input.acceptableInput)
                return Theme.palette.error
            if (input.activeFocus)
                return Theme.palette.overlayOrange
            return Theme.palette.backgroundElevated
        }
    }

    contentItem: Item {
        id: contentRow
        property alias input: input
        clip: true

        LogosText {
            id: placeholder
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            text: root.placeholderText
            color: root.placeholderTextColor
            font.pixelSize: Theme.typography.secondaryText
            visible: input.text.length === 0
        }

        TextInput {
            id: input
            clip: true
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Theme.typography.secondaryText
            color: input.validator && input.text.length > 0 && !input.acceptableInput ? Theme.palette.error : Theme.palette.text
            echoMode: root.echoMode
            enabled: root.enabled
        }
    }
}
