import QtQuick
import QtTest

import Logos.Controls

TestCase {
    id: root
    name: "LogosPaginator"
    width: 800
    height: 100
    when: windowShown

    LogosPaginator {
        id: pager
        totalCount: 10
        pageSize: 1
        currentPage: 1
    }

    SignalSpy {
        id: requestedSpy
        target: pager
        signalName: "pageRequested"
    }

    SignalSpy {
        id: sizeSpy
        target: pager
        signalName: "pageSizeRequested"
    }

    function init() {
        requestedSpy.clear()
        sizeSpy.clear()
        // Tests historically operated on pageCount directly. The public API
        // now derives pageCount from totalCount/pageSize, so we use a 1:1
        // mapping (pageSize=1) here so `totalCount = N` ⇒ `pageCount = N`.
        pager.pageSize = 1
        pager.totalCount = 10
        pager.currentPage = 1
        pager.siblingCount = 1
        pager.boundaryCount = 1
        pager.showFirstLast = true
        pager.showPrevNext = true
        pager.pageInfoText = ""
        pager.pageSizeOptions = []
        pager.pageSizeLabel = "/ page"
    }

    function test_totalCount_round_trips() {
        pager.totalCount = 25
        compare(pager.totalCount, 25)
        compare(pager.pageCount, 25)   // pageSize = 1 in init
    }

    function test_pageCount_derived_from_totalCount_and_pageSize() {
        pager.pageSize = 10
        pager.totalCount = 100
        compare(pager.pageCount, 10)
        pager.pageSize = 20
        compare(pager.pageCount, 5)
        pager.totalCount = 101         // partial page rounds up
        compare(pager.pageCount, 6)
    }

    function test_pageCount_minimum_is_one_for_empty_total() {
        pager.totalCount = 0
        verify(pager.pageCount >= 1)
    }

    function test_currentPage_round_trips() {
        pager.totalCount = 50
        pager.currentPage = 7
        compare(pager.currentPage, 7)
    }

    function test_pageInfoText_visibility_tracks_property() {
        pager.pageInfoText = "Showing 1–10 of 100"
        compare(pager.infoLabel.text, "Showing 1–10 of 100")
    }

    function test_prev_disabled_on_first_page() {
        pager.currentPage = 1
        compare(pager.prevButton.enabled, false)
        compare(pager.firstButton.enabled, false)
    }

    function test_next_disabled_on_last_page() {
        pager.totalCount = 5
        pager.currentPage = 5
        compare(pager.nextButton.enabled, false)
        compare(pager.lastButton.enabled, false)
    }

    function test_prev_enabled_in_middle() {
        pager.totalCount = 10
        pager.currentPage = 5
        compare(pager.prevButton.enabled, true)
        compare(pager.nextButton.enabled, true)
    }

    function test_pageRequested_emitted_with_clamped_value() {
        pager._d.request(0)             // below 1 → clamped to 1
        compare(requestedSpy.count, 1)
        compare(requestedSpy.signalArguments[0][0], 1)

        pager._d.request(999)           // above pageCount → clamped to pageCount
        compare(requestedSpy.count, 2)
        compare(requestedSpy.signalArguments[1][0], pager.pageCount)
    }

    function test_small_pageCount_shows_all_pages_no_ellipsis() {
        pager.totalCount = 5
        pager.currentPage = 3
        const pages = pager._d.computedPages()
        compare(pages.length, 5)
        compare(pages.indexOf("…"), -1, "no ellipsis when all pages fit")
    }

    function test_middle_currentPage_shows_two_ellipses() {
        pager.totalCount = 30
        pager.currentPage = 15
        pager.siblingCount = 1
        pager.boundaryCount = 1
        const pages = pager._d.computedPages()
        // Expect: [1, "…", 14, 15, 16, "…", 30]
        let ellipses = 0
        for (let i = 0; i < pages.length; i++)
            if (pages[i] === "…") ellipses++
        compare(ellipses, 2)
        verify(pages.indexOf(1) !== -1)
        verify(pages.indexOf(15) !== -1)
        verify(pages.indexOf(30) !== -1)
    }

    function test_currentPage_near_start_has_one_trailing_ellipsis() {
        pager.totalCount = 30
        pager.currentPage = 2
        pager.siblingCount = 1
        pager.boundaryCount = 1
        const pages = pager._d.computedPages()
        let ellipses = 0
        for (let i = 0; i < pages.length; i++)
            if (pages[i] === "…") ellipses++
        compare(ellipses, 1)
    }

    function test_inspection_aliases_resolve() {
        verify(pager.firstButton, "firstButton must resolve")
        verify(pager.prevButton, "prevButton must resolve")
        verify(pager.nextButton, "nextButton must resolve")
        verify(pager.lastButton, "lastButton must resolve")
        verify(pager.pagesItem, "pagesItem must resolve")
        verify(pager.pageCells, "pageCells (Repeater) must resolve")
    }

    function test_currentPage_clamped_renders_within_bounds() {
        pager.totalCount = 5
        pager.currentPage = 99   // out of range
        // Even with an out-of-range currentPage, _computedPages clamps to n.
        const pages = pager._d.computedPages()
        verify(pages.length > 0)
    }

    // ─── Page-size selector ──────────────────────────────────────────────

    function test_pageSize_round_trips() {
        pager.pageSize = 50
        compare(pager.pageSize, 50)
    }

    function test_pageSizeOptions_round_trips() {
        pager.pageSizeOptions = [10, 20, 50]
        compare(pager.pageSizeOptions.length, 3)
        compare(pager.pageSizeOptions[0], 10)
        compare(pager.pageSizeOptions[2], 50)
    }

    function test_sizeSelector_label_includes_suffix() {
        pager.pageSizeOptions = [10, 25]
        const labels = pager._d.sizeOptionLabels()
        compare(labels.length, 2)
        compare(labels[0], "10 / page")
        compare(labels[1], "25 / page")
    }

    function test_sizeSelector_label_omits_suffix_when_empty() {
        pager.pageSizeOptions = [10, 25]
        pager.pageSizeLabel = ""
        const labels = pager._d.sizeOptionLabels()
        compare(labels[0], "10")
        compare(labels[1], "25")
    }

    function test_sizeSelector_label_empty_when_options_empty() {
        pager.pageSizeOptions = []
        compare(pager._d.sizeOptionLabels().length, 0)
    }

    function test_pageSizeRequested_emitted_with_selected_size() {
        pager.pageSizeOptions = [10, 20, 50, 100]
        pager.pageSize = 20
        pager._d.requestSize(2)   // index 2 → 50
        compare(sizeSpy.count, 1)
        compare(sizeSpy.signalArguments[0][0], 50)
    }

    function test_pageSizeRequested_ignores_out_of_range_index() {
        pager.pageSizeOptions = [10, 20]
        pager._d.requestSize(99)   // out of range — no emit
        pager._d.requestSize(-1)   // out of range — no emit
        compare(sizeSpy.count, 0)
    }

    // ─── Keyboard / focus ────────────────────────────────────────────────

    function test_wrapper_is_not_a_tab_stop() {
        compare(pager.activeFocusOnTab, false)
        compare(pager.focusPolicy, Qt.NoFocus)
    }

    function test_nav_buttons_join_tab_focus_chain() {
        compare(pager.nextButton.activeFocusOnTab, true)
        compare(pager.nextButton.focusPolicy, Qt.StrongFocus)
        compare(pager.prevButton.activeFocusOnTab, true)
    }

    function test_focusableNavItems_skips_ellipsis_cells() {
        pager.totalCount = 30
        pager.currentPage = 15
        waitForRendering(pager)
        const items = pager._d.focusableNavItems()
        verify(items.length > 0)
        for (let i = 0; i < items.length; ++i)
            verify(!items[i].isEllipsis, "ellipsis cells must not be focusable")
    }

    function test_focusableNavItems_omits_disabled_prev_on_first_page() {
        pager.currentPage = 1
        waitForRendering(pager)
        compare(pager.prevButton.enabled, false)
        const items = pager._d.focusableNavItems()
        // Prev is disabled — moving left from the first focusable must fail.
        items[0].forceActiveFocus()
        tryCompare(items[0], "activeFocus", true)
        compare(pager._d.moveFocus(-1), false)
    }

    function test_moveFocus_right_and_left() {
        pager.currentPage = 5
        waitForRendering(pager)
        const items = pager._d.focusableNavItems()
        verify(items.length >= 2)
        items[0].forceActiveFocus()
        tryCompare(items[0], "activeFocus", true)
        verify(pager._d.moveFocus(1))
        tryCompare(items[1], "activeFocus", true)
        verify(pager._d.moveFocus(-1))
        tryCompare(items[0], "activeFocus", true)
    }

    function test_moveFocus_stops_at_ends() {
        pager.currentPage = 5
        waitForRendering(pager)
        const items = pager._d.focusableNavItems()
        items[0].forceActiveFocus()
        tryCompare(items[0], "activeFocus", true)
        compare(pager._d.moveFocus(-1), false)
        tryCompare(items[0], "activeFocus", true)

        items[items.length - 1].forceActiveFocus()
        tryCompare(items[items.length - 1], "activeFocus", true)
        compare(pager._d.moveFocus(1), false)
        tryCompare(items[items.length - 1], "activeFocus", true)
    }

    function test_moveFocus_false_when_nothing_focused() {
        root.forceActiveFocus()
        compare(pager._d.moveFocus(1), false)
    }

    function test_moveFocus_between_trailing_nav_buttons() {
        pager.currentPage = 5
        waitForRendering(pager)
        const items = pager._d.focusableNavItems()
        verify(items.length >= 2)
        const nextIdx = items.length - 2
        const lastIdx = items.length - 1
        items[nextIdx].forceActiveFocus()
        tryCompare(items[nextIdx], "activeFocus", true)
        verify(pager._d.moveFocus(1))
        tryCompare(items[lastIdx], "activeFocus", true)
        verify(pager._d.moveFocus(-1))
        tryCompare(items[nextIdx], "activeFocus", true)
    }

    function test_arrow_keys_move_focus_between_nav_items() {
        pager.currentPage = 5
        waitForRendering(pager)
        const items = pager._d.focusableNavItems()
        verify(items.length >= 2)
        // Start on a nav IconButton (first) — ←/→ must move focus, not be
        // swallowed by the button's Space/Enter Keys handler.
        items[0].forceActiveFocus(Qt.TabFocusReason)
        tryCompare(items[0], "activeFocus", true)
        keyClick(Qt.Key_Right)
        tryCompare(items[1], "activeFocus", true)
        compare(pager._d.navFocusBorderWidth(items[1]), 2)
        keyClick(Qt.Key_Left)
        tryCompare(items[0], "activeFocus", true)
        compare(pager._d.navFocusBorderWidth(items[0]), 2)
    }

    function test_arrow_keys_from_page_cell_reach_nav_button() {
        pager.currentPage = 5
        waitForRendering(pager)
        const items = pager._d.focusableNavItems()
        // Find first page cell in the focusable list (after first+prev).
        let cellIdx = -1
        for (let i = 0; i < items.length; ++i) {
            if (items[i] !== pager.firstButton && items[i] !== pager.prevButton
                    && items[i] !== pager.nextButton && items[i] !== pager.lastButton) {
                cellIdx = i
                break
            }
        }
        verify(cellIdx >= 0)
        verify(cellIdx + 1 < items.length)
        items[cellIdx].forceActiveFocus()
        tryCompare(items[cellIdx], "activeFocus", true)
        keyClick(Qt.Key_Right)
        tryCompare(items[cellIdx + 1], "activeFocus", true)
    }

    function test_nav_icon_buttons_are_tab_stops_when_enabled() {
        pager.currentPage = 5
        waitForRendering(pager)
        compare(pager.firstButton.activeFocusOnTab, true)
        compare(pager.prevButton.activeFocusOnTab, true)
        compare(pager.nextButton.activeFocusOnTab, true)
        compare(pager.lastButton.activeFocusOnTab, true)
        compare(pager.firstButton.focusPolicy, Qt.StrongFocus)
        compare(pager.firstButton.enabled, true)
        compare(pager.nextButton.enabled, true)
    }

    function test_focus_stays_in_nav_when_reaching_first_page() {
        pager.currentPage = 5
        waitForRendering(pager)
        pager.firstButton.forceActiveFocus(Qt.TabFocusReason)
        tryCompare(pager.firstButton, "activeFocus", true)
        keyClick(Qt.Key_Space)
        compare(requestedSpy.count, 1)
        compare(requestedSpy.signalArguments[0][0], 1)
        // Consumer applies the page — «/‹ disable and cells may rebuild.
        pager.currentPage = 1
        waitForRendering(pager)
        tryVerify(function() {
            const items = pager._d.focusableNavItems()
            for (let i = 0; i < items.length; ++i) {
                if (items[i].activeFocus)
                    return true
            }
            return false
        })
        // Prefer the current page cell after landing on page 1.
        let currentCell = null
        for (let i = 0; i < pager.pageCells.count; ++i) {
            const cell = pager.pageCells.itemAt(i)
            if (cell && cell.isCurrent) {
                currentCell = cell
                break
            }
        }
        verify(currentCell !== null)
        tryCompare(currentCell, "activeFocus", true)
    }

    function test_left_at_first_nav_item_keeps_focus() {
        pager.currentPage = 1
        waitForRendering(pager)
        const items = pager._d.focusableNavItems()
        verify(items.length >= 1)
        items[0].forceActiveFocus(Qt.TabFocusReason)
        tryCompare(items[0], "activeFocus", true)
        keyClick(Qt.Key_Left)
        tryCompare(items[0], "activeFocus", true)
    }

    function test_space_on_next_requests_next_page() {
        pager.currentPage = 5
        waitForRendering(pager)
        pager.nextButton.forceActiveFocus()
        tryCompare(pager.nextButton, "activeFocus", true)
        keyClick(Qt.Key_Space)
        compare(requestedSpy.count, 1)
        compare(requestedSpy.signalArguments[0][0], 6)
    }

    function test_page_cell_space_requests_that_page() {
        pager.totalCount = 5
        pager.currentPage = 1
        waitForRendering(pager)
        let target = null
        for (let i = 0; i < pager.pageCells.count; ++i) {
            const cell = pager.pageCells.itemAt(i)
            if (cell && !cell.isEllipsis && !cell.isCurrent) {
                target = cell
                break
            }
        }
        verify(target !== null)
        target.forceActiveFocus()
        tryCompare(target, "activeFocus", true)
        keyClick(Qt.Key_Space)
        compare(requestedSpy.count, 1)
        verify(requestedSpy.signalArguments[0][0] >= 2)
    }
}
