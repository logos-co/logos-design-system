import QtQuick
import QtQuick.Controls

import Logos.Theme

ToolBar {
    id: root

    property color backgroundColor: Theme.palette.backgroundSecondary
    property color separatorColor: Theme.palette.borderHairline

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias backgroundItem: bg

    background: Rectangle {
        id: bg
        color: root.backgroundColor

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: root.separatorColor
        }
    }
}
