import QtQuick

import Logos.Theme

// Plain-Item-based spinner. We deliberately do NOT extend BusyIndicator —
Item {
    id: root

    property bool running: true
    property color ringColor: Theme.palette.text
    property int thickness: Theme.controls.spinner.thickness
    property int dotSize: Theme.controls.spinner.dotSize

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias ringItem: ring
    readonly property alias dotItem: dot

    implicitWidth: Theme.controls.spinner.size
    implicitHeight: Theme.controls.spinner.size

    Rectangle {
        id: ring
        anchors.fill: parent
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
            anchors.topMargin: Theme.controls.spinner.dotInset
        }

        RotationAnimation on rotation {
            from: 0
            to: 360
            duration: 1000
            loops: Animation.Infinite
            running: root.running
        }
    }
}
