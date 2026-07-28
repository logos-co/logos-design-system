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
                text: "LogosCopyButton"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: value, size, iconSize, feedbackDuration, feedbackText, recentlyCopied, copy(), copied(value), clicked()"
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
            LogosText {
                text: "Ghost icon (no pill/border). After copy, a \"Copied\" LogosToolTip floats above the icon for the feedback duration."
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

            RowLayout {
                spacing: Theme.spacing.large

                ColumnLayout {
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: "Default"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosCopyButton {
                        value: "QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG"
                    }
                }
                ColumnLayout {
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: "Disabled"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosCopyButton {
                        value: "disabled-value"
                        enabled: false
                    }
                }
                ColumnLayout {
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: "Larger hit target"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosCopyButton {
                        value: "larger-hit"
                        size: 32
                        iconSize: 20
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
