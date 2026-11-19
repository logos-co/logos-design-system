import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

// LogosWelcome — the first screen of an app's onboarding, as Basecamp,
// Blockchain and LEZ have it: a backdrop under a scrim, and centred on it the
// logo, a title, a line under it and the ways in, the main one first, full
// width. A LogosWizard shows it before its first step.
//
// Public API:
//     backdrop          an image filling the screen, cropped
//     logo              an icon over the title; none by default
//     title, subtitle
//     primaryText       the main way in, e.g. "Quick start"
//     secondaryText     another, e.g. "Advanced"; hidden when empty
//     busy              a spinner in place of the buttons
//     primaryClicked(), secondaryClicked()
//
// Read-only inspection aliases: columnItem, primaryButtonItem,
// secondaryButtonItem, spinnerItem.
//
// Example:
//     LogosWizard {
//         id: setup
//         welcome: Component {
//             LogosWelcome {
//                 backdrop: "qrc:/onboarding.jpg"
//                 title: qsTr("Blockchain Node")
//                 primaryText: qsTr("Quick start")
//                 secondaryText: qsTr("Advanced")
//                 onPrimaryClicked: startWithDefaults()
//                 onSecondaryClicked: setup.begin()
//             }
//         }
//         …
//     }
Item {
    id: root

    property url backdrop
    property url logo
    property string title: ""
    property string subtitle: ""
    property string primaryText: ""
    property string secondaryText: ""
    property bool busy: false

    signal primaryClicked()
    signal secondaryClicked()

    readonly property alias columnItem: column
    readonly property alias primaryButtonItem: primaryButton
    readonly property alias secondaryButtonItem: secondaryButton
    readonly property alias spinnerItem: spinner

    Image {
        anchors.fill: parent
        source: root.backdrop
        fillMode: Image.PreserveAspectCrop
        mipmap: true
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.palette.scrim
    }

    ColumnLayout {
        id: column
        anchors.centerIn: parent
        width: Math.min(root.width - 2 * Theme.pageMargin(root.width), Theme.layouts.welcome.maximumWidth)
        spacing: Theme.spacing.medium

        LogosIcon {
            visible: root.logo.toString() !== ""
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: Theme.spacing.medium
            Layout.preferredWidth: Theme.layouts.welcome.logoSize
            Layout.preferredHeight: Theme.layouts.welcome.logoSize
            source: root.logo
        }

        LogosText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: root.title
            wrapMode: Text.Wrap
            font.pixelSize: Theme.typography.pageTitleText
            font.weight: Theme.typography.weightBold
        }

        LogosText {
            visible: root.subtitle !== ""
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: root.subtitle
            wrapMode: Text.Wrap
            font.pixelSize: Theme.typography.subtitleText
        }

        ColumnLayout {
            visible: !root.busy
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Theme.spacing.large
            Layout.maximumWidth: Theme.layouts.welcome.buttonWidth
            spacing: Theme.spacing.medium

            LogosButton {
                id: primaryButton
                visible: root.primaryText !== ""
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.layouts.welcome.buttonHeight
                variant: LogosButton.Variant.Primary
                text: root.primaryText
                onClicked: root.primaryClicked()
            }
            LogosButton {
                id: secondaryButton
                visible: root.secondaryText !== ""
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.layouts.welcome.buttonHeight
                text: root.secondaryText
                onClicked: root.secondaryClicked()
            }
        }

        LogosSpinner {
            id: spinner
            visible: root.busy
            running: root.busy
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Theme.spacing.large
        }
    }
}
