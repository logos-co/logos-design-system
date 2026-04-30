import QtQuick
import QtQuick.Controls

import Logos.Theme

BusyIndicator {
    id: root

    property color ringColor: Theme.palette.text
    property int thickness: 3
    property int dotSize: 6

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias ringItem: ring
    readonly property alias dotItem: dot

    implicitWidth: 36
    implicitHeight: 36
    running: true

    contentItem: Rectangle {
        id: ring
        radius: Math.min(width, height) / 2
        color: "transparent"
        border.color: root.ringColor
        border.width: root.thickness

        Rectangle {
            id: dot
            width: root.dotSize
            height: root.dotSize
            radius: width / 2
            color: root.ringColor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 2
        }

        RotationAnimation on rotation {
            from: 0
            to: 360
            duration: 1000
            loops: Animation.Infinite
            running: root.running && root.visible
        }
    }
}
