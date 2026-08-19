import QtQuick
import QtQuick.Layouts
import QtTest

import Logos.Theme
import Logos.Controls
import Logos.Icons

// Note: assertions here go through `shown`, never `visible`. QtTest's TestCase
// is an invisible Item (TestCase.qml sets `visible: false`), and QQuickItem's
// visible property reports *effective* visibility, so every child of a TestCase
// reads false regardless of what it was set to.
TestCase {
    name: "LogosNotice"
    width: 400
    height: 200
    when: windowShown

    LogosNotice {
        id: notice
        width: 400
        message: "something happened"
    }

    SignalSpy {
        id: dismissedSpy
        target: notice
        signalName: "dismissed"
    }

    // Actions are caller-supplied Items that the notice reparents, matching
    // LogosDialog's leftActions/rightActions. Declared here so the test owns them.
    LogosButton {
        id: retryAction
        text: "Retry"
        variant: LogosButton.Variant.Secondary
    }

    function init() {
        notice.severity = LogosNotice.Info
        notice.title = ""
        notice.message = "something happened"
        notice.closable = false
        notice.actions = []
        notice.shown = true
        dismissedSpy.clear()
    }

    function test_aliases_resolve() {
        verify(notice.titleItem)
        verify(notice.messageItem)
        verify(notice.backgroundItem)
        verify(notice.closeButtonItem)
    }

    function test_message_flows_through() {
        compare(notice.messageItem.text, "something happened")
    }

    function test_title_flows_through() {
        compare(notice.titleItem.text, "")
        notice.title = "Heads up"
        compare(notice.titleItem.text, "Heads up")
    }

    function test_severity_drives_accent_data() {
        return [
            { tag: "info",    severity: LogosNotice.Info,    expected: Theme.palette.primary },
            { tag: "success", severity: LogosNotice.Success, expected: Theme.palette.success },
            { tag: "warning", severity: LogosNotice.Warning, expected: Theme.palette.warning },
            { tag: "error",   severity: LogosNotice.Error,   expected: Theme.palette.error },
        ]
    }

    // Severity shows through the border and the icon, not a tinted fill and not
    // the title: the title stays neutral so the notice reads as a message rather
    // than one undifferentiated block of alarm colour.
    function test_severity_drives_accent(data) {
        notice.severity = data.severity
        compare(notice.iconItem.color.toString(), data.expected.toString())
        // Border is the muted variant of the same hue, so it shares RGB and
        // differs only in alpha — status without shouting.
        compare(notice.backgroundItem.border.color.r, data.expected.r)
        compare(notice.backgroundItem.border.color.g, data.expected.g)
        compare(notice.backgroundItem.border.color.b, data.expected.b)
        verify(notice.backgroundItem.border.color.a < 1.0)
    }

    // The severity icons are near-black silhouettes (#0d1625); MultiEffect
    // colorization leaves those near-black unless brightness normalises them
    // first, so the tint silently does nothing. Asserting the colour property
    // alone passes while the icon renders black on screen.
    function test_icon_brightness_normalised_for_tinting() {
        compare(notice.iconItem.brightness, 1.0)
    }

    function test_title_is_neutral_not_severity_coloured() {
        notice.title = "Upload failed"
        notice.severity = LogosNotice.Error
        compare(notice.titleItem.color.toString(), Theme.palette.text.toString())
    }

    function test_severity_selects_icon_data() {
        return [
            { tag: "success", severity: LogosNotice.Success, expected: LogosIcons.check },
            { tag: "warning", severity: LogosNotice.Warning, expected: LogosIcons.warning },
            { tag: "error",   severity: LogosNotice.Error,   expected: LogosIcons.warning },
            { tag: "info",    severity: LogosNotice.Info,    expected: LogosIcons.info },
        ]
    }

    function test_severity_selects_icon(data) {
        notice.severity = data.severity
        compare(notice.iconItem.source.toString(), data.expected.toString())
    }

    // The notice hosts whatever Item it is handed and reparents it, rather than
    // building buttons from a data schema: what an action *is* -- a button that
    // acts or a link that navigates -- is the caller's decision.
    function test_actions_are_hosted_and_reparented() {
        notice.actions = [retryAction]
        compare(notice.actions.length, 1)
        compare(notice.actions[0], retryAction)
        tryVerify(function() { return retryAction.parent !== null }, 1000)
    }

    function test_hosted_action_still_emits_its_own_signal() {
        notice.actions = [retryAction]
        var fired = 0
        retryAction.clicked.connect(function() { fired += 1 })
        retryAction.mouseAreaItem.clicked(null)
        compare(fired, 1)
    }

    // A notice floats over other content, so a translucent fill would let that
    // content bleed through and render the message unreadable.
    function test_background_is_opaque() {
        compare(notice.backgroundItem.color.a, 1.0)
        compare(notice.backgroundItem.color.toString(),
                Theme.palette.backgroundElevated.toString())
    }

    function test_hide_clears_shown_and_emits_dismissed() {
        notice.hide()
        compare(notice.shown, false)
        compare(dismissedSpy.count, 1)
    }

    // dismissed() means "this just closed". Emitting it for a notice that was
    // never open makes the signal unreliable for its listeners — LogosToast stops
    // its timer on it, and callers clear backend state on it.
    function test_hide_when_already_hidden_does_not_re_emit() {
        notice.hide()
        compare(dismissedSpy.count, 1)
        notice.hide()
        notice.hide()
        compare(dismissedSpy.count, 1)
        compare(notice.shown, false)
    }

    // Drives the close button through its mouse area's clicked signal rather than
    // synthesizing a real mouse event: TestCase is an invisible Item, so a
    // synthesized click has nothing to hit. Same approach as tst_LogosCopyButton.
    function test_close_button_dismisses() {
        notice.closable = true
        notice.closeButtonItem.mouseAreaItem.clicked(null)
        compare(notice.shown, false)
        compare(dismissedSpy.count, 1)
    }

    // The surface never closes itself. Timed dismissal is LogosToast's job, and a
    // banner that could quietly vanish is precisely what this base must not be —
    // it is where messages carrying unrecoverable detail (a path, an error code)
    // are meant to be safe.
    function test_never_closes_itself() {
        wait(250)
        compare(notice.shown, true)
        compare(dismissedSpy.count, 0)
    }

    function test_has_no_timing_api() {
        compare(typeof notice.duration, "undefined")
        compare(typeof notice.show, "undefined")
    }

    function test_visible_follows_shown() {
        // Can't assert visible === true under an invisible TestCase, but the
        // false direction is unaffected by ancestors and still proves the link.
        notice.shown = false
        compare(notice.visible, false)
    }
}
