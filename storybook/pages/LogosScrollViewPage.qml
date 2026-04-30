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
                text: "LogosScrollView"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "ScrollView wrapper that wires LogosScrollBar for vertical and horizontal scroll."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        LogosScrollView {
            id: scrollView
            
            Layout.fillWidth: true
            Layout.fillHeight: true

            contentHeight: contentColumn.implicitHeight

            Column {
                id: contentColumn

                width: scrollView.width
                spacing: Theme.spacing.small
                Repeater {
                    model: 50
                    Rectangle {
                        width: parent.width
                        height: 36
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
