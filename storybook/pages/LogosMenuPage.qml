import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

Rectangle {
    property string figmaUrl: ""
    property bool designed: false

    color: Theme.palette.background

    LogosMenu {
        id: contextMenu
        LogosMenuItem { text: "Open" }
        LogosMenuItem { text: "Rename" }
        LogosMenuItem { text: "Move…" }
        LogosMenuItem { text: "Delete"; enabled: false }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosMenu / LogosMenuItem"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: Menu / MenuItem (text, enabled, triggered()), contextFor, sheet (read-only). Use popupUnder(button) for button menus (keyboard-safe). contextFor makes it an item's context menu: a right-click opens it there, a long press (the touch path) at the item. Aliases: backgroundItem, handleItem, dragAreaItem, labelItem. In a phone-wide window, however it is opened, it is a sheet across the bottom: try it with Preview: phone in the header."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        LogosButton {
            id: menuButton
            text: "Open menu"
            implicitWidth: 140
            onClicked: contextMenu.popupUnder(menuButton)
        }

        Rectangle {
            id: contextTarget
            Layout.fillWidth: true
            Layout.maximumWidth: 320
            implicitHeight: Theme.size.touchTarget * 2
            radius: Theme.spacing.radiusLarge
            color: Theme.palette.backgroundSecondary
            border.color: Theme.palette.borderSubtle

            LogosText {
                anchors.centerIn: parent
                text: "Right-click or long-press here"
                color: Theme.palette.textSecondary
            }
        }

        LogosMenu {
            contextFor: contextTarget
            LogosMenuItem { text: "Copy" }
            LogosMenuItem { text: "Share" }
        }

        Item { Layout.fillHeight: true }
    }
}
