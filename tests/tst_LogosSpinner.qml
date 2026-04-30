import QtQuick
import QtTest

import Logos.Controls

TestCase {
    name: "LogosSpinner"
    width: 100
    height: 100
    when: windowShown

    LogosSpinner { id: spin }

    function init() {
        spin.running = true
        spin.thickness = 3
        spin.dotSize = 6
    }

    function test_default_running() { compare(spin.running, true) }

    function test_running_property_round_trips() {
        spin.running = false
        compare(spin.running, false)
        spin.running = true
        compare(spin.running, true)
    }

    function test_aliases_resolve() {
        verify(spin.ringItem)
        verify(spin.dotItem)
    }

    function test_thickness_setter() {
        spin.thickness = 5
        compare(spin.thickness, 5)
    }

    function test_dot_visibility_follows_running() {
        spin.running = false
        tryCompare(spin.ringItem, "visible", false)
        spin.running = true
        tryCompare(spin.ringItem, "visible", true)
    }
}
