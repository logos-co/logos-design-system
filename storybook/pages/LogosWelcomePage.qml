import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Icons
import Logos.Controls
import Logos.Layouts

// Catalog page for LogosWelcome: an onboarding's first screen at phone and
// desktop width, and busy.
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

    component Screen: LogosWelcome {
        Layout.fillWidth: true
        Layout.preferredHeight: 480
        backdrop: Qt.resolvedUrl("sample-app-icon.png")
        title: "Welcome to Basecamp,"
        subtitle: "Let's get you set up, it'll only take a moment."
        primaryText: "Let's go"
        secondaryText: "Advanced setup"
    }

    // As Basecamp's design has it: aligned left, a status over the title, the
    // brand, a close button, the version and other ways in in the corners.
    component Designed: LogosWelcome {
        Layout.fillWidth: true
        Layout.preferredHeight: 560
        backdrop: Qt.resolvedUrl("sample-app-icon.png")
        alignment: Qt.AlignLeft
        status: LogosBadge { text: "Network connected"; color: Theme.palette.success }
        title: "Welcome to Basecamp,"
        subtitle: "Let's get you set up, it'll only take a moment."
        primaryText: "Continue"
        primaryIcon: LogosIcons.arrowRight
        actionsFillWidth: false
        topLeft: ColumnLayout {
            spacing: 0
            LogosText { text: "Logos"; color: Theme.palette.textSecondary }
            LogosText { text: "Basecamp."; font.pixelSize: Theme.typography.panelTitleText; font.weight: Theme.typography.weightBold }
            LogosBadge { text: "Alpha" }
        }
        topRight: LogosIconButton { iconSource: LogosIcons.close; flat: true; Accessible.name: "Close" }
        bottomLeft: ColumnLayout {
            spacing: Theme.spacing.tiny
            LogosText { text: "Alpha · V. 0.1.3"; font.pixelSize: Theme.typography.secondaryText; color: Theme.palette.textSecondary }
            LogosLink { text: "Legal disclaimer" }
        }
        bottomRight: Row {
            spacing: Theme.spacing.large
            LogosLink { text: "Restore existing device"; underline: false }
            LogosLink { text: "Connect to remote device"; underline: false }
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
                text: "LogosWelcome"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
            }
            LogosText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: "The first screen of an app's onboarding. Public API: backdrop, logo, title, subtitle, status, alignment, primaryText, primaryIcon, secondaryText, actionsFillWidth, busy, topLeft, topRight, bottomLeft, bottomRight, primaryClicked(), secondaryClicked(). Centred, as the apps have it, or aligned left with corners, as Basecamp's design has it; on a phone the bottom corners stack. A LogosWizard shows it before its first step (welcome)."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Section {
            title: "At 390 px"
            Screen { Layout.maximumWidth: 390 }
        }

        Section {
            title: "At 900 px"
            Screen { Layout.maximumWidth: 900 }
        }

        Section {
            title: "Aligned left, with corners (Basecamp's design), at 390 px"
            Designed { Layout.maximumWidth: 390 }
        }

        Section {
            title: "Aligned left, with corners, at 1000 px"
            Designed { Layout.maximumWidth: 1000 }
        }

        Section {
            title: "Busy"
            Screen { Layout.maximumWidth: 900; busy: true }
        }

        Item { Layout.fillHeight: true }
    }
}
