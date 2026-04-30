import QtQuick
import QtQuick.Controls
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
                text: "LogosScrollBar"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: ScrollBar (orientation, position, size, etc.) + barColor, barColorActive, barThickness. Alias: barItem."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: 1500
            clip: true

            ScrollBar.vertical: LogosScrollBar {}

            Column {
                width: parent.width
                spacing: Theme.spacing.medium
                Repeater {
                    model: 30
                    Rectangle {
                        width: parent.width
                        height: 40
                        color: index % 2 === 0 ? Theme.palette.surface : Theme.palette.backgroundSecondary
                        radius: Theme.spacing.radiusSmall
                        LogosText {
                            anchors.centerIn: parent
                            text: "Row " + index
                            color: Theme.palette.text
                        }
                    }
                }
            }
        }
    }
}
