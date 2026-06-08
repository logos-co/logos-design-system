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
                text: "Public API: source, color"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            LogosText {
                text: "Standalone tinted icon. The asset is recolored at render time via MultiEffect, so the same SVG/PNG can be reused across themes and states."
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

                LogosIcon {
                    id: liveIcon
                    source: LogosIcons.refresh
                    width: sizeSpin.value
                    height: sizeSpin.value
                    color: tintCombo.currentColor
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
                        SpinBox { id: sizeSpin; from: 12; to: 96; value: 24 }
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
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
