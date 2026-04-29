import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

// Catalog page for LogosButton. Shows the public API states + a knobs panel
// underneath so reviewers can poke the component without code.
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
                text: "LogosButton"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: text, enabled, clicked()"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        // States row
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

                LogosButton {
                    text: "Default"
                    implicitWidth: 160
                    implicitHeight: 50
                }
                LogosButton {
                    text: "Disabled"
                    implicitWidth: 160
                    implicitHeight: 50
                    enabled: false
                }
            }
        }

        // Interactive knobs
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

                LogosButton {
                    id: liveButton
                    text: textInput.text || "Live button"
                    enabled: !disableSwitch.checked
                    implicitWidth: 200
                    implicitHeight: 50
                    onClicked: clickCount.value++
                }

                ColumnLayout {
                    spacing: Theme.spacing.small

                    RowLayout {
                        spacing: Theme.spacing.small
                        LogosText {
                            text: "Label:"
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textSecondary
                        }
                        LogosTextField {
                            id: textInput
                            text: "Live button"
                            implicitWidth: 200
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
