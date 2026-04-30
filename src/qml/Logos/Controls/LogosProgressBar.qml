import QtQuick
import QtQuick.Controls

import Logos.Theme

ProgressBar {
    id: root

    property color trackColor: Theme.palette.backgroundSecondary
    property color fillColor: Theme.palette.primary

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias backgroundItem: bg
    readonly property alias fillItem: fill

    implicitWidth: 200
    implicitHeight: 8

    background: Rectangle {
        id: bg
        implicitWidth: root.implicitWidth
        implicitHeight: root.implicitHeight
        radius: height / 2
        color: root.trackColor
    }

    contentItem: Item {
        Rectangle {
            id: fill
            width: root.indeterminate ? parent.width * 0.3 : root.visualPosition * parent.width
            height: parent.height
            radius: height / 2
            color: root.fillColor

            SequentialAnimation on x {
                running: root.indeterminate && root.visible
                loops: Animation.Infinite
                NumberAnimation { from: 0; to: root.width - fill.width; duration: 1200 }
                NumberAnimation { from: root.width - fill.width; to: 0; duration: 1200 }
            }
        }
    }
}
