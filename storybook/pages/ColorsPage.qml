import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

// Visual catalog of every named color token in DarkTheme.qml. Names match the
// property names so consumers can copy-paste `Theme.palette.<name>` directly.
Rectangle {
    // Set to the Figma frame URL for this page; empty hides "Open in Figma".
    property string figmaUrl: ""

    color: Theme.palette.background

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: Theme.spacing.xxlarge

            Item { Layout.preferredHeight: Theme.spacing.large }

            ColumnLayout {
                Layout.leftMargin: Theme.spacing.xxlarge
                Layout.rightMargin: Theme.spacing.xxlarge
                spacing: Theme.spacing.tiny

                LogosText {
                    text: "Colors"
                    font.pixelSize: Theme.typography.titleText
                    font.weight: Theme.typography.weightBold
                    color: Theme.palette.text
                }
                LogosText {
                    text: "Tokens from DarkTheme.qml. Use as Theme.palette.<name>."
                    font.pixelSize: Theme.typography.secondaryText
                    color: Theme.palette.textSecondary
                }
            }

            Section {
                title: "Backgrounds"
                items: [
                    { name: "background",          value: Theme.palette.background },
                    { name: "backgroundSecondary", value: Theme.palette.backgroundSecondary },
                    { name: "backgroundTertiary",  value: Theme.palette.backgroundTertiary },
                    { name: "backgroundElevated",  value: Theme.palette.backgroundElevated },
                    { name: "backgroundMuted",     value: Theme.palette.backgroundMuted },
                    { name: "backgroundInset",     value: Theme.palette.backgroundInset },
                    { name: "backgroundButton",    value: Theme.palette.backgroundButton },
                    { name: "backgroundBlack",     value: Theme.palette.backgroundBlack }
                ]
            }

            Section {
                title: "Surfaces"
                items: [
                    { name: "surface",       value: Theme.palette.surface },
                    { name: "surfaceRaised", value: Theme.palette.surfaceRaised }
                ]
            }

            Section {
                title: "Text"
                items: [
                    { name: "text",            value: Theme.palette.text },
                    { name: "textSecondary",   value: Theme.palette.textSecondary },
                    { name: "textTertiary",    value: Theme.palette.textTertiary },
                    { name: "textPlaceholder", value: Theme.palette.textPlaceholder },
                    { name: "textMuted",       value: Theme.palette.textMuted }
                ]
            }

            Section {
                title: "Borders"
                items: [
                    { name: "border",              value: Theme.palette.border },
                    { name: "borderSecondary",     value: Theme.palette.borderSecondary },
                    { name: "borderTertiary",      value: Theme.palette.borderTertiary },
                    { name: "borderTertiaryMuted", value: Theme.palette.borderTertiaryMuted },
                    { name: "borderSubtle",        value: Theme.palette.borderSubtle },
                    { name: "borderHairline",      value: Theme.palette.borderHairline },
                    { name: "borderInteractive",   value: Theme.palette.borderInteractive },
                    { name: "borderDark",          value: Theme.palette.borderDark }
                ]
            }

            Section {
                title: "Primary (accent)"
                items: [
                    { name: "primary",        value: Theme.palette.primary },
                    { name: "primaryHover",   value: Theme.palette.primaryHover },
                    { name: "primaryPressed", value: Theme.palette.primaryPressed },
                    { name: "primarySoft",    value: Theme.palette.primarySoft }
                ]
            }

            Section {
                title: "Status"
                items: [
                    { name: "success",        value: Theme.palette.success },
                    { name: "successHover",   value: Theme.palette.successHover },
                    { name: "successPressed", value: Theme.palette.successPressed },
                    { name: "error",          value: Theme.palette.error },
                    { name: "errorHover",     value: Theme.palette.errorHover },
                    { name: "errorPressed",   value: Theme.palette.errorPressed },
                    { name: "warning",        value: Theme.palette.warning },
                    { name: "warningHover",   value: Theme.palette.warningHover },
                    { name: "info",           value: Theme.palette.info },
                    { name: "notification",   value: Theme.palette.notification }
                ]
            }

            Section {
                title: "Accents"
                items: [
                    { name: "accentOrange",      value: Theme.palette.accentOrange },
                    { name: "accentOrangeMid",   value: Theme.palette.accentOrangeMid },
                    { name: "accentOrangeDeep",  value: Theme.palette.accentOrangeDeep },
                    { name: "accentBurntOrange", value: Theme.palette.accentBurntOrange },
                    { name: "accentYellowSoft",  value: Theme.palette.accentYellowSoft }
                ]
            }

            Section {
                title: "Interactive states"
                items: [
                    { name: "hover",    value: Theme.palette.hover },
                    { name: "pressed",  value: Theme.palette.pressed },
                    { name: "disabled", value: Theme.palette.disabled },
                    { name: "focus",    value: Theme.palette.focus }
                ]
            }

            Section {
                title: "Overlays"
                items: [
                    { name: "glassOverlay",  value: Theme.palette.glassOverlay },
                    { name: "glassStrong",   value: Theme.palette.glassStrong },
                    { name: "overlayDark",   value: Theme.palette.overlayDark },
                    { name: "overlayLight",  value: Theme.palette.overlayLight },
                    { name: "overlayOrange", value: Theme.palette.overlayOrange }
                ]
            }

            Item { Layout.preferredHeight: Theme.spacing.xxlarge }
        }
    }

    component Section: ColumnLayout {
        property string title
        property var items: []

        Layout.fillWidth: true
        Layout.leftMargin: Theme.spacing.xxlarge
        Layout.rightMargin: Theme.spacing.xxlarge
        spacing: Theme.spacing.medium

        LogosText {
            text: title
            font.pixelSize: Theme.typography.primaryText
            font.weight: Theme.typography.weightBold
            color: Theme.palette.text
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.palette.borderHairline
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 4
            columnSpacing: Theme.spacing.medium
            rowSpacing: Theme.spacing.medium

            Repeater {
                model: items
                Swatch {
                    Layout.fillWidth: true
                    name: modelData.name
                    value: modelData.value
                }
            }
        }
    }

    component Swatch: ColumnLayout {
        property string name
        property color value

        spacing: Theme.spacing.small

        Rectangle {
            Layout.fillWidth: true
            height: 72
            color: parent.value
            radius: Theme.spacing.radiusLarge
            border.width: 1
            border.color: Theme.palette.borderHairline
        }

        ColumnLayout {
            spacing: 2

            LogosText {
                text: parent.parent.name
                font.pixelSize: Theme.typography.secondaryText
                font.weight: Theme.typography.weightMedium
                color: Theme.palette.text
            }
            LogosText {
                text: Qt.colorEqual(parent.parent.value, "transparent")
                      ? "transparent"
                      : parent.parent.value.toString()
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
            }
        }
    }
}
