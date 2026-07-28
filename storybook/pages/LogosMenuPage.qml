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
                text: "Public API: Menu / MenuItem (text, enabled, triggered()). Use popupUnder(button) for button menus (keyboard-safe); popup() for context menus at the cursor. Aliases: backgroundItem, labelItem."
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
            implicitHeight: 36
            onClicked: contextMenu.popupUnder(menuButton)
        }

        Item { Layout.fillHeight: true }
    }
}
