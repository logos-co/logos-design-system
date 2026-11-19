import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import LogosTests

// LogosPaginator in less width than all of it needs.
TestCase {
    id: root
    name: "LogosPaginatorNarrow"
    width: 1000
    height: 200
    // These tests read which parts show; that needs a visible TestCase.
    visible: true
    when: windowShown

    Component {
        id: pagerComp
        LogosPaginator {
            totalCount: 150
            pageSize: 10
            currentPage: 8
            pageInfoText: "Showing 71–80 of 150"
            pageSizeOptions: [10, 20, 50, 100]
        }
    }

    Component { id: spyComp; SignalSpy { signalName: "pageRequested" } }

    readonly property var everything: ["info", "first", "prev", "pages", "next", "last", "sizes"]

    function cleanup() {
        ThemeManager.setDensity("")
    }

    function make(width, properties) {
        const pager = createTemporaryObject(pagerComp, root, Object.assign({ width: width }, properties || {}))
        waitForRendering(pager)
        return pager
    }

    function resize(pager, width) {
        pager.width = width
        waitForRendering(pager)
    }

    function parts(pager) {
        return { info: pager.infoLabel, first: pager.firstButton, prev: pager.prevButton,
                 pages: pager.pagesItem, position: pager.positionLabel, next: pager.nextButton,
                 last: pager.lastButton, sizes: pager.pageSizeSelector }
    }

    function shown(pager) {
        const all = parts(pager)
        return Object.keys(all).filter(name => all[name].visible)
    }

    // How far right the parts shown reach, in the paginator.
    function reach(pager) {
        const all = parts(pager)
        let right = 0
        for (const name in all) {
            const item = all[name]
            if (item.visible)
                right = Math.max(right, item.mapToItem(pager, item.width, 0).x)
        }
        return right
    }

    function test_all_of_it_where_it_fits() {
        const pager = make(1000)
        verify(!pager.condensed)
        compare(shown(pager), everything)
        compare(pager.pageCells.count, 7)
    }

    function test_sized_by_its_content_it_shows_all_of_it() {
        const pager = createTemporaryObject(pagerComp, root)
        waitForRendering(pager)
        compare(pager.width, pager.implicitWidth)
        compare(shown(pager), everything)
    }

    function test_its_implicit_width_is_all_of_its_row() {
        const variants = [{}, { pageInfoText: "" }, { pageSizeOptions: [] }, { showFirstLast: false },
                          { showPrevNext: false }, { totalCount: 30 }]
        for (let i = 0; i < variants.length; ++i) {
            const pager = make(1200, variants[i])
            compare(pager.implicitWidth, pager.contentItem.implicitWidth, JSON.stringify(variants[i]))
        }
    }

    function test_condensed_its_implicit_width_stays() {
        const pager = make(1200)
        const full = pager.implicitWidth
        resize(pager, 300)
        verify(pager.condensed)
        compare(pager.implicitWidth, full)
    }

    function test_all_of_it_fits_down_to_its_narrowest() {
        const pager = make(1000)
        const d = pager._d
        const narrowest = Math.ceil(d.fullNavWidth + d.infoWidth + Theme.controls.paginator.pageSizeMinWidth + d.gap)
        resize(pager, narrowest)
        compare(shown(pager), everything)
        verify(reach(pager) <= narrowest, "reaches " + reach(pager))
        verify(pager.pagesItem.mapToItem(pager, pager.pagesItem.implicitWidth, 0).x <= pager.nextButton.x)
    }

    function test_the_size_selector_gives_way_first() {
        const pager = make(1000)
        const d = pager._d
        resize(pager, Math.ceil(d.fullNavWidth + d.infoWidth + Theme.controls.paginator.pageSizeMinWidth + d.gap) - 1)
        compare(shown(pager), ["info", "first", "prev", "pages", "next", "last"])
        verify(reach(pager) <= pager.width)
    }

    function test_then_the_info_text() {
        const pager = make(1000)
        const d = pager._d
        resize(pager, Math.ceil(d.fullNavWidth + d.infoWidth) - 1)
        // The size selector still fits where the info text doesn't.
        compare(shown(pager), ["first", "prev", "pages", "next", "last", "sizes"])
        verify(reach(pager) <= pager.width)
        resize(pager, d.fullNavWidth)
        compare(shown(pager), ["first", "prev", "pages", "next", "last"])
        verify(!pager.condensed)
        verify(reach(pager) <= pager.width)
    }

    function test_then_the_page_numbers_condense() {
        const pager = make(1000)
        resize(pager, Math.ceil(pager._d.fullNavWidth) - 1)
        verify(pager.condensed)
        compare(pager.pageCells.count, 0)
        compare(pager.positionLabel.text, "8 / 15")
        compare(pager.positionLabel.Accessible.name, "Page 8 of 15")
        verify(shown(pager).indexOf("position") >= 0)
        verify(shown(pager).indexOf("pages") < 0)
    }

    function test_condensed_the_position_follows_the_page() {
        const pager = make(300)
        pager.currentPage = 15
        compare(pager.positionLabel.text, "15 / 15")
    }

    function test_condensed_first_and_last_show_while_they_fit() {
        const pager = make(300)
        const d = pager._d
        const withThem = Math.ceil(d.condensedWidth + 2 * (d.buttonSize + d.gap))
        resize(pager, withThem)
        compare(shown(pager), ["first", "prev", "position", "next", "last"])
        resize(pager, withThem - 1)
        compare(shown(pager), ["prev", "position", "next"])
        verify(reach(pager) <= pager.width)
    }

    function test_condensed_the_info_text_and_sizes_show_while_they_fit() {
        const pager = make(300)
        const d = pager._d
        const nav = d.condensedWidth + 2 * (d.buttonSize + d.gap)
        resize(pager, Math.ceil(nav + d.infoWidth))
        compare(shown(pager), ["info", "first", "prev", "position", "next", "last"])
        verify(pager.condensed)
        verify(reach(pager) <= pager.width)
        pager.pageInfoText = ""
        resize(pager, Math.ceil(nav + Theme.controls.paginator.pageSizeMinWidth + d.gap))
        compare(shown(pager), ["first", "prev", "position", "next", "last", "sizes"])
        verify(pager.condensed)
        verify(reach(pager) <= pager.width)
    }

    function test_condensed_shows_prev_and_next_even_when_turned_off() {
        compare(shown(make(1000, { showPrevNext: false })).indexOf("prev"), -1)
        const pager = make(300, { showPrevNext: false })
        verify(pager.condensed)
        compare(shown(pager), ["first", "prev", "position", "next", "last"])
    }

    function test_condensed_parts_stay_inside() {
        const widths = [440, 360, 300, 240, 180]
        for (let i = 0; i < widths.length; ++i) {
            const pager = make(widths[i])
            verify(pager.condensed, widths[i])
            verify(reach(pager) <= widths[i], widths[i] + " reaches " + reach(pager))
        }
    }

    function test_condensed_arrows_still_page() {
        const pager = make(300)
        const spy = createTemporaryObject(spyComp, root, { target: pager })
        mouseClick(pager.nextButton)
        mouseClick(pager.lastButton)
        mouseClick(pager.prevButton)
        compare(spy.count, 3)
        compare(spy.signalArguments[0][0], 9)
        compare(spy.signalArguments[1][0], 15)
        compare(spy.signalArguments[2][0], 7)
    }

    function test_arrow_keys_skip_the_position() {
        const pager = make(300)
        pager.prevButton.forceActiveFocus(Qt.TabFocusReason)
        keyClick(Qt.Key_Right)
        verify(pager.nextButton.activeFocus)
        keyClick(Qt.Key_Left)
        verify(pager.prevButton.activeFocus)
    }

    function test_condensed_on_a_touch_phone() {
        ThemeManager.setDensity("touch")
        const pager = make(358)
        verify(pager.condensed)
        compare(pager.nextButton.height, Theme.controls.paginator.buttonSize)
        verify(Theme.controls.paginator.buttonSize >= Theme.size.touchTarget)
        verify(reach(pager) <= 358)
    }
}
