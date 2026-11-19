import QtQuick
import QtQuick.Layouts

import Logos.Theme
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
                text: "The first screen of an app's onboarding, as Basecamp, Blockchain and LEZ have it. Public API: backdrop, logo, title, subtitle, primaryText, secondaryText, busy, primaryClicked(), secondaryClicked(). A LogosWizard shows it before its first step (welcome)."
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
            title: "Busy"
            Screen { Layout.maximumWidth: 900; busy: true }
        }

        Item { Layout.fillHeight: true }
    }
}
