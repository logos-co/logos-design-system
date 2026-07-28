import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls

TestCase {
    name: "LogosLink"
    width: 400
    height: 200
    when: windowShown

    LogosLink {
        id: link
        text: "Docs"
        href: "https://example.com/docs"
    }

    SignalSpy {
        id: activatedSpy
        target: link
        signalName: "activated"
    }

    function init() {
        link.text = "Docs"
        link.href = "https://example.com/docs"
        link.enabled = true
        link.underline = true
        link.linkColor = Theme.palette.primary
        link.hoverColor = Theme.palette.primaryHover
        activatedSpy.clear()
    }

    // ── Aliases ──────────────────────────────────────────────────────────

    function test_aliases_resolve() {
        verify(link.labelItem)
        verify(link.mouseAreaItem)
    }

    // ── Defaults / round-trips ───────────────────────────────────────────

    function test_label_tracks_text() {
        tryCompare(link.labelItem, "text", "Docs")
        link.text = "Guide"
        tryCompare(link.labelItem, "text", "Guide")
    }

    function test_underline_default_true() {
        compare(link.underline, true)
        compare(link.labelItem.font.underline, true)
    }

    function test_linkColor_flows_to_label() {
        tryCompare(link.labelItem, "color", Theme.palette.primary)
        link.linkColor = Theme.palette.info
        tryCompare(link.labelItem, "color", Theme.palette.info)
    }

    // ── Activation ───────────────────────────────────────────────────────

    function test_click_emits_activated_with_href() {
        link.mouseAreaItem.clicked(null)
        compare(activatedSpy.count, 1)
        compare(activatedSpy.signalArguments[0][0].toString(),
                "https://example.com/docs")
    }

    function test_activate_emits_activated() {
        link.activate()
        compare(activatedSpy.count, 1)
    }

    function test_disabled_does_not_activate() {
        link.enabled = false
        link.activate()
        compare(activatedSpy.count, 0)
    }

    function test_empty_href_still_emits_activated() {
        link.href = ""
        link.activate()
        compare(activatedSpy.count, 1)
        compare(activatedSpy.signalArguments[0][0].toString(), "")
    }
}
