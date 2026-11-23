import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import Logos.Layouts

// A page's title and subtitle with a search on their right; on a phone the
// search is a 🔍 at the end of the title's line that opens across it.
TestCase {
    id: root
    name: "LogosPageHeader"
    width: 1100
    height: 300
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
    when: windowShown

    Component {
        id: header
        LogosPageHeader {
            title: "Package Manager"
            subtitle: "Manage your plugins and packages."
            searchEnabled: true
            searchPlaceholder: "Search packages"
            searchWidth: 605
        }
    }

    Component {
        id: submittedSpy
        SignalSpy { signalName: "searchSubmitted" }
    }

    function init() {
        failOnWarning(/Binding loop/)
    }

    function create(width, properties) {
        const item = createTemporaryObject(header, root, Object.assign({ width: width }, properties || {}))
        verify(item)
        waitForRendering(item)
        return item
    }

    function xOf(item, within) { return item.mapToItem(within, 0, 0).x }
    function yOf(item, within) { return item.mapToItem(within, 0, 0).y }

    // Beside the title and subtitle, a field searchWidth wide, as tall as a
    // search field, centred on the two lines.
    function test_a_search_field_beside_the_title() {
        const h = create(1100)
        const search = h.searchItem
        verify(search.visible)
        verify(search.expanded && !search.folds, "a field, not an icon")
        compare(search.width, 605)
        compare(search.searchBarItem.height, Theme.controls.search.height)
        compare(xOf(search, h) + search.width, 1100, "on the right")
        verify(xOf(search, h) >= h.titleItem.implicitWidth, "clear of the title")
        verify(h.subtitleItem.visible)
        fuzzyCompare(yOf(search, h) + search.height / 2, h.height / 2, 1, "centred on the title and subtitle")
    }

    // The search gives way to the title, which keeps its line: given exactly
    // its width, a title had wrapped.
    function test_the_search_gives_way_to_the_title() {
        const h = create(700)
        compare(h.titleItem.lineCount, 1)
        verify(h.searchItem.width < 605)
        verify(xOf(h.searchItem, h) >= h.titleItem.implicitWidth)
        verify(xOf(h.searchItem, h) + h.searchItem.width <= 700 + 0.5)
    }

    function test_no_search_until_enabled() {
        const h = create(1100, { searchEnabled: false })
        verify(!h.searchItem.visible)
        h.searchItem.text = "chat"
        compare(h.searchText, "", "a page without a search filters nothing")
        h.searchEnabled = true
        compare(h.searchText, "chat")
    }

    function test_an_empty_title_or_subtitle_takes_no_room() {
        const h = create(390)
        const both = h.height
        h.subtitle = ""
        waitForRendering(h)
        verify(!h.subtitleItem.visible)
        compare(h.height, Math.max(h.titleItem.height, h.searchItem.height))
        verify(h.height < both)
        h.title = ""
        verify(!h.titleItem.visible)
    }

    // On a phone a 🔍 at the end of the title's line, not a row of its own.
    // A phone-wide header can say less: a short title in place of a long one,
    // and no subtitle that only says the title again. Wider, both as they are.
    function test_a_phone_header_can_say_less_data() {
        return [{ tag: "phone", width: 390, phone: true }, { tag: "desktop", width: 1000, phone: false }]
    }

    function test_a_phone_header_can_say_less(data) {
        const h = create(data.width, { title: "Package Manager", subtitle: "Manage your plugins and packages.",
                                       shortTitle: "Packages", subtitleOnPhone: false })
        compare(h.titleItem.text, data.phone ? "Packages" : "Package Manager")
        compare(h.subtitleItem.visible, !data.phone)
        if (data.phone)
            verify(h.height <= Math.max(h.titleItem.height, Theme.size.touchTarget) + 0.5,
                   "the title's line alone, " + h.height + " px")
    }

    // Unless asked, a phone-wide header keeps its title and subtitle.
    function test_a_phone_header_keeps_both_by_default() {
        const h = create(390, { title: "Package Manager", subtitle: "Manage your plugins and packages." })
        compare(h.titleItem.text, "Package Manager")
        verify(h.subtitleItem.visible)
    }

    function test_phone_search_folds_into_the_title_line() {
        const h = create(390)
        const search = h.searchItem
        verify(search.folds && !search.expanded, "an icon")
        compare(search.width, Theme.size.touchTarget)
        compare(xOf(search, h) + search.width, 390, "at the end")
        fuzzyCompare(yOf(search, h) + search.height / 2, yOf(h.titleItem, h) + h.titleItem.height / 2,
                     Math.abs(search.height - h.titleItem.height) / 2 + 1, "on the title's line")
        verify(yOf(h.subtitleItem, h) >= yOf(h.titleItem, h) + h.titleItem.height, "the subtitle under them")
    }

    // A tap opens it across the title's line in place of the title; ✕ clears
    // and folds it, and the title is back.
    function test_phone_search_opens_across_the_title_line() {
        const h = create(390)
        const search = h.searchItem
        mouseClick(search.openButtonItem)
        verify(search.expanded)
        verify(!h.titleItem.visible)
        tryVerify(() => search.searchBarItem.textInput.activeFocus)
        waitForRendering(h)
        compare(search.width, 390, "across the line")
        keyClick("c")
        compare(h.searchText, "c")

        mouseClick(search.closeButtonItem)
        verify(!search.expanded)
        compare(h.searchText, "")
        verify(h.titleItem.visible)
    }

    function test_phone_escape_folds_the_search() {
        const h = create(390)
        h.openSearch()
        h.searchItem.text = "chat"
        keyClick(Qt.Key_Escape)
        verify(!h.searchItem.expanded)
        compare(h.searchText, "")
    }

    // A query survives a change of width: on a phone the search stays open
    // with it, in place of the title.
    function test_query_survives_a_change_of_width() {
        const h = create(1100)
        h.searchItem.text = "chat"
        h.width = 390
        waitForRendering(h)
        verify(h.searchItem.expanded)
        verify(!h.titleItem.visible)
        compare(h.searchText, "chat")
        h.width = 1100
        waitForRendering(h)
        verify(!h.searchItem.folds)
        verify(h.titleItem.visible)
        compare(h.searchText, "chat")
    }

    function test_shortcut_hint_beside_the_title_only() {
        const h = create(1100, { searchShortcutHint: "Ctrl+K" })
        compare(h.searchItem.shortcutHint, "Ctrl+K")
        h.width = 390
        compare(h.searchItem.shortcutHint, "")
    }

    function test_openSearch_data() {
        return [
            { tag: "phone",   width: 390 },
            { tag: "desktop", width: 1100 },
        ]
    }

    // Focused with its query selected, opening it on a phone; without a
    // search, nothing.
    function test_openSearch(data) {
        const h = create(data.width, { searchEnabled: false })
        h.openSearch()
        verify(!h.searchItem.searchBarItem.textInput.activeFocus)

        h.searchEnabled = true
        h.openSearch()
        verify(h.searchItem.expanded)
        tryVerify(() => h.searchItem.searchBarItem.textInput.activeFocus)
        h.searchItem.text = "chat"
        h.forceActiveFocus()
        h.openSearch()
        tryVerify(() => h.searchItem.searchBarItem.textInput.activeFocus)
        compare(h.searchItem.searchBarItem.textInput.selectedText, "chat")
        h.closeSearch()
        compare(h.searchText, "")
    }

    // Given a query, it searches for that, open on a phone.
    function test_openSearch_with_a_query_data() {
        return [
            { tag: "phone",   width: 390 },
            { tag: "desktop", width: 1100 },
        ]
    }

    function test_openSearch_with_a_query(data) {
        const h = create(data.width)
        h.openSearch("wallet")
        compare(h.searchText, "wallet")
        verify(h.searchItem.expanded)
        compare(h.titleItem.visible, data.width >= 600, "on a phone it is open across the title's line")
    }

    function test_enter_submits_the_query() {
        const h = create(1100)
        const spy = createTemporaryObject(submittedSpy, root, { target: h })
        h.openSearch()
        h.searchItem.text = "chat"
        keyClick(Qt.Key_Return)
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], "chat")
    }
}
