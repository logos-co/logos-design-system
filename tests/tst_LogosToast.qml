import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls

// LogosToast is LogosNotice plus transient behaviour, so this covers only what it
// adds — the surface itself is tested in tst_LogosNotice.
TestCase {
    name: "LogosToast"
    width: 400
    height: 200
    when: windowShown

    LogosToast {
        id: toast
        width: 400
        message: "something happened"
    }

    SignalSpy {
        id: dismissedSpy
        target: toast
        signalName: "dismissed"
    }

    function init() {
        toast.severity = LogosNotice.Info
        toast.title = ""
        toast.message = "something happened"
        toast.duration = 4000
        toast.shown = false
        dismissedSpy.clear()
    }

    // A toast appears in response to an event; a banner is part of the page. If it
    // started shown, every page carrying one would flash it on load.
    function test_starts_hidden() {
        compare(toast.shown, false)
    }

    function test_defaults_to_auto_closing_and_dismissible() {
        compare(toast.duration, 4000)
        compare(toast.closable, true)
    }

    function test_show_then_auto_closes() {
        toast.duration = 100
        toast.show("Saved", "Your changes were saved.")
        compare(toast.shown, true)
        tryVerify(function() { return !toast.shown }, 2000)
        compare(dismissedSpy.count, 1)
    }

    // Explicitly overridable: a toast carrying something the user cannot recover
    // must be able to stay put.
    function test_zero_duration_overrides_auto_close() {
        toast.duration = 0
        toast.show("Wallet forgotten", "Config: /a.json")
        wait(250)
        compare(toast.shown, true)
        compare(dismissedSpy.count, 0)
    }

    // show() has to restart a countdown that is already running -- same toast,
    // new message, `shown` never changes. The timer is therefore armed from one
    // place imperatively rather than by a `running:` binding, which an
    // imperative restart() would have overwritten the first time it was called.
    function test_show_restarts_a_running_countdown() {
        toast.duration = 1000
        toast.show("First", "one")
        wait(700)
        verify(toast.shown)
        toast.show("Second", "two")
        wait(700)                 // 1400ms since the first show, 700 since the second
        verify(toast.shown)       // would already have closed had it not re-armed
        tryVerify(function() { return !toast.shown }, 2000)
    }

    // Hiding a toast by assignment, rather than through the close button, still
    // has to disarm it -- otherwise the countdown outlives what it was counting.
    function test_hiding_disarms_the_countdown() {
        toast.duration = 200
        toast.show("Saved", "ok")
        toast.shown = false
        dismissedSpy.clear()
        wait(500)
        compare(dismissedSpy.count, 0)
    }

    function test_inherits_notice_surface() {
        toast.severity = LogosNotice.Error
        compare(toast.backgroundItem.border.color.toString(), Theme.palette.errorBorder.toString())
        compare(toast.backgroundItem.color.a, 1.0)
    }
}
