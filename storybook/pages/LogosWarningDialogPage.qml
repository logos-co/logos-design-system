import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

Rectangle {
    property string figmaUrl: ""

    color: Theme.palette.background

    // Warning severity (default) — uses message: shorthand for simple body text.
    LogosWarningDialog {
        id: removeDlg
        anchors.centerIn: Overlay.overlay
        title: "Remove default repository?"
        width: 420
        message: "The default Logos repository provides the official package catalog. "
                 + "You can restore it later by pasting its URL into the \"Add a repository\" field."
        leftActions: [
            LogosButton { text: "Cancel"; implicitWidth: 100; implicitHeight: 36; onClicked: removeDlg.reject() }
        ]
        rightActions: [
            LogosButton { text: "Remove"; implicitWidth: 100; implicitHeight: 36; onClicked: removeDlg.accept() }
        ]
    }

    // Error severity — accentColor overridden to error palette.
    LogosWarningDialog {
        id: deleteDlg
        anchors.centerIn: Overlay.overlay
        title: "Delete account?"
        width: 380
        accentColor: Theme.palette.error
        message: "This will permanently delete your account and all associated data. This action cannot be undone."
        rightActions: [
            LogosButton { text: "Cancel"; implicitWidth: 100; implicitHeight: 36; onClicked: deleteDlg.reject() },
            LogosButton { text: "Delete"; implicitWidth: 100; implicitHeight: 36; onClicked: deleteDlg.accept() }
        ]
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosWarningDialog"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Extends LogosDialog with a warning icon in the header and an orange border accent. "
                      + "Use for destructive or cautionary confirmations. "
                      + "Same leftActions / rightActions API as LogosDialog."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        RowLayout {
            spacing: Theme.spacing.medium

            LogosButton {
                text: "Remove repository"
                implicitWidth: 180
                implicitHeight: 36
                onClicked: removeDlg.open()
            }

            LogosButton {
                text: "Delete account"
                implicitWidth: 160
                implicitHeight: 36
                onClicked: deleteDlg.open()
            }
        }

        Item { Layout.fillHeight: true }
    }
}
