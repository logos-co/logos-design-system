import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

Rectangle {
    property string figmaUrl: ""

    color: Theme.palette.background

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xxlarge

        ColumnLayout {
            Layout.fillWidth: true
            Layout.maximumWidth: implicitWidth
            spacing: Theme.spacing.tiny

            LogosText {
                text: "LogosTextField"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                Layout.fillWidth: true
                Layout.maximumWidth: Math.ceil(implicitWidth)
                wrapMode: Text.Wrap
                text: "Public API: text, placeholderText, placeholderTextColor, echoMode, validator, readOnly, enabled, textInput"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

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

            GridLayout {
                Layout.fillWidth: true
                Layout.maximumWidth: 140 + columnSpacing + 320
                columns: 2
                columnSpacing: Theme.spacing.large
                rowSpacing: Theme.spacing.large

                LogosText {
                    text: "Empty"
                    Layout.preferredWidth: 140
                    color: Theme.palette.textSecondary
                }
                LogosTextField {
                    placeholderText: "Type something..."
                    Layout.fillWidth: true
                    Layout.maximumWidth: 320
                }

                LogosText {
                    text: "With value"
                    Layout.preferredWidth: 140
                    color: Theme.palette.textSecondary
                }
                LogosTextField {
                    text: "Hello"
                    Layout.fillWidth: true
                    Layout.maximumWidth: 320
                }

                LogosText {
                    text: "Password"
                    Layout.preferredWidth: 140
                    color: Theme.palette.textSecondary
                }
                LogosTextField {
                    text: "supersecret"
                    echoMode: TextInput.Password
                    Layout.fillWidth: true
                    Layout.maximumWidth: 320
                }

                LogosText {
                    text: "Validation"
                    Layout.preferredWidth: 140
                    color: Theme.palette.textSecondary
                }
                LogosTextField {
                    placeholderText: "1 – 100"
                    validator: IntValidator { bottom: 1; top: 100 }
                    Layout.fillWidth: true
                    Layout.maximumWidth: 320
                }

                LogosText {
                    text: "Read-only"
                    Layout.preferredWidth: 140
                    color: Theme.palette.textSecondary
                }
                LogosTextField {
                    text: "Cannot edit this"
                    readOnly: true
                    Layout.fillWidth: true
                    Layout.maximumWidth: 320
                }

                LogosText {
                    text: "Disabled"
                    Layout.preferredWidth: 140
                    color: Theme.palette.textSecondary
                }
                LogosTextField {
                    text: "Unavailable"
                    enabled: false
                    Layout.fillWidth: true
                    Layout.maximumWidth: 320
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
