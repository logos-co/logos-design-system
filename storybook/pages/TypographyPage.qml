import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

// Visual sample of each Theme.typography.* size + weight.
Rectangle {
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
                    text: "Typography"
                    font.pixelSize: Theme.typography.titleText
                    font.weight: Theme.typography.weightBold
                    color: Theme.palette.text
                }
                LogosText {
                    text: "Tokens from Typography.qml. Use as Theme.typography.<name>."
                    font.pixelSize: Theme.typography.secondaryText
                    color: Theme.palette.textSecondary
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spacing.xxlarge
                Layout.rightMargin: Theme.spacing.xxlarge
                spacing: Theme.spacing.medium

                LogosText {
                    text: "Sizes"
                    font.pixelSize: Theme.typography.primaryText
                    font.weight: Theme.typography.weightBold
                    color: Theme.palette.text
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.palette.borderHairline
                }

                Repeater {
                    model: [
                        { name: "titleText",     value: Theme.typography.titleText },
                        { name: "primaryText",   value: Theme.typography.primaryText },
                        { name: "secondaryText", value: Theme.typography.secondaryText }
                    ]
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.large

                        LogosText {
                            Layout.preferredWidth: 160
                            text: modelData.name + " (" + modelData.value + "px)"
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textTertiary
                        }
                        LogosText {
                            text: "The quick brown fox"
                            font.pixelSize: modelData.value
                            color: Theme.palette.text
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spacing.xxlarge
                Layout.rightMargin: Theme.spacing.xxlarge
                spacing: Theme.spacing.medium

                LogosText {
                    text: "Weights"
                    font.pixelSize: Theme.typography.primaryText
                    font.weight: Theme.typography.weightBold
                    color: Theme.palette.text
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.palette.borderHairline
                }

                Repeater {
                    model: [
                        { name: "weightRegular", value: Theme.typography.weightRegular },
                        { name: "weightMedium",  value: Theme.typography.weightMedium },
                        { name: "weightBold",    value: Theme.typography.weightBold }
                    ]
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.large

                        LogosText {
                            Layout.preferredWidth: 160
                            text: modelData.name + " (" + modelData.value + ")"
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textTertiary
                        }
                        LogosText {
                            text: "The quick brown fox jumps"
                            font.pixelSize: Theme.typography.primaryText
                            font.weight: modelData.value
                            color: Theme.palette.text
                        }
                    }
                }
            }

            Item { Layout.preferredHeight: Theme.spacing.xxlarge }
        }
    }
}
