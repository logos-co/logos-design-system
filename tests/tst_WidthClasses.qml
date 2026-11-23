import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import LogosTests

// Layout follows the width of the app's own area. The host keeps each view's
// engine told its width, and a phone-width view gets touch-size targets.
TestCase {
    id: tc
    name: "WidthClasses"
    when: windowShown

    function cleanup() {
        Theme.viewWidth = 0
        ThemeManager.setDensity("")
    }

    function test_windowClass_data() {
        return [
            { tag: "390",  width: 390,  windowClass: "phone" },
            { tag: "599",  width: 599,  windowClass: "phone" },
            { tag: "600",  width: 600,  windowClass: "tablet" },
            { tag: "839",  width: 839,  windowClass: "tablet" },
            { tag: "840",  width: 840,  windowClass: "desktop" },
            { tag: "1280", width: 1280, windowClass: "desktop" },
        ]
    }

    function test_windowClass(data) {
        compare(Theme.windowClass(data.width), data.windowClass)
    }

    function test_pageMargin() {
        compare(Theme.pageMargin(390), Theme.spacing.large)
        compare(Theme.pageMargin(700), Theme.spacing.xlarge)
        compare(Theme.pageMargin(1280), Theme.spacing.xxlarge)
    }

    function test_tileWidth() {
        compare(Theme.tileWidth(390), Theme.layouts.cardGrid.tileWidthPhone)
        compare(Theme.tileWidth(700), Theme.layouts.cardGrid.tileWidthTablet)
        compare(Theme.tileWidth(1280), Theme.layouts.cardGrid.tileWidthDesktop)
        // Three across a phone, from its narrowest, inside the page margins.
        compare(Math.floor((360 - 2 * Theme.pageMargin(360)) / Theme.tileWidth(360)), 3)
    }

    // Until the host says otherwise, a view is a desktop one.
    function test_unknownViewWidthIsDesktop() {
        compare(Theme.viewWidth, 0)
        compare(Theme.viewClass, "desktop")
        verify(!Theme.touch)
    }

    function test_viewClassFollowsTheViewWidth() {
        Theme.viewWidth = 390
        compare(Theme.viewClass, "phone")
        Theme.viewWidth = 700
        compare(Theme.viewClass, "tablet")
        Theme.viewWidth = 1280
        compare(Theme.viewClass, "desktop")
    }

    // A phone-width view gets touch-size targets at any density; only density
    // scales sizes.
    function test_phoneWidthFloorsTappablesWithoutScaling() {
        Theme.viewWidth = 390
        compare(Theme.density, "comfortable")
        verify(Theme.touch)
        compare(Theme.controls.combo.height, Theme.size.touchTarget)
        compare(Theme.controls.button.compactHeight, Theme.size.touchTarget)
        compare(Theme.controls.field.height, Theme.size.touchTarget)
        compare(Theme.controls.button.height, 44)
    }

    function test_tabletWidthIsNotTouch() {
        Theme.viewWidth = 700
        verify(!Theme.touch)
        compare(Theme.controls.combo.height, 32)
    }
}
