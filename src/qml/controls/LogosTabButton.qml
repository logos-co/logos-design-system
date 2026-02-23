import QtQuick
import QtQuick.Controls

import Logos.Theme
import Logos.Controls

TabButton {
    id: root

    font.pixelSize: Theme.typography.secondaryText

    contentItem: LogosText {
        text: root.text
        font: root.font
        color: root.checked ? Theme.palette.text : Theme.palette.textSecondary
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 3
        visible: root.checked
        color: Theme.palette.primary
    }
}
