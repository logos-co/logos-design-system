import QtQuick
import QtQuick.Controls

import Logos.Theme

Slider {
    id: root

    property color trackColor: Theme.palette.backgroundSecondary
    property color fillColor: Theme.palette.primary
    property color handleColor: Theme.palette.primary

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias trackItem: track
    readonly property alias fillItem: fill
    readonly property alias handleItem: handle

    background: Rectangle {
        id: track
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 4
        width: root.availableWidth
        height: 4
        radius: 2
        color: root.trackColor

        Rectangle {
            id: fill
            width: root.visualPosition * parent.width
            height: parent.height
            color: root.fillColor
            radius: 2
        }
    }

    handle: Rectangle {
        id: handle
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: 18
        implicitHeight: 18
        radius: width / 2
        color: root.pressed ? Theme.palette.primaryPressed : root.handleColor
        border.color: Theme.palette.border
    }
}
