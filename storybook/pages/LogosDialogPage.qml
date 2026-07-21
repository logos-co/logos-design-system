import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

Rectangle {
    property string figmaUrl: ""
    property bool designed: false

    color: Theme.palette.background

    // message: shorthand — no contentItem override needed for simple text.
    LogosDialog {
        id: confirmDlg
        anchors.centerIn: Overlay.overlay
        title: "Confirm action"
        message: "Are you sure you want to proceed? This action cannot be undone."
        rightActions: [
            LogosButton { text: "Cancel"; implicitWidth: 100; onClicked: confirmDlg.reject() },
            LogosButton { text: "Confirm"; implicitWidth: 100; onClicked: confirmDlg.accept() }
        ]
    }

    LogosDialog {
        id: helpDlg
        anchors.centerIn: Overlay.overlay
        title: "Setup wizard"
        contentItem: LogosText {
            text: "Step 2 of 4 — configure your network preferences."
            wrapMode: Text.WordWrap
        }
        leftActions: [
            LogosButton { text: "Help"; implicitWidth: 100; onClicked: console.log("help") }
        ]
        rightActions: [
            LogosButton { text: "Back"; implicitWidth: 100; onClicked: helpDlg.reject() },
            LogosButton { text: "Next"; implicitWidth: 100; onClicked: helpDlg.accept() }
        ]
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosDialog"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: title, message (convenience body text), leftActions, rightActions (list<Item>). "
                      + "Override contentItem for rich bodies. Aliases: backgroundItem, headerItem, footerItem, messageItem."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        RowLayout {
            spacing: Theme.spacing.medium

            LogosButton {
                text: "Confirm dialog"
                implicitWidth: 160
                implicitHeight: 36
                onClicked: confirmDlg.open()
            }

            LogosButton {
                text: "Wizard dialog (left + right)"
                implicitWidth: 240
                implicitHeight: 36
                onClicked: helpDlg.open()
            }
        }

        Item { Layout.fillHeight: true }
    }
}
