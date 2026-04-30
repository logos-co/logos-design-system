import QtQuick
import QtQuick.Controls

import Logos.Theme
import Logos.Controls

ScrollView {
    id: root

    clip: true

    contentWidth: root.width

    ScrollBar.vertical: LogosScrollBar {
        id: verticalBar

        orientation: Qt.Vertical
        policy: ScrollBar.AsNeeded

        parent: root
        anchors.top: root.top
        anchors.bottom: root.bottom
        anchors.right: root.right
    }

    ScrollBar.horizontal: LogosScrollBar {
        id: horizontalBar

        orientation: Qt.Horizontal
        policy: ScrollBar.AlwaysOff

        parent: root
        anchors.left: root.left
        anchors.right: root.right
        anchors.bottom: root.bottom
    }
}