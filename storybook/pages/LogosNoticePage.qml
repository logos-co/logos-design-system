import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Icons

Rectangle {
    property string figmaUrl: ""

    color: Theme.palette.background

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosNotice"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: severity, title, message, closable, actions (list<Item>), shown. "
                    + "Method: hide(). Signal: dismissed(). "
                    + "Aliases: titleItem, messageItem, backgroundItem, closeButtonItem, iconItem."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
            LogosText {
                text: "Use LogosNotice for a message that belongs to the layout and stays until the "
                    + "situation changes. For one that arrives, says its piece and leaves, use LogosToast."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.maximumWidth: 640
            spacing: Theme.spacing.medium

            LogosText { text: "Severities"; color: Theme.palette.textSecondary }

            LogosNotice {
                Layout.fillWidth: true
                severity: LogosNotice.Success
                title: "Module published"
                message: "logos-chat-ui 0.2.2 is live on the release channel."
                closable: true
            }
            LogosNotice {
                Layout.fillWidth: true
                severity: LogosNotice.Error
                title: "Upload failed"
                message: "Couldn't reach the signing server. Check your connection."
                closable: true
            }
            LogosNotice {
                Layout.fillWidth: true
                severity: LogosNotice.Warning
                title: "Disk space low"
                message: "Cache is using 4.2 GB. Old builds may fail to save."
                closable: true
            }
            LogosNotice {
                Layout.fillWidth: true
                severity: LogosNotice.Info
                title: "Update available"
                message: "Version 0.3.0 is ready to install on next restart."
                closable: true
            }

            LogosText {
                text: "With actions"
                color: Theme.palette.textSecondary
                Layout.topMargin: Theme.spacing.medium
            }
            LogosNotice {
                id: actionNotice
                Layout.fillWidth: true
                severity: LogosNotice.Error
                title: "Upload failed"
                message: "Couldn't reach the signing server. Check your connection."
                closable: true
                // Caller-supplied Items, like LogosDialog's footer actions.
                // "Retry" acts, so it is a button; "View log" navigates, so it is
                // a link — the two carry different accessible roles and the
                // notice deliberately does not choose for you.
                actions: [
                    LogosButton {
                        text: "Retry"
                        variant: LogosButton.Variant.Secondary
                        font.pixelSize: Theme.typography.secondaryText
                        onClicked: actionLog.text = "Retry triggered"
                    },
                    LogosLink {
                        text: "View log"
                        underline: false
                        onActivated: actionLog.text = "View log triggered"
                    }
                ]
            }
            LogosText {
                id: actionLog
                text: "(no action triggered yet)"
                color: Theme.palette.textTertiary
                font.pixelSize: Theme.typography.secondaryText
            }

            LogosText {
                text: "Message only — no title, not dismissible. The form-error shape."
                color: Theme.palette.textSecondary
                Layout.topMargin: Theme.spacing.medium
            }
            LogosNotice {
                Layout.fillWidth: true
                severity: LogosNotice.Error
                message: "Passwords do not match."
            }

            LogosText {
                text: "LogosNotice never closes itself — there is no duration and no show(). "
                    + "Timed dismissal lives in LogosToast, so anything carrying information the "
                    + "user can't recover (a path, an error code) is safe on this surface by default."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                color: Theme.palette.textTertiary
                font.pixelSize: Theme.typography.secondaryText
                Layout.topMargin: Theme.spacing.medium
            }
        }

        Item { Layout.fillHeight: true }
    }
}
