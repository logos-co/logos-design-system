import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

Rectangle {
    property string figmaUrl: ""

    color: Theme.palette.background

    // Lets the storybook's own Flickable scroll the page.
    implicitHeight: contentColumn.implicitHeight + 2 * Theme.spacing.xxlarge

    // The dropdown only measures its entries while it is open, so the numbers
    // mean nothing until then.
    // Fixed width on purpose: the text changes length when the dropdown opens,
    // and a readout that resized would shuffle every column in the row.
    component WidthReadout: LogosText {
        property var target

        Layout.preferredWidth: 240
        text: target.popupItem.visible
              ? "control " + Math.round(target.width)
                + "  →  dropdown " + Math.round(target.popupItem.width)
              : "control " + Math.round(target.width) + "  →  open to measure"
        font.pixelSize: Theme.typography.secondaryText
        font.family: Theme.typography.mono
        color: Theme.palette.textTertiary
        elide: Text.ElideRight
    }

    component HeightReadout: LogosText {
        property var target

        Layout.preferredWidth: 240
        text: target.popupItem.visible
              ? "rows " + Math.round(target.popupListView.contentHeight)
                + "  →  dropdown " + Math.round(target.popupItem.height)
              : target.count + " entries  →  open to measure"
        font.pixelSize: Theme.typography.secondaryText
        font.family: Theme.typography.mono
        color: Theme.palette.textTertiary
        elide: Text.ElideRight
    }

    ColumnLayout {
        id: contentColumn

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
                text: "Public API: model, currentIndex, currentText, displayText, textRole, placeholderText, maxPopupWidthFactor, activated(int), accepted()"
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

        // Dropdown width
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Dropdown size"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.palette.borderHairline
            }

            LogosText {
                text: "The closed control keeps whatever width it was given and elides. The dropdown takes max(control, widest entry + padding), bounded by maxPopupWidthFactor times the control, and grows to the height of its rows until it reaches the window, after which it scrolls. Open each one — the readout measures the live popup."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: Theme.spacing.large

                ColumnLayout {
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: "Entries wider than the control"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosComboBox {
                        id: growBox
                        Layout.preferredWidth: 140
                        model: ["1.0.0", "2.0.0-32.gf8ab37c1 (nightly)", "0.9.1-rc.4"]
                        currentIndex: 1
                    }
                    WidthReadout { target: growBox }
                }

                ColumnLayout {
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: "Clamped at maxPopupWidthFactor"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosComboBox {
                        id: clampBox
                        Layout.preferredWidth: 140
                        maxPopupWidthFactor: factorSlider.value
                        model: ["1.0.0",
                                "an entry so long that even three times the width of the control is not enough to show all of it",
                                "0.9.1-rc.4"]
                        currentIndex: 1
                    }
                    RowLayout {
                        spacing: Theme.spacing.small
                        LogosSlider {
                            id: factorSlider
                            Layout.preferredWidth: 110
                            from: 1; to: 4; stepSize: 0.25; value: 3
                            snapMode: LogosSlider.SnapAlways
                        }
                        LogosText {
                            text: "×" + factorSlider.value.toFixed(2)
                            font.pixelSize: Theme.typography.secondaryText
                            font.family: Theme.typography.mono
                            color: Theme.palette.textSecondary
                        }
                    }
                    WidthReadout { target: clampBox }
                }

                ColumnLayout {
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: "Short entries, wide control"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosComboBox {
                        id: wideBox
                        Layout.preferredWidth: 320
                        model: ["a", "b", "c"]
                        currentIndex: 0
                    }
                    WidthReadout { target: wideBox }
                }
            }

            RowLayout {
                spacing: Theme.spacing.large

                ColumnLayout {
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: "More rows than the window"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosComboBox {
                        id: tallBox
                        Layout.preferredWidth: 140
                        model: Array.from({length: 200}, function (_, i) { return "entry " + i })
                        currentIndex: 0
                    }
                    HeightReadout { target: tallBox }
                }

                Item { Layout.fillWidth: true }
            }
        }

        // Re-measuring an open dropdown
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Re-measuring an open dropdown"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.palette.borderHairline
            }

            LogosText {
                text: "A row edited in place notifies nothing the width binding reads, so it reads entryRevision instead, which the model's dataChanged bumps. Turn the switch on, open the dropdown and leave it open: row 0's text cycles every 2s and the dropdown re-measures without being reopened."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            ListModel {
                id: liveRows
                ListElement { label: "1.0.0" }
                ListElement { label: "1.1.0" }
                ListElement { label: "1.2.0" }
            }

            // setProperty() emits dataChanged; nothing here touches the combo box.
            Timer {
                id: editTimer
                interval: 2000
                repeat: true
                running: liveEdits.checked

                readonly property var texts: ["1.0.0", "2.0.0-32.gf8ab37c1 (nightly)", "2.0.0"]
                property int step: 0

                onTriggered: {
                    step = (step + 1) % texts.length
                    liveRows.setProperty(0, "label", texts[step])
                }
            }

            RowLayout {
                spacing: Theme.spacing.large

                LogosComboBox {
                    id: liveBox
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 140
                    model: liveRows
                    textRole: "label"
                    currentIndex: 0
                }

                ColumnLayout {
                    spacing: Theme.spacing.small

                    LogosSwitch {
                        id: liveEdits
                        text: "Edit row 0 every 2s"
                    }
                    LogosText {
                        text: "row 0: \"" + editTimer.texts[editTimer.step] + "\""
                        font.pixelSize: Theme.typography.secondaryText
                        font.family: Theme.typography.mono
                        color: Theme.palette.textSecondary
                    }
                    WidthReadout { target: liveBox }
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
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 220
                    model: itemsModel.text.split(",").map(function(s) { return s.trim() }).filter(function(s) { return s.length > 0 })
                    currentIndex: -1
                    placeholderText: placeholderInput.text || "(empty placeholder)"
                    enabled: !disableSwitch.checked
                    maxPopupWidthFactor: tryFactor.value
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
                            text: "alpha, beta, gamma, an entry wider than the control"
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
                        LogosText {
                            text: "maxPopupWidthFactor:"
                            Layout.preferredWidth: 140
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textSecondary
                        }
                        LogosSlider {
                            id: tryFactor
                            Layout.preferredWidth: 160
                            from: 1; to: 4; stepSize: 0.25; value: 3
                            snapMode: LogosSlider.SnapAlways
                        }
                        LogosText {
                            text: "×" + tryFactor.value.toFixed(2)
                            font.pixelSize: Theme.typography.secondaryText
                            font.family: Theme.typography.mono
                            color: Theme.palette.textSecondary
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
                    WidthReadout { target: tryBox }
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
