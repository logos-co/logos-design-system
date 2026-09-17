import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

// Catalog page for LogosStatCard. Shows the public API states + a knobs panel
// underneath so reviewers can poke the component without code.
Rectangle {
    property string figmaUrl: ""
    property bool designed: false

    color: Theme.palette.background

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xxlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny

            LogosText {
                text: "LogosStatCard"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: label, value, caption, labelTrailing, valueTrailing, captionTrailing, severity, valueColor, valueFontSizeMode, valueMinimumPixelSize, interactive, flashOnChange, flashColor, clicked(). A labelled metric — not a general container; for that use LogosFrame."
                Layout.maximumWidth: 720
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        // Anatomy
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Anatomy"
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

                LogosStatCard {
                    Layout.preferredWidth: 210
                    label: "Height"
                    value: "151548"
                }
                LogosStatCard {
                    Layout.preferredWidth: 210
                    label: "Epoch"
                    value: "174"
                    caption: "6h of 10h"
                }
                LogosStatCard {
                    Layout.preferredWidth: 210
                    label: "At Headslot"
                    value: "-12"
                    caption: "12 slots behind"
                    labelTrailing: [
                        LogosInfoButton {
                            title: "At Headslot"
                            text: "How far the chain tip sits from the consensus clock, in slots."
                        }
                    ]
                }

                // Three slots, three jobs: labelTrailing annotates the card,
                // valueTrailing acts on the figure, captionTrailing on the
                // caption's own text. Note that neither copy button carries
                // what is on screen — the value is a shortened hash and the
                // caption a formatted slot, which is exactly why these are
                // buttons with their own strings rather than selectable text.
                LogosStatCard {
                    Layout.preferredWidth: 210
                    label: "LiB"
                    value: "0x71bd…9e4a"
                    caption: "slot 151548"
                    labelTrailing: [
                        LogosInfoButton {
                            title: "LiB"
                            text: "Header id of the last irreversible block."
                        }
                    ]
                    valueTrailing: [
                        LogosCopyButton { value: "0x71bd000000009e4a" }
                    ]
                    captionTrailing: [
                        LogosCopyButton { value: "151548" }
                    ]
                }
            }
        }

        // Severity
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Severity — the value carries the state, the surface stays flat"
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

                LogosStatCard {
                    Layout.preferredWidth: 180
                    label: "None"; value: "151548"
                }
                LogosStatCard {
                    Layout.preferredWidth: 180
                    label: "Info"; value: "Core"
                    severity: LogosStatCard.Info
                }
                LogosStatCard {
                    Layout.preferredWidth: 180
                    label: "Success"; value: "Online"
                    severity: LogosStatCard.Success
                }
                LogosStatCard {
                    Layout.preferredWidth: 180
                    label: "Warning"; value: "-12"
                    caption: "12 slots behind"
                    severity: LogosStatCard.Warning
                }
                LogosStatCard {
                    Layout.preferredWidth: 180
                    label: "Error"; value: "Stalled"
                    caption: "No block progress"
                    severity: LogosStatCard.Error
                }
            }
            LogosText {
                text: "Opt into a stronger signal with borderColor: Theme.palette.warningBorder — flat is the default, not a rule."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
            }

            LogosText {
                text: "valueColor — tint without a verdict"
                font.pixelSize: Theme.typography.subtitleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "severity flags something; valueColor just colours. Reach for severity only when the figure is incomplete, stale or wrong — it adds an icon so the meaning survives without colour, and beside an info button that icon reads as a second, broken one."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            RowLayout {
                spacing: Theme.spacing.large

                LogosStatCard {
                    Layout.preferredWidth: 220
                    label: "Blend"; value: "Core"
                    valueColor: Theme.palette.info
                    labelTrailing: [
                        LogosInfoButton { text: "One icon: the role is a fact, not a flag." }
                    ]
                }
                LogosStatCard {
                    Layout.preferredWidth: 220
                    label: "Blend (severity: Info)"; value: "Core"
                    severity: LogosStatCard.Info
                    labelTrailing: [
                        LogosInfoButton { text: "Two icons, one of them inert. This is what valueColor exists to avoid." }
                    ]
                }
                LogosStatCard {
                    Layout.preferredWidth: 220
                    label: "Total Balance"; value: "1 530"
                    caption: "3 of 6 accounts reported"
                    severity: LogosStatCard.Warning
                    labelTrailing: [
                        LogosInfoButton { text: "Severity earns its icon here: the figure really is incomplete." }
                    ]
                }
            }
            RowLayout {
                spacing: Theme.spacing.large
                LogosStatCard {
                    Layout.preferredWidth: 180
                    label: "Bordered"; value: "-98"
                    severity: LogosStatCard.Warning
                    borderColor: Theme.palette.warningBorder
                }
            }
        }

        // Long values
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Long values — elide, or shrink to fit"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.palette.borderHairline
            }
            LogosText {
                text: "Same width, same digits. Elide is right when the value is long because it is an identifier — half a hash still reads as a hash. Shrink is right when every digit is meaning, which is most numbers. Drag the width to watch both."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            RowLayout {
                spacing: Theme.spacing.large

                LogosStatCard {
                    Layout.preferredWidth: widthKnob.value
                    label: "Total Balance (default)"
                    value: "5,999,999,986,578"
                    caption: "Text.FixedSize"
                }
                LogosStatCard {
                    Layout.preferredWidth: widthKnob.value
                    label: "Total Balance"
                    value: "5,999,999,986,578"
                    caption: "Text.HorizontalFit"
                    valueFontSizeMode: Text.HorizontalFit
                    valueTrailing: [
                        LogosCopyButton { value: "5999999986578" }
                    ]
                }
                // Past the floor even shrinking gives up and elides — which is
                // why the exact figure belongs on a copy button, not on the
                // hope that it fits.
                LogosStatCard {
                    Layout.preferredWidth: widthKnob.value
                    label: "Past the floor"
                    value: "5,999,999,986,578,000,000,000"
                    caption: "shrinks to " + Theme.typography.subtitleText + "px, then elides"
                    valueFontSizeMode: Text.HorizontalFit
                }
            }
            RowLayout {
                spacing: Theme.spacing.small
                Slider {
                    id: widthKnob
                    from: 120
                    to: 420
                    value: 194
                }
                LogosText {
                    text: "width: " + Math.round(widthKnob.value) + "px"
                    font.pixelSize: Theme.typography.secondaryText
                    color: Theme.palette.textSecondary
                }
            }
        }

        // Interactive
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Interactive"
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

                LogosStatCard {
                    Layout.preferredWidth: 210
                    label: "Static (default)"
                    value: "151548"
                }
                LogosStatCard {
                    id: clickable
                    Layout.preferredWidth: 210
                    label: "Browsable"
                    value: "151548"
                    caption: "Clicks: " + clickCount.value
                    interactive: true
                    onClicked: clickCount.value++
                }
                // The trailing item keeps its own clicks even though the card
                // is interactive — the case worth seeing side by side.
                LogosStatCard {
                    Layout.preferredWidth: 210
                    label: "Both"
                    value: "151548"
                    caption: "Card clicks: " + bothCount.value
                    interactive: true
                    onClicked: bothCount.value++
                    labelTrailing: [
                        LogosInfoButton { text: "Clicking me must NOT count as a card click." }
                    ]
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

                LogosStatCard {
                    id: liveCard
                    Layout.preferredWidth: 220
                    label: "Slot"
                    value: String(ticker.tick)
                    caption: "flashOnChange"
                    flashOnChange: true
                    severity: severitySwitch.checked ? LogosStatCard.Warning
                                                     : LogosStatCard.None
                }

                ColumnLayout {
                    spacing: Theme.spacing.small

                    RowLayout {
                        spacing: Theme.spacing.small
                        Switch {
                            id: tickSwitch
                            checked: true
                        }
                        LogosText {
                            text: "Ticking"
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textSecondary
                        }
                    }
                    RowLayout {
                        spacing: Theme.spacing.small
                        Switch { id: severitySwitch }
                        LogosText {
                            // The case the restore-binding exists for: toggle
                            // this while it ticks and the value must settle on
                            // orange, not drift back to neutral.
                            text: "Warning while it ticks"
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textSecondary
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }

    QtObject {
        id: clickCount
        property int value: 0
    }

    QtObject {
        id: bothCount
        property int value: 0
    }

    Timer {
        id: ticker
        property int tick: 151548
        interval: 1500
        repeat: true
        running: tickSwitch.checked
        onTriggered: tick++
    }
}
