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
                text: "LogosProgressBar"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: ProgressBar (from, to, value, indeterminate) + trackColor, fillColor. Aliases: backgroundItem, fillItem."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        ColumnLayout {
            spacing: Theme.spacing.medium
            Layout.fillWidth: true

            LogosText { text: "0% / 25% / 60% / 100%"; color: Theme.palette.textSecondary }
            LogosProgressBar { Layout.fillWidth: true; from: 0; to: 1; value: 0 }
            LogosProgressBar { Layout.fillWidth: true; from: 0; to: 1; value: 0.25 }
            LogosProgressBar { Layout.fillWidth: true; from: 0; to: 1; value: 0.6 }
            LogosProgressBar { Layout.fillWidth: true; from: 0; to: 1; value: 1.0 }

            LogosText { text: "Indeterminate"; color: Theme.palette.textSecondary; Layout.topMargin: Theme.spacing.medium }
            LogosProgressBar { Layout.fillWidth: true; indeterminate: true }

            LogosText {
                text: "Animated 0% → 100% over 10s"
                color: Theme.palette.textSecondary
                Layout.topMargin: Theme.spacing.medium
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.medium

                LogosProgressBar {
                    id: demoBar
                    Layout.fillWidth: true
                    from: 0
                    to: 1
                    value: 0

                    NumberAnimation on value {
                        id: demoAnim
                        from: 0
                        to: 1
                        duration: 10000
                        running: false
                    }
                }

                LogosText {
                    text: Math.round(demoBar.value * 100) + "%"
                    color: Theme.palette.text
                    Layout.preferredWidth: 50
                    horizontalAlignment: Text.AlignRight
                }

                LogosButton {
                    text: demoAnim.running ? "Stop" : "Play"
                    implicitWidth: 80
                    implicitHeight: 32
                    onClicked: {
                        if (demoAnim.running) {
                            demoAnim.stop()
                            demoBar.value = 0
                        } else {
                            demoBar.value = 0
                            demoAnim.start()
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
