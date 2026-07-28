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
                text: "LogosLink"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: text, href, linkColor, hoverColor, underline, elide, activate(), activated(href). Tab focuses; hold Space/Enter for pressed, release to activate."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
            LogosText {
                text: "Link chrome for navigation. Emits activated only — never copies, never opens URLs. Handle activated to open/navigate. Use LogosCopyButton / LogosCopyableText for clipboard values."
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
                text: "Default (handle activated to open)"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
            }
            LogosLink {
                text: "https://logos.co"
                href: "https://logos.co"
                onActivated: function(url) { statusLabel.text = "activated: " + url }
            }
            LogosText {
                id: statusLabel
                text: "Click the link above"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textMuted
            }

            LogosText {
                text: "In-app navigation"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
                Layout.topMargin: Theme.spacing.medium
            }
            LogosLink {
                text: "Open settings"
                onActivated: statusLabel.text = "activated (in-app)"
            }

            LogosText {
                text: "Underline on hover only"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
                Layout.topMargin: Theme.spacing.medium
            }
            LogosLink {
                text: "Hover me"
                href: "https://example.com"
                underline: false
            }

            LogosText {
                text: "Custom colors (info)"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
                Layout.topMargin: Theme.spacing.medium
            }
            LogosLink {
                text: "Info-colored link"
                href: "https://example.com"
                linkColor: Theme.palette.info
                hoverColor: Theme.palette.successHover
            }

            LogosText {
                text: "Disabled"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
                Layout.topMargin: Theme.spacing.medium
            }
            LogosLink {
                text: "Unavailable"
                href: "https://example.com"
                enabled: false
            }

            LogosText {
                text: "Inline with body text"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
                Layout.topMargin: Theme.spacing.medium
            }
            RowLayout {
                spacing: Theme.spacing.tiny
                LogosText {
                    text: "See the"
                    color: Theme.palette.text
                }
                LogosLink {
                    text: "documentation"
                    href: "https://example.com/docs"
                    onActivated: function(url) { statusLabel.text = "activated: " + url }
                }
                LogosText {
                    text: "for details."
                    color: Theme.palette.text
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
