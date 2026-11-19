import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Layouts

// Catalog page for LogosWizard: a node setup at phone and desktop width.
Rectangle {
    id: page

    property string figmaUrl: ""
    property bool designed: false

    color: Theme.palette.background
    implicitHeight: column.implicitHeight + 2 * Theme.spacing.xxlarge

    component Section: ColumnLayout {
        property alias title: sectionTitle.text
        Layout.fillWidth: true
        spacing: Theme.spacing.medium
        LogosText {
            id: sectionTitle
            font.pixelSize: Theme.typography.primaryText
            font.weight: Theme.typography.weightBold
        }
        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.palette.borderHairline }
    }

    component StepTitle: LogosText {
        font.pixelSize: Theme.typography.subtitleText
        font.weight: Theme.typography.weightBold
    }

    component Setup: Rectangle {
        id: frame
        Layout.preferredHeight: 520
        color: Theme.palette.background
        border.color: Theme.palette.borderSubtle
        clip: true

        LogosWizard {
            id: wizard
            anchors.fill: parent
            anchors.margins: Theme.size.borderWidth
            title: "Set up your node"
            subtitle: "Advanced setup: configure and secure your node."
            steps: ["Setup", "Network", "Keys"]
            cancellable: true
            welcome: welcomeScreen
            canGoNext: wizard.currentIndex !== 2 || keysSaved.checked
            nextHint: canGoNext ? "" : "Confirm you saved your keys to continue"
            nextText: wizard.currentIndex === 2 ? "Start node" : "Continue"
            onFinished: {
                keysSaved.checked = false
                wizard.currentIndex = 0
                wizard.back()
            }
            onCancelled: {
                wizard.currentIndex = 0
                wizard.back()
            }

            Component {
                id: welcomeScreen
                LogosWelcome {
                    title: "Blockchain Node"
                    subtitle: "Run a node in a few steps."
                    primaryText: "Quick start"
                    secondaryText: "Advanced"
                    onSecondaryClicked: wizard.begin()
                }
            }

            ColumnLayout {
                spacing: Theme.spacing.small
                StepTitle { text: "How do you want to start?" }
                LogosRadioButton { text: "Generate a new node"; checked: true }
                LogosRadioButton { text: "Use an existing config" }
            }
            ColumnLayout {
                spacing: Theme.spacing.small
                StepTitle { text: "Which network?" }
                LogosRadioButton { text: "Testnet"; checked: true }
                LogosRadioButton { text: "Devnet" }
            }
            ColumnLayout {
                spacing: Theme.spacing.small
                StepTitle { text: "Back up your node keys" }
                LogosText {
                    Layout.fillWidth: true
                    text: "They are shown once, here. Without them the node's stake can't be recovered."
                    wrapMode: Text.Wrap
                    color: Theme.palette.textSecondary
                }
                LogosCheckbox { id: keysSaved; text: "I saved my keys" }
            }
        }
    }

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xxlarge

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosWizard"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
            }
            LogosText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: "A task in steps, as the apps' onboarding does it. Public API: title, subtitle, steps, currentIndex, welcome, begin(), canGoNext, nextText, nextHint, secondaryText, canGoBack, cancellable, cancelText, next(), back(), finished(), cancelled(), secondaryClicked(). A rail of the steps across the top; the main button names what it does, and a hint beside it says why it can't be pressed yet. On a phone only the current step is named and the buttons stack, the main one last. Advanced starts it; tick the box on Keys to go on."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Section {
            title: "At 390 px"
            Setup { Layout.fillWidth: true; Layout.maximumWidth: 390 }
        }

        Section {
            title: "At 900 px"
            Setup { Layout.fillWidth: true; Layout.maximumWidth: 900 }
        }

        Item { Layout.fillHeight: true }
    }
}
