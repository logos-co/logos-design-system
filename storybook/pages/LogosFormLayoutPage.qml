import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Layouts

// Catalog page for LogosFormLayout and LogosFormField: one form at phone,
// tablet and desktop width.
Rectangle {
    id: page

    property string figmaUrl: ""
    property bool designed: false

    color: Theme.palette.background
    implicitHeight: column.implicitHeight + 2 * Theme.spacing.xxlarge

    component Section: ColumnLayout {
        property alias title: sectionTitle.text
        Layout.fillWidth: true
        spacing: Theme.spacing.medium
        LogosText {
            id: sectionTitle
            font.pixelSize: Theme.typography.primaryText
            font.weight: Theme.typography.weightBold
        }
        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.palette.borderHairline }
    }

    component PayoutForm: Rectangle {
        id: frame
        Layout.preferredHeight: payout.implicitHeight + 2 * Theme.spacing.xlarge
        color: Theme.palette.backgroundSecondary
        border.color: Theme.palette.borderSubtle

        LogosFormLayout {
            id: payout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            leftActions: [ LogosButton { text: "Cancel" } ]
            rightActions: [ LogosButton { text: "Save" } ]

            LogosText {
                text: "Payout"
                font.pixelSize: Theme.typography.subtitleText
                font.weight: Theme.typography.weightBold
            }
            LogosFormField {
                label: "Name"
                LogosTextField { placeholderText: "Your name" }
            }
            LogosFormField {
                label: "Payout address"
                error: "That isn't an address: it should start with 0x."
                LogosTextField { text: "x91b2" }
            }
            LogosFormField {
                label: "Amount"
                narrow: true
                LogosTextField { placeholderText: "0.00" }
            }
            LogosFormField {
                label: "Currency"
                narrow: true
                LogosComboBox { model: ["LGO", "ETH", "USDC"] }
            }
            LogosFormField {
                label: "Note"
                help: "Only you see this."
                LogosTextField {}
            }
        }
    }

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xxlarge

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosFormLayout"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
            }
            LogosText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: "A form, at most 720 px wide and centred. LogosFormLayout: leftActions, rightActions, maximumWidth, labelsBeside. LogosFormField: label, help, error, narrow, and the control as its content. Desktop: labels in a 200 px column beside the controls, buttons together at the end. Tablet: labels above, narrow fields in pairs. Phone: one field per row, buttons stacked with the main one last. Help and errors are text under the control, never tooltips."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Section {
            title: "At " + Math.round(phoneForm.width) + " px"
            PayoutForm { id: phoneForm; Layout.fillWidth: true; Layout.maximumWidth: 390 }
        }

        Section {
            title: "At " + Math.round(tabletForm.width) + " px"
            PayoutForm { id: tabletForm; Layout.fillWidth: true; Layout.maximumWidth: 700 }
        }

        Section {
            title: "At " + Math.round(desktopForm.width) + " px"
            PayoutForm { id: desktopForm; Layout.fillWidth: true; Layout.maximumWidth: 1000 }
        }

        Item { Layout.fillHeight: true }
    }
}
