import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

Rectangle {
    property string figmaUrl: ""
    property bool designed: false

    color: Theme.palette.background

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosToolSeparator"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Themed vertical (or horizontal) divider for use inside LogosToolBar. Public: separatorColor, orientation. Alias: separatorItem."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        LogosToolBar {
            Layout.fillWidth: true

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.medium
                anchors.rightMargin: Theme.spacing.medium
                spacing: Theme.spacing.tiny

                LogosToolButton { text: "Cut" }
                LogosToolButton { text: "Copy" }
                LogosToolButton { text: "Paste" }
                LogosToolSeparator {}
                LogosToolButton { text: "Bold" }
                LogosToolButton { text: "Italic" }
                LogosToolSeparator {}
                LogosToolButton { text: "Undo" }
                LogosToolButton { text: "Redo" }
                Item { Layout.fillWidth: true }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
