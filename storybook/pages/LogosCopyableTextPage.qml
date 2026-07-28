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
                text: "LogosCopyableText"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: text, copyText, showCopyButton, textColor, buttonSize, iconSize, feedbackDuration, feedbackText, recentlyCopied, copy(), copied(value)"
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
            LogosText {
                text: "Convenience row: LogosSelectableText + LogosCopyButton. Drag the text to select; click the button to copy. Prefer the primitives for custom layouts."
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
                text: "Default"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
            }
            LogosCopyableText {
                Layout.fillWidth: true
                text: "QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG"
            }

            LogosText {
                text: "Display short, copy full value"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
                Layout.topMargin: Theme.spacing.medium
            }
            LogosCopyableText {
                Layout.preferredWidth: 280
                text: "QmYwAP…PbdG"
                copyText: "QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG"
            }

            LogosText {
                text: "Without copy button (select + Cmd/Ctrl+C only)"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
                Layout.topMargin: Theme.spacing.medium
            }
            LogosCopyableText {
                Layout.fillWidth: true
                text: "select-me-manually"
                showCopyButton: false
            }

            LogosText {
                text: "Disabled"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
                Layout.topMargin: Theme.spacing.medium
            }
            LogosCopyableText {
                Layout.fillWidth: true
                text: "cannot-copy-when-disabled"
                enabled: false
            }

            LogosText {
                text: "Secondary color"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
                Layout.topMargin: Theme.spacing.medium
            }
            LogosCopyableText {
                Layout.fillWidth: true
                text: "repo/path/to/module"
                textColor: Theme.palette.textSecondary
            }
        }

        Item { Layout.fillHeight: true }
    }
}
