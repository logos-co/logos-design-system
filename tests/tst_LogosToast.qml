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

    function test_inherits_notice_surface() {
        toast.severity = LogosNotice.Error
        compare(toast.backgroundItem.border.color.toString(), Theme.palette.errorBorder.toString())
        compare(toast.backgroundItem.color.a, 1.0)
    }
}
