import QtQuick
import QtQuick.Controls

import Logos.Theme

// An overlay scroll bar: hidden while the content sits idle, revealed only when
// there is something to scroll and the user is engaging with it (dragging it,
// hovering it, or just after a scroll step), then it fades back out. Set
// policy: ScrollBar.AlwaysOn to keep it pinned instead.
ScrollBar {
    id: root

    property color barColor: Theme.palette.borderTertiaryMuted
    property color barColorActive: Theme.palette.textTertiary
    property int barThickness: 6

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias barItem: bar

    hoverEnabled: true

    QtObject {
        id: d

        // Keeps the bar up for a moment after a scroll, so a wheel step or
        // flick is visible before it fades. Restarted on every position change.
        readonly property Timer activityTimer: Timer {
            interval: 800
        }
    }
    onPositionChanged: d.activityTimer.restart()

    contentItem: Rectangle {
        id: bar
        implicitWidth: root.barThickness
        implicitHeight: root.barThickness
        radius: root.barThickness / 2
        color: root.pressed || root.hovered ? root.barColorActive : root.barColor

        // Show only for real overflow, and only while the user is engaging with
        // it. Reveal is not tied to ScrollBar.active, which the runtime can latch
        // on and never clear, leaving the bar stuck visible.
        opacity: root.policy === ScrollBar.AlwaysOn
                 || (root.size < 1.0 && (root.pressed || root.hovered || d.activityTimer.running))
                 ? 1 : 0

        Behavior on opacity { NumberAnimation { duration: 200 } }
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    background: Rectangle { color: "transparent" }
}
