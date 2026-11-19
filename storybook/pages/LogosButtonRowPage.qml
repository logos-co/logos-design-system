import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

// Catalog page for LogosButtonRow: one row while the buttons fit, stacked full
// width with the main ones last when they don't or on a phone.
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

    component Framed: ColumnLayout {
        id: framed
        property int frameWidth: 390
        property bool stackOnPhone: true
        spacing: Theme.spacing.tiny
        LogosText {
            text: framed.frameWidth + " px"
            font.pixelSize: Theme.typography.secondaryText
            color: Theme.palette.textSecondary
        }
        Rectangle {
            Layout.preferredWidth: framed.frameWidth
            Layout.preferredHeight: buttons.implicitHeight + 2 * Theme.spacing.large
            color: Theme.palette.backgroundSecondary
            border.color: Theme.palette.borderSubtle

            LogosButtonRow {
                id: buttons
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: Theme.spacing.large
                stackOnPhone: framed.stackOnPhone
                leftActions: [ LogosButton { text: "Cancel" } ]
                rightActions: [ LogosButton { text: "Save draft" }, LogosButton { text: "Publish" } ]
            }
        }
    }

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xxlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosButtonRow"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
            }
            LogosText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: "The buttons under a form, a card or a message. Public API: leftActions, rightActions, stackOnPhone, stacked. One row while they fit at 140 px each; when they don't, or when the row is phone-wide, they stack full width with the main (right-hand) ones last."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Section {
            title: "Under a form"
            Framed { frameWidth: 390 }
            Framed { frameWidth: 700 }
        }

        Section {
            title: "In a card (stackOnPhone: false): a row while they fit"
            Framed { frameWidth: 500; stackOnPhone: false }
            Framed { frameWidth: 360; stackOnPhone: false }
        }

        Item { Layout.fillHeight: true }
    }
}
