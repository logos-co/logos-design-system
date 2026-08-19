import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Icons

Rectangle {
    id: page
    property string figmaUrl: ""

    color: Theme.palette.background

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosToast"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "LogosNotice plus transient behaviour: auto-closes (duration, 4 s default), "
                    + "dismissible, starts hidden, and animates in. Same API otherwise."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
            LogosText {
                text: "A toast should not be the only place a user can read something they can't "
                    + "recover. Set duration: 0 for those and it stays until dismissed."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        ColumnLayout {
            spacing: Theme.spacing.medium

            LogosText {
                text: "Trigger one — it appears bottom-right and closes itself."
                color: Theme.palette.textSecondary
            }

            RowLayout {
                spacing: Theme.spacing.medium
                LogosButton {
                    text: "Success"
                    onClicked: demoToast.raise(LogosNotice.Success, "Module published",
                                               "logos-chat-ui 0.2.2 is live on the release channel.", 4000)
                }
                LogosButton {
                    text: "Error"
                    onClicked: demoToast.raise(LogosNotice.Error, "Upload failed",
                                               "Couldn't reach the signing server.", 4000)
                }
                LogosButton {
                    text: "Warning"
                    onClicked: demoToast.raise(LogosNotice.Warning, "Disk space low",
                                               "Cache is using 4.2 GB.", 4000)
                }
                LogosButton {
                    text: "Info"
                    onClicked: demoToast.raise(LogosNotice.Info, "Update available",
                                               "Version 0.3.0 is ready to install.", 4000)
                }
            }

            RowLayout {
                spacing: Theme.spacing.medium
                Layout.topMargin: Theme.spacing.medium
                LogosButton {
                    text: "Sticky (duration: 0)"
                    onClicked: demoToast.raise(LogosNotice.Error, "Wallet forgotten",
                                               "Config: /home/you/wallet/config.json", 0)
                }
                LogosButton {
                    text: "Long (10 s)"
                    onClicked: demoToast.raise(LogosNotice.Info, "Syncing modules",
                                               "3 of 7 repositories fetched…", 10000)
                }
            }

            LogosText {
                id: stateLabel
                text: "shown: false"
                color: Theme.palette.textTertiary
                font.pixelSize: Theme.typography.secondaryText
                Layout.topMargin: Theme.spacing.medium
            }
        }

        Item { Layout.fillHeight: true }
    }

    LogosToast {
        id: demoToast

        // Toasts are positioned by the caller; the component owns the surface,
        // the timing and the animation, not where it lives on screen.
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.spacing.xlarge
        width: 420

        function raise(sev, t, m, ms) {
            demoToast.severity = sev
            demoToast.duration = ms
            demoToast.show(t, m)
            stateLabel.text = "shown: true (duration: " + ms + ")"
        }

        onDismissed: stateLabel.text = "shown: false — dismissed"
    }
}
