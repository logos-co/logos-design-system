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

    /** Expose the inner TextInput for advanced use (cursorPosition, select, etc.) */
    readonly property alias textInput: input

    QtObject {
        id: d
        property bool inputActiveFocus: false
    }

    implicitWidth: 200
    implicitHeight: 40
    leftPadding: 12
    rightPadding: 12
    clip: true

    background: Rectangle {
        radius: Theme.spacing.radiusSmall
        color: Theme.palette.backgroundSecondary
        border.width: 1
        border.color: d.inputActiveFocus ? Theme.palette.overlayOrange : Theme.palette.backgroundElevated
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
            color: Theme.palette.text
            echoMode: root.echoMode
            onActiveFocusChanged: d.inputActiveFocus = input.activeFocus
        }

        Component.onCompleted: d.inputActiveFocus = input.activeFocus
    }
}
