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
                text: "LogosIcon"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: source, color, brightness"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            LogosText {
                text: "Standalone tinted icon. The asset is recolored at render time via MultiEffect, so the same SVG/PNG can be reused across themes and states. Set brightness to 1.0 when tinting grey or black third-party icons on colored app tiles."
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
                text: "Tints"
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
                        text: "text"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosIcon { source: LogosIcons.refresh }
                }
                ColumnLayout {
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: "textTertiary"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosIcon {
                        source: LogosIcons.refresh
                        color: Theme.palette.textTertiary
                    }
                }
                ColumnLayout {
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: "accentOrange"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosIcon {
                        source: LogosIcons.refresh
                        color: Theme.palette.accentOrange
                    }
                }
                ColumnLayout {
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: "info"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosIcon {
                        source: LogosIcons.refresh
                        color: Theme.palette.info
                    }
                }
            }
        }

        // Sizes
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Sizes"
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
                        text: "16"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosIcon { source: LogosIcons.refresh; width: 16; height: 16 }
                }
                ColumnLayout {
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: "20 (default)"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosIcon { source: LogosIcons.refresh }
                }
                ColumnLayout {
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: "32"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosIcon { source: LogosIcons.refresh; width: 32; height: 32 }
                }
                ColumnLayout {
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: "48"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosIcon { source: LogosIcons.refresh; width: 48; height: 48 }
                }
            }
        }

        // Package icons on colored tiles — brightness normalizes grey assets before tinting.
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Package icons (brightness)"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.palette.borderHairline
            }
            LogosText {
                text: "Design-system icons are neutral grey silhouettes and tint with color alone. Third-party package icons are often darker; brightness: 1.0 lifts them to white before colorization — the pattern used on Basecamp app tiles."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: Theme.spacing.xlarge

                Repeater {
                    model: [
                        { label: "brightness: 0",  brightness: 0,   tile: Theme.palette.info },
                        { label: "brightness: 1.0", brightness: 1.0, tile: Theme.palette.info },
                        { label: "brightness: 1.0", brightness: 1.0, tile: Theme.palette.accentOrange },
                    ]

                    delegate: ColumnLayout {
                        required property var modelData

                        spacing: Theme.spacing.tiny

                        LogosText {
                            text: modelData.label
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textTertiary
                        }
                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 80
                            radius: Theme.spacing.radiusXlarge
                            color: modelData.tile

                            LogosIcon {
                                anchors.centerIn: parent
                                source: LogosIcons.refresh
                                color: Theme.palette.text
                                brightness: modelData.brightness
                                width: 40
                                height: 40
                            }
                        }
                        LogosText {
                            text: modelData.tile === Theme.palette.info
                                  ? "blue tile"
                                  : "orange tile"
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textTertiary
                            visible: modelData.brightness === 1.0
                        }
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

                Rectangle {
                    Layout.preferredWidth: sizeSpin.value + 40
                    Layout.preferredHeight: sizeSpin.value + 40
                    radius: Theme.spacing.radiusXlarge
                    color: tileColorCombo.currentColor

                    LogosIcon {
                        id: liveIcon
                        anchors.centerIn: parent
                        source: LogosIcons.refresh
                        width: sizeSpin.value
                        height: sizeSpin.value
                        color: tintCombo.currentColor
                        brightness: brightnessCheck.checked ? 1.0 : 0
                    }
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
                        SpinBox { id: sizeSpin; from: 12; to: 96; value: 40 }
                    }
                    RowLayout {
                        spacing: Theme.spacing.small
                        LogosText {
                            text: "color:"; Layout.preferredWidth: 100
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textSecondary
                        }
                        ComboBox {
                            id: tintCombo
                            property var swatches: [
                                { label: "text",          value: Theme.palette.text },
                                { label: "textTertiary",  value: Theme.palette.textTertiary },
                                { label: "accentOrange",  value: Theme.palette.accentOrange },
                                { label: "info",          value: Theme.palette.info },
                            ]
                            readonly property color currentColor:
                                swatches[Math.max(0, currentIndex)].value
                            model: swatches.map(function(s) { return s.label })
                            currentIndex: 0
                        }
                    }
                    RowLayout {
                        spacing: Theme.spacing.small
                        LogosText {
                            text: "tile:"; Layout.preferredWidth: 100
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textSecondary
                        }
                        ComboBox {
                            id: tileColorCombo
                            property var swatches: [
                                { label: "info",          value: Theme.palette.info },
                                { label: "accentOrange",  value: Theme.palette.accentOrange },
                                { label: "success",       value: Theme.palette.success },
                                { label: "warning",       value: Theme.palette.warning },
                            ]
                            readonly property color currentColor:
                                swatches[Math.max(0, currentIndex)].value
                            model: swatches.map(function(s) { return s.label })
                            currentIndex: 0
                        }
                    }
                    RowLayout {
                        spacing: Theme.spacing.small
                        LogosText {
                            text: "brightness:"; Layout.preferredWidth: 100
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textSecondary
                        }
                        CheckBox {
                            id: brightnessCheck
                            text: "1.0 (package icon mode)"
                            checked: true
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
