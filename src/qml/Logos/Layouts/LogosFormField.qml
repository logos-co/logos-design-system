import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

// LogosFormField — one field of a form: its label, its control, and help or
// an error under the control. An error takes the help's place, in the error
// colour. In a LogosFormLayout the form places the label: beside the control
// on desktop, above it otherwise; narrow fields pair up on a tablet.
//
// Public API:
//     label              the field's name
//     help               a hint under the control
//     error              what is wrong with the value; replaces help
//     narrow             pairs with a neighbouring narrow field on a tablet
//     labelBeside        the label sits beside the control (set by the form)
//     content (default)  the control, e.g. a LogosTextField; it fills the width,
//                        and its accessible name and description are the
//                        label and the error or help
//
// Read-only inspection aliases: labelItem, helpItem, errorItem.
//
// Example:
//     LogosFormField {
//         label: qsTr("Payout address")
//         help: qsTr("Rewards are paid here.")
//         error: addressValid ? "" : qsTr("That isn't an address.")
//         LogosTextField { placeholderText: "0x…" }
//     }
Item {
    id: root

    property string label: ""
    property string help: ""
    property string error: ""
    property bool narrow: false
    property bool labelBeside: false
    default property alias content: holder.data

    readonly property alias labelItem: labelText
    readonly property alias helpItem: helpText
    readonly property alias errorItem: errorText

    implicitWidth: grid.implicitWidth
    implicitHeight: grid.implicitHeight

    QtObject {
        id: d

        readonly property Item control: holder.children.length > 0 ? holder.children[0] : null

        // A screen reader on the control hears the field's label, and its error
        // or help.
        onControlChanged: {
            if (!control)
                return
            control.Layout.fillWidth = true
            control.Accessible.name = Qt.binding(() => root.label)
            control.Accessible.description = Qt.binding(() => root.error !== "" ? root.error : root.help)
        }
    }

    GridLayout {
        id: grid
        anchors.left: parent.left
        anchors.right: parent.right
        columns: root.labelBeside ? 2 : 1
        columnSpacing: Theme.spacing.large
        rowSpacing: Theme.spacing.tiny

        LogosText {
            id: labelText
            visible: root.label !== ""
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: root.labelBeside ? Theme.layouts.form.labelWidth : -1
            Layout.fillWidth: !root.labelBeside
            // Beside a one-line control, centred on it.
            Layout.preferredHeight: root.labelBeside && d.control ? Math.min(d.control.height, Theme.size.controlLarge) : -1
            verticalAlignment: Text.AlignVCenter
            text: root.label
            wrapMode: Text.Wrap
            color: Theme.palette.textSecondary
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.tiny

            ColumnLayout {
                id: holder
                Layout.fillWidth: true
                spacing: 0
            }

            LogosText {
                id: helpText
                visible: root.help !== "" && root.error === ""
                Layout.fillWidth: true
                text: root.help
                wrapMode: Text.Wrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }

            LogosText {
                id: errorText
                visible: root.error !== ""
                Layout.fillWidth: true
                text: root.error
                wrapMode: Text.Wrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.error
            }
        }
    }
}
