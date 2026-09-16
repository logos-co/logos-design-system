import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls

TestCase {
    id: root
    name: "LogosStageLane"
    width: 600
    height: 200
    when: windowShown

    LogosStageLane {
        id: lane
        width: 480
        height: 30
        anchors.centerIn: parent
        pulseDuration: 0
        stages: [
            LogosStage { label: "Started" },
            LogosStage { label: "Online"; busyLabel: "Syncing…" },
            LogosStage { label: "Earning" }
        ]
    }

    LogosStageLane {
        id: clickable
        width: 480
        height: 30
        interactive: true
        currentIndex: 1
        stages: [
            LogosStage { label: "One" },
            LogosStage { label: "Two" },
            LogosStage { id: lockedStage; label: "Three"; enabled: false }
        ]
    }

    // A lane with the pulse actually running, so the animation can be observed
    // through what it renders rather than by poking the clock behind it.
    LogosStageLane {
        id: pulsing
        width: 480
        height: 30
        currentIndex: 1
        pulseDuration: 400
        stages: [
            LogosStage { label: "One" },
            LogosStage { label: "Two" },
            LogosStage { label: "Three" }
        ]
    }

    SignalSpy {
        id: clickSpy
        target: clickable
        signalName: "stageClicked"
    }

    function init() {
        clickSpy.clear()
        lane.currentIndex = -1
        lane.busy = false
        lane.failed = false
        lane.interactive = false
        lane.height = 30
    }

    // ---- Public surface ----

    function test_geometry_and_palette_are_not_public() {
        // The chevron shape and the five state colours are what make a stage
        // lane recognisable and make a state mean one thing across modules.
        // They live on Theme and in `d`, not on the component.
        const internals = ["notchDepth", "stageSpacing", "cornerRadius",
                           "activeColor", "busyColor", "failedColor",
                           "doneColor", "pendingColor", "pulse", "_d"]
        for (const name of internals)
            compare(lane[name], undefined, name + " should not be public API")
    }

    // ---- Position model ----

    function test_count_reflects_the_stages() {
        compare(lane.count, 3)
    }

    function test_nothing_started_leaves_every_stage_pending() {
        lane.currentIndex = -1
        compare(lane.stateAt(0), LogosStageLane.Pending)
        compare(lane.stateAt(1), LogosStageLane.Pending)
        compare(lane.stateAt(2), LogosStageLane.Pending)
    }

    function test_earlier_stages_are_done_and_later_pending() {
        lane.currentIndex = 1
        compare(lane.stateAt(0), LogosStageLane.Done)
        compare(lane.stateAt(1), LogosStageLane.Active)
        compare(lane.stateAt(2), LogosStageLane.Pending)
    }

    function test_index_past_the_end_completes_every_stage() {
        lane.currentIndex = lane.count
        compare(lane.stateAt(0), LogosStageLane.Done)
        compare(lane.stateAt(1), LogosStageLane.Done)
        compare(lane.stateAt(2), LogosStageLane.Done)
    }

    function test_out_of_range_index_is_pending_not_an_error() {
        compare(lane.stateAt(-1), LogosStageLane.Pending)
        compare(lane.stateAt(99), LogosStageLane.Pending)
    }

    // A single index cannot express "stage 2 done while stage 1 is not", which
    // is the point: the lane is monotonic by construction.
    function test_progress_is_monotonic_by_construction() {
        lane.currentIndex = 2
        for (let i = 0; i < lane.currentIndex; i++)
            compare(lane.stateAt(i), LogosStageLane.Done)
    }

    // ---- Busy / failed ----

    function test_busy_applies_only_to_the_current_stage() {
        lane.currentIndex = 1
        lane.busy = true
        compare(lane.stateAt(0), LogosStageLane.Done)
        compare(lane.stateAt(1), LogosStageLane.Busy)
        compare(lane.stateAt(2), LogosStageLane.Pending)
    }

    function test_failed_wins_over_busy() {
        // A stage that has failed is not still "working".
        lane.currentIndex = 1
        lane.busy = true
        lane.failed = true
        compare(lane.stateAt(1), LogosStageLane.Failed)
    }

    function test_busy_label_replaces_the_label_only_while_busy() {
        lane.currentIndex = 1
        compare(lane.labelItemAt(1).label, "Online")
        lane.busy = true
        compare(lane.labelItemAt(1).label, "Syncing…")
        lane.busy = false
        compare(lane.labelItemAt(1).label, "Online")
    }

    function test_busy_label_falls_back_to_the_label() {
        lane.currentIndex = 0
        lane.busy = true
        compare(lane.labelItemAt(0).label, "Started")
    }

    // ---- Rendering ----

    function test_chevron_path_is_a_closed_rounded_outline() {
        const path = lane.segmentAt(1).outline
        verify(path.startsWith("M "))
        verify(path.endsWith("Z"))
        // Quadratics are the rounded corners; a bare polygon would have none.
        verify(path.indexOf("Q") > 0)
    }

    function test_a_busy_stage_pulses() {
        pulsing.busy = true
        const start = pulsing.segmentAt(1).fillColor.a
        tryVerify(function () { return pulsing.segmentAt(1).fillColor.a !== start },
                  3000)
    }

    function test_a_settled_lane_does_not_animate() {
        pulsing.busy = false
        const before = pulsing.segmentAt(1).fillColor
        wait(300)   // longer than a full pulse at this duration
        compare(pulsing.segmentAt(1).fillColor, before)
    }

    function test_the_pulse_does_not_rebuild_geometry() {
        // The reason this is Shapes and not a Canvas: the pulse must move the
        // fill without touching the path. A Canvas had to re-run its JS and
        // re-rasterise the whole lane on every frame of this animation.
        pulsing.busy = true
        const outline = pulsing.segmentAt(1).outline
        const start = pulsing.segmentAt(1).fillColor.a
        tryVerify(function () { return pulsing.segmentAt(1).fillColor.a !== start },
                  3000)
        compare(pulsing.segmentAt(1).outline, outline)
    }

    function test_only_the_busy_segment_responds_to_the_pulse() {
        pulsing.busy = true
        const settled = pulsing.segmentAt(0).fillColor
        const start = pulsing.segmentAt(1).fillColor.a
        tryVerify(function () { return pulsing.segmentAt(1).fillColor.a !== start },
                  3000)
        // The settled stages are untouched, so their bindings never re-run.
        compare(pulsing.segmentAt(0).fillColor, settled)
    }

    function test_geometry_follows_height() {
        // The notch depth is capped against height, so the outline has to
        // change when the lane gets shorter — this was silently stale before.
        lane.currentIndex = 1
        const tall = lane.segmentAt(1).outline
        lane.height = 10
        verify(lane.segmentAt(1).outline !== tall)
        lane.height = 30
        compare(lane.segmentAt(1).outline, tall)
    }

    // ---- Interaction ----

    function test_not_interactive_by_default() {
        compare(lane.interactive, false)
    }

    function test_interactive_emits_the_clicked_index() {
        clickable.hitAreaAt(0).clicked(null)
        compare(clickSpy.count, 1)
        compare(clickSpy.signalArguments[0][0], 0)
    }

    function test_disabled_stage_is_not_clickable() {
        // lockedStage is declared `enabled: false`, so its hit area is inert
        // while the rest of the lane stays clickable.
        tryCompare(clickable.hitAreaAt(2), "enabled", false)
        compare(clickable.hitAreaAt(0).enabled, true)

        // and it follows the stage, rather than being read once at build time
        lockedStage.enabled = true
        tryCompare(clickable.hitAreaAt(2), "enabled", true)
        lockedStage.enabled = false
        tryCompare(clickable.hitAreaAt(2), "enabled", false)
    }

    function test_no_hit_areas_when_not_interactive() {
        // A display-only lane puts nothing in front of what is beneath it.
        compare(lane.interactive, false)
        compare(lane.hitAreaAt(0), null)
    }

    // ---- Geometry ----

    function test_segments_divide_the_full_width() {
        // First segment starts at 0 and the last ends at the lane's width —
        // the chevrons divide the lane rather than sitting inside it.
        const first = clickable.hitAreaAt(0)
        const last = clickable.hitAreaAt(clickable.count - 1)
        fuzzyCompare(first.x, 0, 0.5)
        fuzzyCompare(last.x + last.width, clickable.width, 0.5)
    }

    function test_notch_depth_is_capped_by_height() {
        // A short lane must not carry points deeper than half its height, or
        // the chevrons invert into bowties. The cap is internal, so this
        // asserts the observable consequence: segments still tile the width.
        lane.height = 10
        lane.interactive = true
        const last = lane.hitAreaAt(lane.count - 1)
        fuzzyCompare(last.x + last.width, lane.width, 0.5)
        lane.height = 30
    }
}
