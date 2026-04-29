import QtQuick
import QtQuick.Controls

import Logos.Theme

Control {
    id: root

    property alias text: label.text
    readonly property bool isActive: mouseArea.pressed || root.hovered
    signal clicked()

    implicitWidth: 200
    implicitHeight: 50
    hoverEnabled: true

    background: Rectangle {
        color: !root.enabled
               ? Theme.palette.backgroundMuted
               : (root.isActive ? Theme.palette.backgroundMuted : Theme.palette.backgroundSecondary)
        radius: Theme.spacing.radiusXlarge
        border.color: !root.enabled
                      ? Theme.palette.border
                      : (root.isActive ? Theme.palette.overlayOrange : Theme.palette.border)
        border.width: 1
    }

    contentItem: Text {
        id: label
        color: root.enabled ? Theme.palette.text : Theme.palette.textMuted
        font.pixelSize: Theme.typography.secondaryText
        font.weight: Theme.typography.weightMedium
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
