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
                text: "LogosSearchBar"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: text, placeholderText, iconSource, shortcutHint (display only), submitted(string)"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
            LogosText {
                text: "Note: shortcutHint only renders the chip — wire your own Shortcut at the app/page level."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
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

            LogosSearchBar {
                Layout.preferredWidth: 600
                placeholderText: "Default (bundled search icon)"
            }

            LogosSearchBar {
                id: barWithChip
                Layout.preferredWidth: 600
                placeholderText: "shortcutHint: \"Ctrl+K\" — chip only, no binding by itself"
                shortcutHint: "Ctrl+K"
            }

            LogosSearchBar {
                Layout.preferredWidth: 600
                placeholderText: "Icon hidden, Ctrl+F hint"
                iconSource: ""
                shortcutHint: "Ctrl+F"
            }
        }

        // Consumer-side wiring
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Wiring a real keyboard shortcut (consumer side)"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.palette.borderHairline
            }

            LogosText {
                text: "The Shortcut element below is declared by THIS PAGE, not by LogosSearchBar. Press its sequence to focus + select the live bar — try it!"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            LogosSearchBar {
                id: liveBar
                Layout.preferredWidth: 600
                placeholderText: "Press Ctrl+K (or Cmd+K on macOS) to focus me"
                // Pass the consumer Shortcut's nativeText so the chip
                // renders the platform-aware form (⌘ K on macOS).
                shortcutHint: liveShortcut.nativeText
                onSubmitted: function(text) {
                    submittedLog.text = "submitted: \"" + text + "\""
                }
            }

            // ↓ This is the consumer-owned Shortcut. The component does not
            // ship one — we wire it here on the page that contains the bar.
            Shortcut {
                id: liveShortcut
                sequence: "Ctrl+K"
                context: Qt.WindowShortcut
                onActivated: {
                    liveBar.textInput.forceActiveFocus()
                    liveBar.textInput.selectAll()
                }
            }

            LogosText {
                id: submittedLog
                text: "(no submission yet)"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
            }
        }

        // Interactive — exercises every public API on a single bar so the
        // contract is testable in-browser. Uses a different sequence than
        // the wiring example above to avoid Qt's ambiguity registry
        // disabling both bindings.
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

            LogosSearchBar {
                id: tryBar
                Layout.preferredWidth: 600
                placeholderText: placeholderInput.text || "(empty placeholder)"
                shortcutHint: tryShortcut.nativeText
                echoMode: passwordSwitch.checked ? TextInput.Password : TextInput.Normal
                onSubmitted: function(text) {
                    submitCount.value++
                    lastSubmitted.text = "last submitted: \"" + text + "\""
                }
            }

            // Page-level Shortcut that activates the tryBar. Bound to
            // whatever sequence the user types into shortcutSeqInput.
            Shortcut {
                id: tryShortcut
                sequence: shortcutSeqInput.text
                context: Qt.WindowShortcut
                onActivated: {
                    tryBar.textInput.forceActiveFocus()
                    tryBar.textInput.selectAll()
                }
            }

            ColumnLayout {
                spacing: Theme.spacing.small

                RowLayout {
                    spacing: Theme.spacing.small
                    LogosText {
                        text: "placeholderText:"
                        Layout.preferredWidth: 160
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                    LogosTextField {
                        id: placeholderInput
                        text: "Type and press Enter"
                        implicitWidth: 280
                    }
                }

                RowLayout {
                    spacing: Theme.spacing.small
                    LogosText {
                        text: "shortcut sequence:"
                        Layout.preferredWidth: 160
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                    LogosTextField {
                        id: shortcutSeqInput
                        text: "Ctrl+J"
                        implicitWidth: 160
                        placeholderText: "e.g. Ctrl+J"
                    }
                    LogosText {
                        text: "→ chip: " + (tryShortcut.nativeText || "(empty)")
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                }

                RowLayout {
                    spacing: Theme.spacing.small
                    Switch { id: passwordSwitch }
                    LogosText {
                        text: "Password mode (echoMode)"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                }

                RowLayout {
                    spacing: Theme.spacing.small
                    LogosText {
                        text: "submit count:"
                        Layout.preferredWidth: 160
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                    LogosText {
                        id: submitCount
                        property int value: 0
                        text: value
                        font.pixelSize: Theme.typography.secondaryText
                        font.weight: Theme.typography.weightBold
                        color: Theme.palette.text
                    }
                }
                LogosText {
                    id: lastSubmitted
                    text: "(no submission yet)"
                    font.pixelSize: Theme.typography.secondaryText
                    color: Theme.palette.textTertiary
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
