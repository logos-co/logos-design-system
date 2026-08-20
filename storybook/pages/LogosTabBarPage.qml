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
                text: "Public API: indicatorColor, indicatorHeight, animationDuration, trackColor. "
                      + "Use with LogosTabButton. Selected tab uses the solid indicator; "
                      + "a low-opacity track runs under all tabs."
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

        // Nested bar inside a StackLayout page — the case that broke in the wallet.
        // A bar laid out while its page is hidden measures its current item at zero
        // width; if it then never gets currentItemChanged or widthChanged when the
        // page is shown, the indicator keeps that stale position and (before the
        // background was clipped) painted outside the bar entirely, over whatever
        // sat beside it. Switch to "Bridge" and the inner indicator must sit under
        // "Withdraw", inside the bar.
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Nested in a StackLayout (indicator must be correct on first reveal)"
                color: Theme.palette.textSecondary
            }

            LogosTabBar {
                id: outerBar
                Layout.fillWidth: true
                LogosTabButton { text: "Transfer" }
                LogosTabButton { text: "Bridge" }
            }

            StackLayout {
                Layout.fillWidth: true
                currentIndex: outerBar.currentIndex

                ColumnLayout {
                    LogosTabBar {
                        Layout.fillWidth: true
                        LogosTabButton { text: "Public" }
                        LogosTabButton { text: "Private" }
                    }
                    Item { Layout.fillHeight: true }
                }

                // Mirrors BridgePanel's actual shape in the wallet: a plain Item as
                // the StackLayout page, with an anchors-filled ColumnLayout inside
                // it holding the bar. The wrapper is the part that differs from the
                // sibling page above, and it is where the geometry timing changes.
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        LogosTabBar {
                            id: innerBridgeBar
                            Layout.fillWidth: true
                            spacing: Theme.spacing.small
                            LogosTabButton { text: "Withdraw" }
                            LogosTabButton { text: "Claim Deposit" }
                        }
                        Item { Layout.fillHeight: true }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
