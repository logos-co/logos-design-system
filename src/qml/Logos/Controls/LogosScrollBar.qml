import QtQuick
import QtQuick.Controls

import Logos.Theme

ScrollBar {
    id: root

    property color barColor: Theme.palette.borderTertiaryMuted
    property color barColorActive: Theme.palette.textTertiary
    property int barThickness: 6

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias barItem: bar

    contentItem: Rectangle {
        id: bar
        implicitWidth: root.barThickness
        implicitHeight: root.barThickness
        radius: root.barThickness / 2
        color: root.pressed || root.hovered ? root.barColorActive : root.barColor
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    background: Rectangle { color: "transparent" }
}
