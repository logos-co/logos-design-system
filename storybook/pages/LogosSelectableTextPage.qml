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
        spacing: Theme.spacing.xxlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny

            LogosText {
                text: "LogosSelectableText"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: text, color, selectByMouse, wrapMode, selectedText (plus TextEdit selection APIs)"
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
            LogosText {
                text: "Themed like LogosText, drag-selectable via TextEdit. Not an input — use LogosTextField to edit. Pair with LogosCopyButton for one-click copy."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "States"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.palette.borderHairline
            }

            LogosText {
                text: "Default — drag to select"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
            }
            LogosSelectableText {
                Layout.fillWidth: true
                Layout.preferredHeight: 24
                text: "QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG"
            }

            LogosText {
                text: "Secondary color"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
                Layout.topMargin: Theme.spacing.medium
            }
            LogosSelectableText {
                Layout.fillWidth: true
                Layout.preferredHeight: 24
                text: "repo/path/to/module"
                color: Theme.palette.textSecondary
            }

            LogosText {
                text: "Composed with LogosCopyButton"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
                Layout.topMargin: Theme.spacing.medium
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.small
                LogosSelectableText {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24
                    text: "QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG"
                    verticalAlignment: TextEdit.AlignVCenter
                }
                LogosCopyButton {
                    value: "QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG"
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
