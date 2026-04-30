import QtQuick
import QtQuick.Controls

import Logos.Theme

Drawer {
    id: root

    property color borderColor: Theme.palette.border
    property color backgroundColor: Theme.palette.backgroundSecondary

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias backgroundItem: bg

    background: Rectangle {
        id: bg
        color: root.backgroundColor
        border.color: root.borderColor
    }
}
