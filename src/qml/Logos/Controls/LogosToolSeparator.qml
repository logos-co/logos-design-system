import QtQuick
import QtQuick.Controls

import Logos.Theme

ToolSeparator {
    id: root

    property color separatorColor: Theme.palette.borderHairline

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias separatorItem: line

    contentItem: Rectangle {
        id: line
        implicitWidth: root.orientation === Qt.Horizontal ? 24 : 1
        implicitHeight: root.orientation === Qt.Horizontal ? 1 : 24
        color: root.separatorColor
    }
}
