import QtQuick
import QtQuick.Controls
import QtTest

import Logos.Controls

TestCase {
    name: "LogosScrollBar"
    width: 200
    height: 200
    when: windowShown

    Flickable {
        id: scroll
        anchors.fill: parent
        contentWidth: width
        contentHeight: 800
        ScrollBar.vertical: LogosScrollBar { id: bar }
    }

    Flickable {
        id: fittingScroll
        anchors.fill: parent
        contentWidth: width
        contentHeight: height
        ScrollBar.vertical: LogosScrollBar { id: fittingBar }
    }

    function init() {
        // QtTest runs alphabetically; reset state so leakage from earlier
        // tests doesn't break later ones.
        bar.barThickness = 6
        bar.policy = ScrollBar.AsNeeded
        bar.position = 0
    }

    function test_default_thickness() { compare(bar.barThickness, 6) }

    function test_aliases_resolve() {
        verify(bar.barItem)
    }

    function test_bar_thickness_setter() {
        bar.barThickness = 10
        tryCompare(bar.barItem, "implicitWidth", 10)
    }

    function test_hidden_when_content_fits() {
        compare(fittingBar.size, 1)
        tryCompare(fittingBar.barItem, "opacity", 0)
    }

    // The overlay bar stays hidden at rest even when the content overflows: it
    // is not tied to ScrollBar.active, which the runtime can leave stuck on.
    function test_hidden_at_rest_when_content_overflows() {
        verify(bar.size < 1)
        tryCompare(bar.barItem, "opacity", 0)
    }

    function test_shown_after_a_scroll() {
        verify(bar.size < 1)
        bar.position = 0.3
        tryCompare(bar.barItem, "opacity", 1)
    }

    function test_always_on_shows_without_activity() {
        bar.policy = ScrollBar.AlwaysOn
        tryCompare(bar.barItem, "opacity", 1)
    }
}
