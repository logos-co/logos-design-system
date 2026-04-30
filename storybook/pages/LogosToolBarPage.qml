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
                text: "LogosToolBar / LogosToolButton"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: ToolBar / ToolButton (text, clicked()) + colour overrides. Aliases: backgroundItem, labelItem."
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

                LogosToolButton { text: "File" }
                LogosToolButton { text: "Edit" }
                LogosToolButton { text: "View" }
                LogosToolButton { text: "Help" }
                Item { Layout.fillWidth: true }
                LogosToolButton { text: "Disabled"; enabled: false }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
