import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

// Visual rulers for every Theme.spacing.* token. Bar width = the actual pixel
// value; copy the name as `Theme.spacing.<name>`.
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
                    text: "Spacing"
                    font.pixelSize: Theme.typography.titleText
                    font.weight: Theme.typography.weightBold
                    color: Theme.palette.text
                }
                LogosText {
                    text: "Tokens from Spacing.qml. Use as Theme.spacing.<name>."
                    font.pixelSize: Theme.typography.secondaryText
                    color: Theme.palette.textSecondary
                }
            }

            Section {
                title: "Spacing scale"
                items: [
                    { name: "tiny",    value: Theme.spacing.tiny },
                    { name: "small",   value: Theme.spacing.small },
                    { name: "medium",  value: Theme.spacing.medium },
                    { name: "large",   value: Theme.spacing.large },
                    { name: "xlarge",  value: Theme.spacing.xlarge },
                    { name: "xxlarge", value: Theme.spacing.xxlarge }
                ]
                showAsBar: true
            }

            Section {
                title: "Border radius"
                items: [
                    { name: "radiusSmall",  value: Theme.spacing.radiusSmall },
                    { name: "radiusMedium", value: Theme.spacing.radiusMedium },
                    { name: "radiusLarge",  value: Theme.spacing.radiusLarge },
                    { name: "radiusXlarge", value: Theme.spacing.radiusXlarge },
                    { name: "radiusPill",   value: Theme.spacing.radiusPill }
                ]
                showAsBar: false
            }

            Item { Layout.preferredHeight: Theme.spacing.xxlarge }
        }
    }

    component Section: ColumnLayout {
        property string title
        property var items: []
        property bool showAsBar: true

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

        Repeater {
            model: items
            delegate: showAsBar ? barDelegate : radiusDelegate
        }

        Component {
            id: barDelegate
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.large

                LogosText {
                    Layout.preferredWidth: 140
                    text: modelData.name
                    font.pixelSize: Theme.typography.secondaryText
                    font.weight: Theme.typography.weightMedium
                    color: Theme.palette.text
                }
                Rectangle {
                    Layout.preferredWidth: modelData.value
                    Layout.preferredHeight: 16
                    color: Theme.palette.primary
                    radius: 2
                }
                LogosText {
                    text: modelData.value + "px"
                    font.pixelSize: Theme.typography.secondaryText
                    color: Theme.palette.textTertiary
                }
                Item { Layout.fillWidth: true }
            }
        }

        Component {
            id: radiusDelegate
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.large

                LogosText {
                    Layout.preferredWidth: 140
                    text: modelData.name
                    font.pixelSize: Theme.typography.secondaryText
                    font.weight: Theme.typography.weightMedium
                    color: Theme.palette.text
                }
                Rectangle {
                    Layout.preferredWidth: 96
                    Layout.preferredHeight: 48
                    color: Theme.palette.surfaceRaised
                    radius: Math.min(modelData.value, height / 2)
                    border.width: 1
                    border.color: Theme.palette.borderHairline
                }
                LogosText {
                    text: modelData.value + "px"
                    font.pixelSize: Theme.typography.secondaryText
                    color: Theme.palette.textTertiary
                }
                Item { Layout.fillWidth: true }
            }
        }
    }
}
