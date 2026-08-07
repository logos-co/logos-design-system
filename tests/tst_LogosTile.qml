import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls

// Locks LogosTile's interaction states.
//
// The ring assertions are not ceremony: this exact component previously had
// its border ring declared as a sibling of an explicit `contentItem:`
// assignment, which put it in contentData, stopped it rendering, and removed
// every hover and pressed cue — with no build error and no runtime warning.
// A test that only checked `pressed` or `hovered` would have stayed green
// throughout. Assert on the rendered chrome.
TestCase {
    id: tc
    name: "LogosTile"
    width: 300
    height: 300
    when: windowShown

    LogosTile {
        id: tile
        label: "wallet_ui"
        tileSize: 80
        anchors.centerIn: parent
    }

    SignalSpy {
        id: clickSpy
        target: tile
        signalName: "clicked"
    }

    function init() {
        tile.source = ""
        tile.fallbackColor = Theme.palette.surface
        tile.enabled = true
        tile.highlighted = false
        tile.interactive = true
        tile.label = "wallet_ui"
        tile.fallbackColor = Theme.palette.surface
        clickSpy.clear()
    }

    // ── Structure ───────────────────────────────────────────────────────
    function test_ring_is_realised() {
        verify(tile.plateItem, "plate must render")
        compare(tile.plateItem.border.width, 1)
    }

    function test_idle_chrome() {
        compare(String(tile.plateItem.border.color),
                String(Theme.palette.borderSubtle))
        compare(tile.artworkItem.brightness, 0)
        compare(tile.scale, 1.0)
    }

    // ── Pressed ─────────────────────────────────────────────────────────
    // Driven by keyboard, not mousePress(): synthesized mouse events do not
    // reliably reach an inner MouseArea through a Control on offscreen QPA.
    // Space sets the same `pressed` state the mouse would, so this asserts
    // the real pressed chrome over a path that works headlessly.
    function test_press_changes_ring_and_icon_and_scale() {
        tile.forceActiveFocus()
        keyPress(Qt.Key_Space)
        tryCompare(tile, "pressed", true)
        tryCompare(tile.plateItem.border, "color", Theme.palette.borderStrong)
        tryCompare(tile.artworkItem, "brightness", -0.06)
        tryCompare(tile, "scale", 0.96)

        keyRelease(Qt.Key_Space)
        tryCompare(tile, "pressed", false)
        tryCompare(tile.plateItem.border, "color", Theme.palette.borderSubtle)
        tryCompare(tile.artworkItem, "brightness", 0)
        tryCompare(tile, "scale", 1.0)
    }

    function test_click_emits_signal() {
        tile.mouseAreaItem.clicked(null)
        compare(clickSpy.count, 1)
    }

    function test_disabled_tile_does_not_emit() {
        tile.enabled = false
        tile.mouseAreaItem.clicked(null)
        compare(clickSpy.count, 0)
    }

    // ── Keyboard activation (it is a button) ────────────────────────────
    function test_space_activates() {
        tile.forceActiveFocus()
        keyPress(Qt.Key_Space)
        tryCompare(tile, "pressed", true)
        keyRelease(Qt.Key_Space)
        compare(clickSpy.count, 1)
    }

    function test_enter_activates() {
        tile.forceActiveFocus()
        keyPress(Qt.Key_Return)
        keyRelease(Qt.Key_Return)
        compare(clickSpy.count, 1)
    }

    // ── Highlighted ─────────────────────────────────────────────────────
    function test_highlighted_shows_hover_chrome() {
        tile.highlighted = true
        tryCompare(tile.plateItem.border, "color", Theme.palette.border)
        tile.highlighted = false
        tile.interactive = true
        tryCompare(tile.plateItem.border, "color", Theme.palette.borderSubtle)
    }

    // Press must still win over a highlighted tile.
    function test_pressed_beats_highlighted() {
        tile.highlighted = true
        tile.forceActiveFocus()
        keyPress(Qt.Key_Space)
        tryCompare(tile.plateItem.border, "color", Theme.palette.borderStrong)
        keyRelease(Qt.Key_Space)
        tile.highlighted = false
        tile.interactive = true
    }

    // ── Non-interactive (preview) ───────────────────────────────────────
    // A preview tile must never compute hover chrome. `enabled: false` was
    // not enough: hoverEnabled stayed true, so a tile appearing under the
    // cursor showed a hover frame and then animated back to idle.
    // A preview sits at idle chrome. Note this does NOT cover the actual
    // flash that motivated `interactive` — that needs a real pointer entering
    // the tile, which cannot be synthesized through a Control on offscreen
    // QPA. The suppression works by turning hoverEnabled off so `hovered`
    // never goes true; what is testable here is that nothing else moved.
    //
    // `highlighted` is deliberately NOT suppressed: it is caller-driven
    // selection state, not interaction.
    function test_non_interactive_sits_at_idle_chrome() {
        tile.interactive = false
        tryCompare(tile.plateItem.border, "color", Theme.palette.borderSubtle)
        compare(tile.artworkItem.brightness, 0)
        compare(tile.scale, 1.0)
        tile.interactive = true
    }

    function test_non_interactive_does_not_emit() {
        tile.interactive = false
        tile.mouseAreaItem.clicked(null)
        compare(clickSpy.count, 0)
        tile.interactive = true
    }

    function test_non_interactive_ignores_keyboard() {
        tile.interactive = false
        tile.forceActiveFocus()
        keyPress(Qt.Key_Space)
        tryCompare(tile, "pressed", false)
        keyRelease(Qt.Key_Space)
        compare(clickSpy.count, 0)
        tile.interactive = true
    }

    // A press latched at the moment `interactive` flips off must not stay
    // stuck — a preview would render pressed chrome it can never clear.
    function test_going_inert_mid_press_clears_pressed() {
        tile.forceActiveFocus()
        keyPress(Qt.Key_Space)
        tryCompare(tile, "pressed", true)
        tile.interactive = false
        tryCompare(tile, "pressed", false)
        tryCompare(tile.plateItem.border, "color", Theme.palette.borderSubtle)
        keyRelease(Qt.Key_Space)
        tile.interactive = true
    }

    function test_non_interactive_reports_not_active() {
        tile.interactive = false
        tile.forceActiveFocus()
        compare(tile.isActive, false)
        tile.interactive = true
    }

    // ── Disabled ────────────────────────────────────────────────────────
    // Matches LogosIconButton / LogosLink / LogosCopyableText, so a disabled
    // tile reads like every other disabled control in the module.
    function test_disabled_dims_the_tile() {
        compare(tile.opacity, 1.0)
        tile.enabled = false
        tryCompare(tile, "opacity", 0.4)
        tile.enabled = true
    }

    function test_disabled_multiplies_with_dimOpacity() {
        tile.dimOpacity = 0.5
        tile.enabled = false
        tryCompare(tile, "opacity", 0.2)
        tile.enabled = true
        tile.dimOpacity = 1.0
    }

    // ── Backplate ───────────────────────────────────────────────────────
    // A tile with no artwork keeps the caller-supplied colour: it is a
    // browsing affordance, not an interaction state.
    function test_no_artwork_uses_fallback_colour() {
        tile.source = ""
        tile.fallbackColor = "#4a90d9"
        tryCompare(tile.plateItem, "color", "#4a90d9")
    }

    // With artwork present the plate is the interaction surface, so the
    // caller's fallback must not leak into it.
    //
    // Note the ordering: the plate has a `Behavior on color`, and tryCompare
    // matches on its FIRST poll. Asserting a value the plate is animating
    // AWAY from therefore passes spuriously. Drive it to the fallback first,
    // then introduce artwork, so the assertion is on the arrival value.
    function test_artwork_present_ignores_fallback_colour() {
        tile.source = ""
        tile.fallbackColor = "#4a90d9"
        tryCompare(tile.plateItem, "color", "#4a90d9")

        tile.source = "qrc:/test-icon.png"
        tryCompare(tile.plateItem, "color", Theme.palette.surface)
    }

    // ── What is actually on screen ──────────────────────────────────────
    function test_shows_monogram_when_no_artwork() {
        tile.source = ""
        compare(tile.showsMonogram, true)
        compare(tile.showsArtwork, false)
        // NOT asserting monogramItem.visible / artworkItem.visible: Item.visible
        // is *effective* visibility (the AND of the ancestor chain) and reports
        // false in an offscreen run even when the local binding is correct.
        // showsArtwork/showsMonogram exist precisely so this is assertable.
    }

    function test_shows_artwork_when_source_set() {
        tile.source = "qrc:/test-icon.png"
        compare(tile.showsArtwork, true)
        compare(tile.showsMonogram, false)
    }

    function test_artwork_and_monogram_are_mutually_exclusive() {
        tile.source = ""
        verify(tile.showsMonogram !== tile.showsArtwork)
        tile.source = "qrc:/test-icon.png"
        verify(tile.showsMonogram !== tile.showsArtwork)
    }

    // ── Fringe regression ───────────────────────────────────────────────
    // The artwork must stop INSIDE the plate's stroke. Sharing the boundary
    // put two independently-antialiased curves on the same pixels, so a
    // saturated icon bled around and through the semi-transparent stroke —
    // invisible on a grey icon, obvious on an orange one.
    function test_artwork_is_inset_within_the_border() {
        tile.source = "qrc:/test-icon.png"
        const bw = tile.plateItem.border.width
        verify(bw >= 1)
        compare(tile.artworkItem.width, tile.width - 2 * bw)
        compare(tile.artworkItem.height, tile.height - 2 * bw)
        compare(tile.artworkItem.radius, tile.radius - bw)
    }

    // ── Monogram ────────────────────────────────────────────────────────
    function test_monogram_from_label() {
        compare(tile.monogram, "WA")
    }

    function test_monogram_follows_label() {
        tile.label = "Storage"
        compare(tile.monogram, "ST")
    }

    function test_hasArtwork_tracks_source() {
        compare(tile.hasArtwork, false)
        tile.source = "qrc:/test-icon.png"
        compare(tile.hasArtwork, true)
    }
}
