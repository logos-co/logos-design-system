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
        spacing: Theme.spacing.xlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosDotMatrix"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: pattern, columns, dotSize, dotSpacing, radius, dotColor, "
                      + "inactiveDotColor, activeOpacity, inactiveOpacity, trailOpacity, animated, "
                      + "animationInterval. Read-only: ringPattern, rows, gridItem."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        LogosText {
            text: "States"
            font.pixelSize: Theme.typography.subtitleText
            color: Theme.palette.text
        }

        RowLayout {
            spacing: Theme.spacing.xxlarge

            ColumnLayout {
                spacing: Theme.spacing.small
                LogosDotMatrix {
                    pattern: ringPattern
                    dotColor: Theme.palette.success
                }
                LogosText {
                    text: "Running"
                    font.pixelSize: Theme.typography.secondaryText
                    color: Theme.palette.textSecondary
                }
            }

            ColumnLayout {
                spacing: Theme.spacing.small
                LogosDotMatrix {
                    pattern: ringPattern
                    dotColor: Theme.palette.textMuted
                }
                LogosText {
                    text: "Stopped"
                    font.pixelSize: Theme.typography.secondaryText
                    color: Theme.palette.textSecondary
                }
            }

            ColumnLayout {
                spacing: Theme.spacing.small
                LogosDotMatrix {
                    animated: true
                    dotColor: Theme.palette.warning
                }
                LogosText {
                    text: "Starting (ripple)"
                    font.pixelSize: Theme.typography.secondaryText
                    color: Theme.palette.textSecondary
                }
            }
        }

        LogosText {
            text: "Try it"
            font.pixelSize: Theme.typography.subtitleText
            color: Theme.palette.text
        }

        RowLayout {
            spacing: Theme.spacing.xxlarge
            Layout.fillWidth: true

            LogosDotMatrix {
                id: knobbed
                pattern: ringPattern
                columns: columnsSlider.value
                dotSize: sizeSlider.value
                dotSpacing: spacingSlider.value
                animated: animatedSwitch.checked
                dotColor: Theme.palette.primary
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.small

                LogosSwitch {
                    id: animatedSwitch
                    text: "animated"
                }

                RowLayout {
                    spacing: Theme.spacing.small
                    LogosText {
                        text: "columns " + knobbed.columns
                        color: Theme.palette.textSecondary
                        font.pixelSize: Theme.typography.secondaryText
                    }
                    LogosSlider {
                        id: columnsSlider
                        Layout.fillWidth: true
                        from: 3; to: 9; stepSize: 2; value: 5
                    }
                }

                RowLayout {
                    spacing: Theme.spacing.small
                    LogosText {
                        text: "dotSize " + knobbed.dotSize
                        color: Theme.palette.textSecondary
                        font.pixelSize: Theme.typography.secondaryText
                    }
                    LogosSlider {
                        id: sizeSlider
                        Layout.fillWidth: true
                        from: 4; to: 20; stepSize: 1; value: 8
                    }
                }

                RowLayout {
                    spacing: Theme.spacing.small
                    LogosText {
                        text: "dotSpacing " + knobbed.dotSpacing
                        color: Theme.palette.textSecondary
                        font.pixelSize: Theme.typography.secondaryText
                    }
                    LogosSlider {
                        id: spacingSlider
                        Layout.fillWidth: true
                        from: 0; to: 12; stepSize: 1; value: 4
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
