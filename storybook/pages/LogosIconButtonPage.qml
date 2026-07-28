import QtQuick
import QtQuick.Controls
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
        spacing: Theme.spacing.xxlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny

            LogosText {
                text: "LogosIconButton"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: iconSource, iconColor, size, iconSize, flat, pressed, enabled, clicked()"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            LogosText {
                text: "Pill-shaped icon-only button. Hover/focus softens the fill; press uses a stronger fill so it reads apart from hover (same idea as LogosButton). Set flat for a ghost variant with no pill/border (e.g. LogosCopyButton)."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        // States
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
                        text: "Refresh"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosIconButton {
                        iconSource: LogosIcons.refresh
                    }
                }
                ColumnLayout {
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: "Install"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosIconButton {
                        iconSource: LogosIcons.install
                    }
                }
                ColumnLayout {
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: "Delete"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosIconButton {
                        iconSource: LogosIcons.trash
                    }
                }
                ColumnLayout {
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: "More"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosIconButton {
                        iconSource: LogosIcons.more
                    }
                }
                ColumnLayout {
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: "Tinted (accent)"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosIconButton {
                        iconColor: Theme.palette.accentOrange
                        iconSource: LogosIcons.refresh
                    }
                }
                ColumnLayout {
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: "Flat (ghost)"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosIconButton {
                        flat: true
                        iconSource: LogosIcons.refresh
                    }
                }
                ColumnLayout {
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: "Disabled"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosIconButton {
                        enabled: false
                        iconSource: LogosIcons.refresh
                    }
                }
            }
        }

        // Try it
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Try it"
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

                LogosIconButton {
                    id: liveButton
                    iconSource: LogosIcons.refresh
                    enabled: !disableSwitch.checked
                    flat: flatSwitch.checked
                    size: sizeSpin.value
                    iconSize: iconSizeSpin.value
                    onClicked: clickCount.value++
                }

                ColumnLayout {
                    spacing: Theme.spacing.small

                    RowLayout {
                        spacing: Theme.spacing.small
                        LogosText {
                            text: "size:"; Layout.preferredWidth: 100
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textSecondary
                        }
                        SpinBox { id: sizeSpin; from: 24; to: 64; value: 40 }
                    }
                    RowLayout {
                        spacing: Theme.spacing.small
                        LogosText {
                            text: "iconSize:"; Layout.preferredWidth: 100
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textSecondary
                        }
                        SpinBox { id: iconSizeSpin; from: 12; to: 32; value: 20 }
                    }
                    RowLayout {
                        spacing: Theme.spacing.small
                        Switch { id: flatSwitch }
                        LogosText {
                            text: "Flat"
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textSecondary
                        }
                    }
                    RowLayout {
                        spacing: Theme.spacing.small
                        Switch { id: disableSwitch }
                        LogosText {
                            text: "Disabled"
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textSecondary
                        }
                    }
                    RowLayout {
                        spacing: Theme.spacing.small
                        LogosText {
                            text: "Click count:"
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textSecondary
                        }
                        LogosText {
                            id: clickCount
                            property int value: 0
                            text: value
                            font.pixelSize: Theme.typography.secondaryText
                            font.weight: Theme.typography.weightBold
                            color: Theme.palette.text
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
