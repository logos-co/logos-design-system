import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

Rectangle {
    property string figmaUrl: ""
    property bool designed: false

    color: Theme.palette.background

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosGroupBox"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: GroupBox (title) + borderColor, labelColor. Aliases: backgroundItem, labelItem."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        LogosGroupBox {
            Layout.fillWidth: true
            title: "Network"

            ColumnLayout {
                width: parent.width
                spacing: Theme.spacing.small
                LogosCheckbox { text: "Use proxy" }
                LogosCheckbox { text: "Verify TLS certificates"; checked: true }
            }
        }

        LogosGroupBox {
            Layout.fillWidth: true
            title: "Storage"

            ColumnLayout {
                width: parent.width
                spacing: Theme.spacing.small
                LogosSwitch { text: "Auto-cleanup" }
                LogosSwitch { text: "Sync on save"; checked: true }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
