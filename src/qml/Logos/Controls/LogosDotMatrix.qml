pragma ComponentBehavior: Bound

import QtQuick

import Logos.Theme

// A grid of rounded-square dots used as a compact status ornament in module
// headers — a node/service card shows it lit while the thing is up.
//
// Two display modes:
//   * static   — `pattern` selects which cells are lit (`dotColor`) and which
//                are not (`inactiveDotColor`). Use for a resting state.
//   * animated — `pattern` is ignored, every cell takes `dotColor`, and a wave
//                ripples outward from the centre. Use for transitional states
//                (starting, stopping, syncing).
//
// The base class is a plain Item, not Control: this has no content, padding or
// interaction, so Control's box model would only add unused surface area.
//
// Example — lit while running, rippling while it starts up:
//
//     LogosDotMatrix {
//         pattern: LogosDotMatrix.ringPattern
//         animated: status === Backend.Starting
//         dotColor: status === Backend.Running ? Theme.palette.success
//                                              : Theme.palette.textMuted
//     }
Item {
    id: root

    // Flat row-major array of 0/1 picking out the lit cells. Length need not
    // fill the grid; missing trailing cells render inactive.
    property list<int> pattern: []

    property int columns: 5
    property int dotSize: 8
    property int dotSpacing: Theme.spacing.tiny

    property color dotColor: Theme.palette.primary
    property color inactiveDotColor: Theme.palette.borderTertiaryMuted
    property real activeOpacity: 1.0
    property real inactiveOpacity: 1.0
    // Opacity of the ring trailing the wavefront in animated mode. This is what
    // makes the ripple visible, so it must NOT be derived from the two above:
    // both default to 1.0, and any midpoint of them is also 1.0 — every dot
    // then renders identically and the animation silently does nothing.
    property real trailOpacity: 0.35
    property real radius: Theme.spacing.radiusTiny

    // Ripple outward from the centre instead of drawing `pattern`.
    property bool animated: false
    // Per-step duration of that ripple. Set to 0 in tests and assert the
    // resting state rather than chasing intermediate frames.
    property int animationInterval: 140

    // A hollow ring — the shape module headers use by default.
    readonly property list<int> ringPattern: [
        0, 1, 1, 1, 0,
        1, 0, 0, 0, 1,
        1, 0, 1, 0, 1,
        1, 0, 0, 0, 1,
        0, 1, 1, 1, 0
    ]

    readonly property int rows: Math.max(1, Math.ceil(d.cellCount / columns))

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias gridItem: grid
    readonly property alias _d: d

    implicitWidth: columns * dotSize + Math.max(0, columns - 1) * dotSpacing
    implicitHeight: rows * dotSize + Math.max(0, rows - 1) * dotSpacing

    QtObject {
        id: d

        // Animated mode fills the whole square; static mode draws only as many
        // cells as `pattern` describes.
        readonly property int cellCount:
            root.animated ? root.columns * root.columns
                          : (root.pattern ? root.pattern.length : 0)

        property int phase: 0

        function isLit(index) {
            return !!(root.pattern && index < root.pattern.length && root.pattern[index])
        }

        // Manhattan distance from the centre cell, which is what the ripple
        // travels along.
        function ringDistance(index) {
            const centre = Math.floor(root.columns / 2)
            const column = index % root.columns
            const row = Math.floor(index / root.columns)
            return Math.abs(column - centre) + Math.abs(row - centre)
        }

        function cellOpacity(index) {
            if (!root.animated)
                return isLit(index) ? root.activeOpacity : root.inactiveOpacity

            const offset = Math.abs(ringDistance(index) - (phase % root.columns))
            if (offset === 0)
                return root.activeOpacity
            if (offset === 1)
                return root.trailOpacity
            return root.inactiveOpacity
        }
    }

    Timer {
        interval: root.animationInterval
        repeat: true
        running: root.animated && root.animationInterval > 0
        onTriggered: d.phase = (d.phase + 1) % (root.columns * 2)
    }

    Grid {
        id: grid
        columns: root.columns
        spacing: root.dotSpacing

        Repeater {
            model: d.cellCount

            Rectangle {
                required property int index

                width: root.dotSize
                height: root.dotSize
                radius: root.radius
                color: (root.animated || d.isLit(index)) ? root.dotColor
                                                         : root.inactiveDotColor
                opacity: d.cellOpacity(index)
            }
        }
    }
}
