import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

Rectangle {
    property string figmaUrl: ""
    property bool designed: false

    color: Theme.palette.background

    LogosDrawer {
        id: drawer
        edge: Qt.LeftEdge
        width: 240
        height: parent.height

        Column {
            anchors.fill: parent
            anchors.margins: Theme.spacing.large
            spacing: Theme.spacing.medium

            LogosText { text: "Settings"; font.pixelSize: Theme.typography.primaryText; font.weight: Theme.typography.weightBold; color: Theme.palette.text }
            LogosText { text: "Drawer content goes here."; color: Theme.palette.textSecondary; wrapMode: Text.WordWrap; width: parent.width }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosDrawer"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: Drawer (edge, modal, opened, open(), close()). Alias: backgroundItem."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        LogosButton {
            text: drawer.opened ? "Close drawer" : "Open drawer"
            implicitWidth: 160
            implicitHeight: 36
            onClicked: drawer.opened ? drawer.close() : drawer.open()
        }

        Item { Layout.fillHeight: true }
    }
}
