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
            spacing: Theme.spacing.tiny

            LogosText {
                text: "LogosTextField"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: text, placeholderText, placeholderTextColor, echoMode, textInput"
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
                    Layout.preferredWidth: 320
                }

                LogosText {
                    text: "With value"
                    Layout.preferredWidth: 140
                    color: Theme.palette.textSecondary
                }
                LogosTextField {
                    text: "Hello"
                    Layout.preferredWidth: 320
                }

                LogosText {
                    text: "Password"
                    Layout.preferredWidth: 140
                    color: Theme.palette.textSecondary
                }
                LogosTextField {
                    text: "supersecret"
                    echoMode: TextInput.Password
                    Layout.preferredWidth: 320
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
