pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

import Logos.Theme
import Logos.Controls

// LogosStageLane — an ordered process drawn as interlocking chevrons, with one
// stage accented at a time.
//
// For a pipeline whose stages are known up front and advance in order: an
// install or sync sequence, an onboarding flow, a node coming up. For a single
// proportion use LogosProgressBar; for free navigation between peers use
// LogosTabBar.
//
// Position is a single index. Stages before `currentIndex` are complete, the
// one at it is in progress, the rest are ahead — so the lane is monotonic by
// construction and a caller cannot describe a stage 3 that is done while
// stage 2 is not.
//
//     currentIndex        -1  nothing started
//                          i  stage i in progress, 0..i-1 complete
//              stages.length  every stage complete
//
// Public API:
//     stages          list of LogosStage. Order is the order drawn
//     currentIndex    the stage in progress (see above). Default -1
//     busy            the current stage is actively working: it pulses and
//                     shows its busyLabel
//     failed          the current stage has failed: it goes red and stops
//                     pulsing
//     interactive     makes stages clickable; emits stageClicked(index)
//     pulseDuration   length of one busy pulse in ms. Set 0 to disable
//     count           number of stages (read-only)
//     stateAt(index)  LogosStageLane.Pending / Busy / Active / Done / Failed.
//                     Out of range reads as Pending rather than throwing
//
// Signals:
//     stageClicked(int index)   only while `interactive` and the stage is enabled
//
// Read-only inspection accessors (tests / tooling only):
//     chevronsItem, labelsItem, hitAreasItem
//     segmentAt(i) / labelItemAt(i) / hitAreaAt(i) — the rendered items, each
//     carrying what it draws (outline, fillColor, label, stageState)
//
// Chevron geometry and the segment palette are deliberately NOT public. The
// shape is what makes a stage lane recognisable as one, and the five colours
// carry fixed semantics — done, in progress, working, failed, ahead — so
// letting each consumer repaint them would make the same state mean different
// things in different modules. Both come from Theme; change them there.
//
// Green is reserved for the stage actually being worked, not used as decoration
// on everything already passed — completed stages are neutral with a check, so
// the eye lands on where the process currently is.
//
// Example:
//     LogosStageLane {
//         currentIndex: 1
//         busy: node.syncing
//         stages: [
//             LogosStage { label: qsTr("Started") },
//             LogosStage { label: qsTr("Online"); busyLabel: qsTr("Syncing…") },
//             LogosStage { label: qsTr("Earning") }
//         ]
//     }
Item {
    id: root

    enum StageState {
        Pending,
        Busy,
        Active,
        Done,
        Failed
    }

    property list<LogosStage> stages: []
    property int currentIndex: -1
    property bool busy: false
    property bool failed: false
    property bool interactive: false
    property int pulseDuration: 2800

    readonly property int count: stages.length

    signal stageClicked(int index)

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias chevronsItem: chevrons
    readonly property alias labelsItem: labels
    readonly property alias hitAreasItem: hitAreas

    function segmentAt(index) { return shapeRepeater.itemAt(index) }
    function labelItemAt(index) { return labelRepeater.itemAt(index) }
    function hitAreaAt(index) { return hitRepeater.itemAt(index) }

    function stateAt(index) {
        if (index < 0 || index >= root.count)
            return LogosStageLane.Pending
        if (index < root.currentIndex)
            return LogosStageLane.Done
        if (index > root.currentIndex)
            return LogosStageLane.Pending
        if (root.failed)
            return LogosStageLane.Failed
        return root.busy ? LogosStageLane.Busy : LogosStageLane.Active
    }

    implicitHeight: 30
    implicitWidth: 200

    Accessible.role: Accessible.ProgressBar
    Accessible.name: (root.currentIndex >= 0 && root.currentIndex < root.count)
                     ? qsTr("Step %1 of %2: %3").arg(root.currentIndex + 1)
                                                .arg(root.count)
                                                .arg(d.labelAt(root.currentIndex))
                     : qsTr("%1 stages").arg(root.count)

    QtObject {
        id: d

        // Chevron geometry. `notch` is how far the point protrudes and the notch
        // bites in; `gap` is the clearance left between a point and the next
        // notch, so the segments read as separate.
        readonly property real notch: 14
        readonly property real gap: 2
        readonly property real cornerRadius: 3

        // Segment palette. Fixed semantics, so these follow Theme rather than
        // the consumer.
        readonly property color activeColor: Theme.palette.success
        readonly property color busyColor: Theme.palette.warning
        readonly property color failedColor: Theme.palette.error
        readonly property color doneColor: Theme.palette.surface
        readonly property color pendingColor: Theme.palette.surfaceRecessed

        // Drives the busy pulse. Internal: it is an animation clock, not state
        // a caller sets.
        property real pulse: 0

        // Capped so a short lane cannot carry points deeper than half its
        // height, which would invert the chevrons into bowties.
        readonly property real depth: Math.min(notch, root.height * 0.5)

        // Each chevron overlaps the next by (depth - gap), so the tip ends up
        // `gap` clear of the following notch.
        readonly property real segmentWidth:
            (root.width + (root.count - 1) * (depth - gap)) / Math.max(1, root.count)

        function left(i) { return i * (segmentWidth - depth + gap) }
        function right(i) { return left(i) + segmentWidth }

        // Centre of the readable area — between this chevron's notch and its point.
        function labelCentre(i) {
            const l = left(i) + (i > 0 ? depth : 0)
            const r = right(i) - (i < root.count - 1 ? depth : 0)
            return (l + r) / 2
        }

        // Chevron outline for stage `index`, in that segment's own coordinates,
        // as an SVG path. Corners are rounded by pulling back `cornerRadius`
        // along both edges and bridging with a quadratic — at this radius it is
        // indistinguishable from a circular arc, and it rounds the concave
        // notch as readily as the convex point.
        function chevronPath(index) {
            const w = segmentWidth
            const h = root.height
            const dep = depth

            const pts = [[0, 0]]
            if (index === root.count - 1)
                pts.push([w, 0], [w, h])
            else
                pts.push([w - dep, 0], [w, h / 2], [w - dep, h])
            pts.push([0, h])
            // Concave notch, seating the previous chevron's point.
            if (index > 0)
                pts.push([dep, h / 2])

            const n = pts.length
            let out = ""
            for (let i = 0; i < n; i++) {
                const prev = pts[(i - 1 + n) % n]
                const cur = pts[i]
                const next = pts[(i + 1) % n]

                const inLen = Math.hypot(cur[0] - prev[0], cur[1] - prev[1])
                const outLen = Math.hypot(next[0] - cur[0], next[1] - cur[1])
                // A zero-length edge has no direction to pull back along.
                if (inLen === 0 || outLen === 0)
                    continue
                const r = Math.min(cornerRadius, inLen / 2, outLen / 2)

                const from = [cur[0] + (prev[0] - cur[0]) * r / inLen,
                              cur[1] + (prev[1] - cur[1]) * r / inLen]
                const to = [cur[0] + (next[0] - cur[0]) * r / outLen,
                            cur[1] + (next[1] - cur[1]) * r / outLen]

                out += (i === 0 ? "M " : "L ")
                     + from[0].toFixed(2) + "," + from[1].toFixed(2) + " "
                     + "Q " + cur[0].toFixed(2) + "," + cur[1].toFixed(2) + " "
                     + to[0].toFixed(2) + "," + to[1].toFixed(2) + " "
            }
            return out + "Z"
        }

        function labelAt(index) {
            const stage = (index >= 0 && index < root.count) ? root.stages[index] : null
            if (!stage)
                return ""
            return (root.stateAt(index) === LogosStageLane.Busy
                    && stage.busyLabel.length > 0)
                   ? stage.busyLabel : stage.label
        }

        function fillFor(state) {
            switch (state) {
            case LogosStageLane.Failed:
                return Qt.rgba(failedColor.r, failedColor.g, failedColor.b, 0.22)
            case LogosStageLane.Busy:
                return Qt.rgba(busyColor.r, busyColor.g, busyColor.b, 0.14 + 0.14 * pulse)
            case LogosStageLane.Active:
                return Qt.rgba(activeColor.r, activeColor.g, activeColor.b, 0.20)
            case LogosStageLane.Done:
                return doneColor
            default:
                return pendingColor
            }
        }

        function textFor(state) {
            switch (state) {
            case LogosStageLane.Failed: return failedColor
            case LogosStageLane.Busy:   return busyColor
            case LogosStageLane.Active: return activeColor
            case LogosStageLane.Done:   return Theme.palette.textSecondary
            default:                    return Theme.palette.textTertiary
            }
        }
    }

    // Breathes up and back down. A sawtooth (0→1 then a snap to 0) reads as a
    // hard drop from filled to transparent rather than as a pulse.
    SequentialAnimation {
        running: root.busy && !root.failed && root.pulseDuration > 0
        loops: Animation.Infinite

        NumberAnimation {
            target: d; property: "pulse"
            from: 0; to: 1
            duration: root.pulseDuration / 2
            easing.type: Easing.InOutSine
        }
        NumberAnimation {
            target: d; property: "pulse"
            from: 1; to: 0
            duration: root.pulseDuration / 2
            easing.type: Easing.InOutSine
        }

        onRunningChanged: if (!running) d.pulse = 0
    }

    // A Repeater cannot produce ShapePaths directly — ShapePath is not an Item —
    // so each segment is its own Shape, positioned over its own slice of the
    // lane and drawn in local coordinates.
    Item {
        id: chevrons
        anchors.fill: parent

        Repeater {
            id: shapeRepeater
            model: root.stages

            Shape {
                id: segment

                required property int index

                // What this segment is drawing, named on the delegate so
                // segmentAt(i) hands back something readable.
                readonly property string outline: d.chevronPath(index)
                readonly property color fillColor: d.fillFor(root.stateAt(index))

                x: d.left(index)
                y: 0
                width: d.segmentWidth
                height: root.height
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                    fillColor: segment.fillColor
                    strokeWidth: -1

                    PathSvg { path: segment.outline }
                }
            }
        }
    }

    Item {
        id: labels
        anchors.fill: parent

        Repeater {
            id: labelRepeater
            model: root.stages

            Row {
                id: stageRow

                required property int index
                required property LogosStage modelData

                // The text this stage resolved to — `label`, or `busyLabel`
                // while it is the busy one. Named on the delegate so
                // labelItemAt(i) hands back something readable.
                readonly property string label: d.labelAt(index)
                readonly property int stageState: root.stateAt(index)

                spacing: 4
                x: d.labelCentre(index) - width / 2
                y: (root.height - height) / 2

                LogosText {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: stageRow.stageState === LogosStageLane.Done
                    text: "✓"
                    color: d.activeColor
                    font.pixelSize: Theme.typography.secondaryText
                    font.weight: Theme.typography.weightBold
                }

                LogosText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: stageRow.label
                    color: d.textFor(stageRow.stageState)
                    font.pixelSize: Theme.typography.secondaryText
                }
            }
        }
    }

    // Hit areas, one per segment. Only created when the lane is interactive, so
    // a display-only lane puts nothing in the way of what is underneath it.
    Item {
        id: hitAreas
        anchors.fill: parent

        Repeater {
            id: hitRepeater
            model: root.interactive ? root.stages : []

            MouseArea {
                id: hit

                required property int index
                required property LogosStage modelData

                x: d.left(index)
                width: d.segmentWidth
                y: 0
                height: root.height
                enabled: hit.modelData.enabled
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.stageClicked(hit.index)
            }
        }
    }
}
