import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

// Catalog page for LogosTabBar + LogosTabButton (the bar owns the sliding
// indicator, buttons render text + optional icon).
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
                text: "LogosTabBar"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: indicatorColor, indicatorHeight, animationDuration. "
                      + "Use with LogosTabButton."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        // Default look
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Default"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.palette.borderHairline
            }

            LogosTabBar {
                Layout.preferredWidth: 480

                LogosTabButton { text: "Files" }
                LogosTabButton { text: "Images" }
                LogosTabButton { text: "Videos" }
                LogosTabButton { text: "Documents" }
            }
        }

        // Configurable indicator
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Configurable indicator"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.palette.borderHairline
            }

            LogosTabBar {
                Layout.preferredWidth: 480
                indicatorColor: indicatorColorPicker.checked
                                ? Theme.palette.success
                                : Theme.palette.primary
                indicatorHeight: heightSlider.value
                animationDuration: durationSlider.value

                LogosTabButton { text: "One" }
                LogosTabButton { text: "Two" }
                LogosTabButton { text: "Three" }
            }

            ColumnLayout {
                spacing: Theme.spacing.small

                RowLayout {
                    spacing: Theme.spacing.small
                    LogosText {
                        Layout.preferredWidth: 160
                        text: "indicatorHeight: " + heightSlider.value.toFixed(0)
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                    Slider {
                        id: heightSlider
                        from: 1; to: 8; value: 3; stepSize: 1
                        Layout.preferredWidth: 240
                    }
                }
                RowLayout {
                    spacing: Theme.spacing.small
                    LogosText {
                        Layout.preferredWidth: 160
                        text: "animationDuration: " + durationSlider.value.toFixed(0) + "ms"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                    Slider {
                        id: durationSlider
                        from: 0; to: 1000; value: 200; stepSize: 50
                        Layout.preferredWidth: 240
                    }
                }
                RowLayout {
                    spacing: Theme.spacing.small
                    Switch { id: indicatorColorPicker }
                    LogosText {
                        text: "Use success color for indicator"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
