import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

// Catalog page for LogosInfoButton. Shows the public API states + a knobs panel
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
            Layout.fillWidth: true
            spacing: Theme.spacing.tiny

            LogosText {
                text: "LogosInfoButton"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: text, title, dialogWidth, open(), close(), toggle(), opened. Opens a centred LogosDialog — an explanation is something you stop to read. For a one-line hint that follows the pointer, use LogosToolTip."
                Layout.fillWidth: true
                Layout.maximumWidth: 760
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        // In context
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "In context"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.palette.borderHairline
            }

            // The stat card goes under the label when there's no room beside it.
            GridLayout {
                id: inContext
                columns: parent.width >= fieldLabel.implicitWidth + fieldInfo.implicitWidth
                                         + Theme.spacing.xxlarge + 210 + 3 * columnSpacing ? 4 : 2
                columnSpacing: Theme.spacing.large
                rowSpacing: Theme.spacing.large

                LogosText {
                    id: fieldLabel
                    text: "Beside a field label"
                    font.pixelSize: Theme.typography.primaryText
                    color: Theme.palette.text
                }
                LogosInfoButton {
                    id: fieldInfo
                    title: "Headslot delta"
                    text: "A paragraph long enough to need wrapping: this is the case a tooltip "
                        + "handles badly, because the text appears under the pointer and "
                        + "disappears the moment you move toward it."
                }

                Item { Layout.preferredWidth: Theme.spacing.xxlarge; visible: inContext.columns === 4 }

                LogosStatCard {
                    Layout.preferredWidth: 210
                    label: "Height"
                    value: "151548"
                    labelTrailing: [
                        LogosInfoButton {
                            title: "Height"
                            text: "Number of blocks in the chain up to the current tip."
                        }
                    ]
                }
            }
        }

        // Title
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "With and without a title"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.palette.borderHairline
            }
            Flow {
                Layout.fillWidth: true
                spacing: Theme.spacing.xxlarge

                RowLayout {
                    spacing: Theme.spacing.small
                    LogosText {
                        text: "Titled"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                    LogosInfoButton {
                        title: "Slot"
                        text: "Consensus slot of the current chain tip."
                    }
                }
                RowLayout {
                    spacing: Theme.spacing.small
                    LogosText {
                        text: "Untitled — header collapses"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                    LogosInfoButton {
                        text: "No title, so the dialog shows only the explanation."
                    }
                }
                RowLayout {
                    spacing: Theme.spacing.small
                    LogosText {
                        text: "Narrow (dialogWidth: 320)"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                    LogosInfoButton {
                        title: "Narrow"
                        dialogWidth: 320
                        text: "Overridden to 320px. The default is 560, clamped to the window."
                    }
                }
            }
        }

        // Placement independence
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Position of the trigger does not matter"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.palette.borderHairline
            }
            LogosText {
                text: "The dialog is parented to the window overlay, so it centres on the window — "
                    + "not on the card or row the trigger sits in, and never clips against an edge. "
                    + "Open the one on the far right."
                Layout.fillWidth: true
                Layout.maximumWidth: 760
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
            }
            RowLayout {
                Layout.fillWidth: true
                LogosInfoButton {
                    title: "Left edge"
                    text: "Triggered from the left."
                }
                Item { Layout.fillWidth: true }
                LogosInfoButton {
                    title: "Right edge"
                    text: "Triggered from the right — same centred dialog."
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
