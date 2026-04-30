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
                text: "LogosItemDelegate"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: ItemDelegate (text, clicked()) + hoverColor, pressedColor, highlightColor. Aliases: backgroundItem, labelItem."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            color: Theme.palette.surface
            border.color: Theme.palette.border
            radius: Theme.spacing.radiusSmall

            Column {
                anchors.fill: parent
                anchors.margins: 8
                LogosItemDelegate { width: parent.width; text: "Open"; onClicked: console.log("open") }
                LogosItemDelegate { width: parent.width; text: "Save" }
                LogosItemDelegate { width: parent.width; text: "Save As…" }
                LogosItemDelegate { width: parent.width; text: "Delete"; enabled: false }
                LogosItemDelegate { width: parent.width; text: "Highlighted"; highlighted: true }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
