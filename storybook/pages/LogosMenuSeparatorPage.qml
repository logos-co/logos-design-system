import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

Rectangle {
    property string figmaUrl: ""
    property bool designed: false

    color: Theme.palette.background

    LogosMenu {
        id: menu
        LogosMenuItem { text: "New" }
        LogosMenuItem { text: "Open" }
        LogosMenuSeparator {}
        LogosMenuItem { text: "Save" }
        LogosMenuItem { text: "Save As…" }
        LogosMenuSeparator {}
        LogosMenuItem { text: "Quit" }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosMenuSeparator"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Themed horizontal divider for use inside LogosMenu. Public: separatorColor. Alias: separatorItem."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        LogosButton {
            text: "Open menu"
            implicitWidth: 140
            implicitHeight: 36
            onClicked: menu.popup()
        }

        Item { Layout.fillHeight: true }
    }
}
