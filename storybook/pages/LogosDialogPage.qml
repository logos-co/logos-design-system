import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

Rectangle {
    property string figmaUrl: ""
    property bool designed: false

    color: Theme.palette.background

    component ProfileForm: ColumnLayout {
        spacing: Theme.spacing.medium
        Repeater {
            model: ["Name", "Email", "Phone", "Node URL", "Payout address", "City", "Country", "Website", "Referral code", "Note"]
            delegate: ColumnLayout {
                id: field
                required property string modelData
                Layout.fillWidth: true
                spacing: Theme.spacing.tiny
                LogosText {
                    text: field.modelData
                    font.pixelSize: Theme.typography.secondaryText
                    color: Theme.palette.textSecondary
                }
                LogosTextField {
                    Layout.fillWidth: true
                    placeholderText: field.modelData
                }
            }
        }
    }

    LogosDialog {
        id: longDlg
        title: "Edit profile"
        message: "Everything here is shared with your contacts."
        preferredWidth: 480
        body: ProfileForm {}
        leftActions: [ LogosButton { text: "Cancel"; onClicked: longDlg.reject() } ]
        rightActions: [ LogosButton { text: "Save"; onClicked: longDlg.accept() } ]
    }

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
            Layout.fillWidth: true
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosDialog"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: title, message, body (your own content; it scrolls when tall), leftActions, rightActions (list<Item>), preferredWidth, fullPage, sheet, dragToClose. "
                      + "Aliases: backgroundItem, headerItem, footerItem, messageItem, handleItem, closeButtonItem, scrollViewItem. "
                      + "Left to place itself it is centred, or in a phone-wide parent a bottom sheet, or with fullPage a full page. The two above set anchors.centerIn and are sheets on a phone all the same."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Flow {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosButton {
                text: "Confirm dialog"
                implicitWidth: 160
                onClicked: confirmDlg.open()
            }

            LogosButton {
                text: "Wizard dialog (left + right)"
                implicitWidth: 240
                onClicked: helpDlg.open()
            }

            LogosButton {
                text: "Long form (body scrolls)"
                implicitWidth: 200
                onClicked: longDlg.open()
            }
        }

        LogosText {
            text: "Placed by itself, in a " + Math.round(phoneParent.width) + " px parent"
            font.pixelSize: Theme.typography.primaryText
            font.weight: Theme.typography.weightBold
            color: Theme.palette.text
        }

        Rectangle {
            id: phoneParent
            Layout.fillWidth: true
            Layout.maximumWidth: 390
            Layout.preferredHeight: 520
            color: Theme.palette.backgroundSecondary
            border.color: Theme.palette.borderSubtle

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.spacing.large
                spacing: Theme.spacing.medium

                LogosButton {
                    Layout.fillWidth: true
                    text: "Sheet (drag down or tap outside to close)"
                    onClicked: phoneSheet.open()
                }
                LogosButton {
                    Layout.fillWidth: true
                    text: "Sheet that must be answered"
                    onClicked: phoneMustAnswer.open()
                }
                LogosButton {
                    Layout.fillWidth: true
                    text: "Full page (fullPage: a form)"
                    onClicked: phonePage.open()
                }
            }

            LogosDialog {
                id: phoneSheet
                title: "Remove repository?"
                message: "You can add it again later. Packages already installed from it stay installed."
                preferredWidth: 420
                leftActions: [ LogosButton { text: "Cancel"; onClicked: phoneSheet.reject() } ]
                rightActions: [ LogosButton { text: "Remove"; onClicked: phoneSheet.accept() } ]
            }

            LogosDialog {
                id: phonePage
                fullPage: true
                title: "Edit profile"
                message: "Everything here is shared with your contacts."
                body: ProfileForm {}
                leftActions: [ LogosButton { text: "Cancel"; onClicked: phonePage.reject() } ]
                rightActions: [ LogosButton { text: "Save"; onClicked: phonePage.accept() } ]
            }

            LogosWarningDialog {
                id: phoneMustAnswer
                closePolicy: Popup.CloseOnEscape
                title: "Delete account?"
                message: "This cannot be undone."
                accentColor: Theme.palette.error
                leftActions: [ LogosButton { text: "Keep it"; onClicked: phoneMustAnswer.reject() } ]
                rightActions: [ LogosButton { text: "Delete"; onClicked: phoneMustAnswer.accept() } ]
            }
        }

        Item { Layout.fillHeight: true }
    }
}
