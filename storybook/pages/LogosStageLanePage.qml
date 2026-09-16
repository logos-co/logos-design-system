import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

// Catalog page for LogosStageLane. Shows the public API states + a knobs panel
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
                text: "LogosStageLane"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: stages (LogosStage), currentIndex, busy, failed, interactive, stageClicked(index), stateAt(index). An ordered process; for a single proportion use LogosProgressBar."
                Layout.maximumWidth: 760
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        // Position model
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Position — one index, monotonic by construction"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.palette.borderHairline
            }

            Repeater {
                model: [
                    { idx: -1, note: "currentIndex: -1 — nothing started" },
                    { idx: 0,  note: "currentIndex: 0" },
                    { idx: 2,  note: "currentIndex: 2 — earlier stages complete" },
                    { idx: 4,  note: "currentIndex: stages.length — all complete" }
                ]

                ColumnLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: Theme.spacing.tiny

                    LogosText {
                        text: parent.modelData.note
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                    LogosStageLane {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 620
                        currentIndex: parent.modelData.idx
                        stages: [
                            LogosStage { label: "Started" },
                            LogosStage { label: "Online" },
                            LogosStage { label: "Funded" },
                            LogosStage { label: "Earning" }
                        ]
                    }
                }
            }
        }

        // States
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Busy and failed"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.palette.borderHairline
            }
            LogosText {
                text: "busy: the current stage pulses and swaps in its busyLabel. failed: it goes red and stops pulsing."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
            }
            LogosStageLane {
                Layout.fillWidth: true
                Layout.maximumWidth: 620
                currentIndex: 1
                busy: true
                stages: [
                    LogosStage { label: "Started" },
                    LogosStage { label: "Online"; busyLabel: "Syncing…" },
                    LogosStage { label: "Funded" },
                    LogosStage { label: "Earning" }
                ]
            }
            LogosStageLane {
                Layout.fillWidth: true
                Layout.maximumWidth: 620
                currentIndex: 1
                failed: true
                stages: [
                    LogosStage { label: "Started" },
                    LogosStage { label: "Online"; busyLabel: "Syncing…" },
                    LogosStage { label: "Funded" },
                    LogosStage { label: "Earning" }
                ]
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

            LogosStageLane {
                id: live
                Layout.fillWidth: true
                Layout.maximumWidth: 620
                currentIndex: Math.round(indexSlider.value)
                busy: busySwitch.checked
                failed: failedSwitch.checked
                interactive: interactiveSwitch.checked
                onStageClicked: function (index) { indexSlider.value = index }
                stages: [
                    LogosStage { label: "Started" },
                    LogosStage { label: "Online"; busyLabel: "Syncing…" },
                    LogosStage { label: "Funded"; busyLabel: "Mining…" },
                    LogosStage { label: "Aged"; busyLabel: "Aging" },
                    LogosStage { label: "Earning" }
                ]
            }

            RowLayout {
                spacing: Theme.spacing.xxlarge

                RowLayout {
                    spacing: Theme.spacing.small
                    LogosText {
                        text: "currentIndex:"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                    Slider {
                        id: indexSlider
                        from: -1; to: 5; stepSize: 1; value: 1
                        implicitWidth: 180
                    }
                    LogosText {
                        text: Math.round(indexSlider.value)
                        font.pixelSize: Theme.typography.secondaryText
                        font.weight: Theme.typography.weightBold
                        color: Theme.palette.text
                    }
                }

                RowLayout {
                    spacing: Theme.spacing.small
                    Switch { id: busySwitch; checked: true }
                    LogosText {
                        text: "busy"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                }
                RowLayout {
                    spacing: Theme.spacing.small
                    Switch { id: failedSwitch }
                    LogosText {
                        text: "failed"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                }
                RowLayout {
                    spacing: Theme.spacing.small
                    Switch { id: interactiveSwitch }
                    LogosText {
                        text: "interactive (click a stage)"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                }
            }
        }

        // In context
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "In context — inside a LogosStatCard hero"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.palette.borderHairline
            }
            LogosStatCard {
                Layout.fillWidth: true
                Layout.maximumWidth: 620
                value: "Online"
                caption: "Following the chain"
                severity: LogosStatCard.Success
            }
            LogosStageLane {
                Layout.fillWidth: true
                Layout.maximumWidth: 620
                currentIndex: 1
                stages: [
                    LogosStage { label: "Started" },
                    LogosStage { label: "Online" }
                ]
            }
        }

        Item { Layout.fillHeight: true }
    }
}
