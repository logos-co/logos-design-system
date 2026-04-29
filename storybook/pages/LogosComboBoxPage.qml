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
                text: "LogosComboBox"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: model, currentIndex, currentText, displayText, textRole, placeholderText, activated(int), accepted()"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        // Variants
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Variants"
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
                        text: "Default"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosComboBox {
                        Layout.preferredWidth: 200
                        model: ["Stable", "Beta", "Nightly", "Custom"]
                        currentIndex: 0
                    }
                }

                ColumnLayout {
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: "With placeholder (no selection)"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosComboBox {
                        Layout.preferredWidth: 200
                        model: ["Files", "Images", "Videos"]
                        currentIndex: -1
                        placeholderText: "Pick a category..."
                    }
                }

                ColumnLayout {
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: "Disabled"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosComboBox {
                        Layout.preferredWidth: 200
                        model: ["a", "b", "c"]
                        currentIndex: 0
                        enabled: false
                    }
                }
            }
        }

        // Object model with textRole
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Object model + textRole"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.palette.borderHairline
            }

            LogosText {
                text: "When the model is a list of objects, set textRole to the property whose value should display."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            LogosComboBox {
                Layout.preferredWidth: 240
                textRole: "label"
                model: [
                    { label: "Apples", id: 1 },
                    { label: "Bananas", id: 2 },
                    { label: "Cherries", id: 3 }
                ]
                currentIndex: 0
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

                LogosComboBox {
                    id: tryBox
                    Layout.preferredWidth: 220
                    model: itemsModel.text.split(",").map(function(s) { return s.trim() }).filter(function(s) { return s.length > 0 })
                    currentIndex: -1
                    placeholderText: placeholderInput.text || "(empty placeholder)"
                    enabled: !disableSwitch.checked
                    onActivated: function(index) {
                        activationCount.value++
                        lastActivated.text = "last activated: index " + index + " (\"" + tryBox.currentText + "\")"
                    }
                }

                ColumnLayout {
                    spacing: Theme.spacing.small

                    RowLayout {
                        spacing: Theme.spacing.small
                        LogosText {
                            text: "model (CSV):"
                            Layout.preferredWidth: 140
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textSecondary
                        }
                        LogosTextField {
                            id: itemsModel
                            text: "alpha, beta, gamma"
                            implicitWidth: 280
                        }
                    }
                    RowLayout {
                        spacing: Theme.spacing.small
                        LogosText {
                            text: "placeholderText:"
                            Layout.preferredWidth: 140
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textSecondary
                        }
                        LogosTextField {
                            id: placeholderInput
                            text: "Choose…"
                            implicitWidth: 240
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
                            text: "activated count:"
                            Layout.preferredWidth: 140
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textSecondary
                        }
                        LogosText {
                            id: activationCount
                            property int value: 0
                            text: value
                            font.pixelSize: Theme.typography.secondaryText
                            font.weight: Theme.typography.weightBold
                            color: Theme.palette.text
                        }
                    }
                    LogosText {
                        id: lastActivated
                        text: "(no activation yet)"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
