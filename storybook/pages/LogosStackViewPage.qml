import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

Rectangle {
    property string figmaUrl: ""
    property bool designed: false

    color: Theme.palette.background

    Component {
        id: pageA
        Rectangle {
            color: Theme.palette.surface
            LogosText {
                anchors.centerIn: parent
                text: "Page A"
                font.pixelSize: Theme.typography.titleText
                color: Theme.palette.text
            }
        }
    }

    Component {
        id: pageB
        Rectangle {
            color: Theme.palette.backgroundSecondary
            LogosText {
                anchors.centerIn: parent
                text: "Page B"
                font.pixelSize: Theme.typography.titleText
                color: Theme.palette.text
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosStackView"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: StackView (initialItem, push(), pop(), depth, currentItem)."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        RowLayout {
            spacing: Theme.spacing.medium
            LogosButton {
                text: "Push B"
                implicitWidth: 100
                implicitHeight: 36
                onClicked: stack.push(pageB)
            }
            LogosButton {
                text: "Pop"
                implicitWidth: 80
                implicitHeight: 36
                enabled: stack.depth > 1
                onClicked: stack.pop()
            }
            LogosText { text: "depth: " + stack.depth; color: Theme.palette.textSecondary }
        }

        LogosStackView {
            id: stack
            Layout.fillWidth: true
            Layout.fillHeight: true
            initialItem: pageA
        }
    }
}
