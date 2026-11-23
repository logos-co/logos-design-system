import QtQuick
import QtQuick.Layouts
import QtTest

import Logos.Theme
import Logos.Controls
import Logos.Layouts

TestCase {
    id: root
    name: "LogosSections"
    width: 1100
    height: 500
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
    when: windowShown

    Component {
        id: settings
        LogosSections {
            id: sections
            height: 480
            title: "Settings"
            subtitle: "Manage modules, apps and dashboards."
            listTitle: "Sections"
            sections: [{ title: "Dashboard" }, { title: "Apps" }, { title: "Appearance" }]
            searchEnabled: currentIndex === 1
            searchPlaceholder: "Search apps"
            searchWidth: 605
            readonly property alias pages: stack
            StackLayout {
                id: stack
                anchors.fill: parent
                currentIndex: sections.currentIndex
                Item { objectName: "dashboard" }
                Item { objectName: "apps" }
                Item { objectName: "appearance" }
            }
        }
    }

    Component {
        id: spyComp
        SignalSpy { signalName: "backRequested" }
    }

    Component {
        id: submittedSpy
        SignalSpy { signalName: "searchSubmitted" }
    }

    function create(width, properties) {
        const props = Object.assign({ width: width }, properties || {})
        const s = createTemporaryObject(settings, root, props)
        waitForRendering(s)
        return s
    }

    function pill(s, index) { return s.listItem.itemAtIndex(index) }

    // Inside the sections and not past their right edge.
    function within(item, s) {
        const p = item.mapToItem(s, 0, 0)
        return p.x >= 0 && p.x + item.width <= s.width + 0.5
    }

    function test_beside_the_section_from_tablet_width_data() {
        return [
            { tag: "tablet",  width: 700,  list: Theme.layouts.sections.tabletListWidth },
            { tag: "desktop", width: 1000, list: Theme.layouts.sections.listWidth },
        ]
    }

    function test_beside_the_section_from_tablet_width(data) {
        const s = create(data.width)
        verify(s.twoPane)
        verify(!s.showingSection)
        verify(s.titleItem.visible)
        verify(s.subtitleItem.visible)
        verify(!s.backRowItem.visible)
        verify(!s.phoneListItem.visible)
        compare(s.listItem.width, data.list)
        compare(s.listItem.headerItem.text, "Sections")
        verify(s.sectionItem.visible)
        verify(s.sectionItem.mapToItem(s, 0, 0).x > s.listItem.mapToItem(s, 0, 0).x + data.list - 1,
               "the section is beside the list")
        verify(within(s.sectionItem, s))

        verify(pill(s, 0).highlighted)
        mouseClick(pill(s, 2))
        compare(s.currentIndex, 2)
        verify(pill(s, 2).highlighted)
        verify(!pill(s, 0).highlighted)
        verify(!s.showingSection)
    }

    // The pages fill the card the section is in.
    function test_pages_go_into_the_section_card() {
        const s = create(1000)
        compare(s.pages.parent.parent, s.sectionItem)
        compare(s.pages.width, s.sectionItem.width)
    }

    // Beside the list a search field on the title's right, searchWidth wide,
    // as tall as a search field, for the sections that have one.
    function test_search_beside_the_title_only_for_its_section() {
        const s = create(1100)
        const search = s.searchItem
        verify(!search.visible, "no search on the Dashboard")
        s.currentIndex = 1
        waitForRendering(s)
        verify(search.visible)
        verify(search.expanded && !search.folds, "a field, not an icon")
        verify(search.mapToItem(s, 0, 0).y < s.sectionItem.mapToItem(s, 0, 0).y, "above the section")
        verify(search.mapToItem(s, 0, 0).x > s.titleItem.mapToItem(s, 0, 0).x + s.titleItem.implicitWidth,
               "on the title's right")
        compare(search.width, 605)
        compare(search.searchBarItem.height, Theme.controls.search.height)
        compare(search.searchBarItem.placeholderText, "Search apps")
        s.currentIndex = 0
        verify(!search.visible)
    }

    // Narrower than the title and searchWidth, the search gives way.
    function test_search_shrinks_rather_than_run_off_the_page() {
        const s = create(700)
        s.currentIndex = 1
        waitForRendering(s)
        verify(s.searchItem.width < 605)
        verify(within(s.searchItem, s))
        verify(s.searchItem.mapToItem(s, 0, 0).x >= s.titleItem.mapToItem(s, 0, 0).x + s.titleItem.implicitWidth,
               "the title keeps its width")
    }

    function test_searchText_is_the_query_while_there_is_a_search() {
        const s = create(1000)
        s.currentIndex = 1
        s.searchItem.text = "wallet"
        compare(s.searchText, "wallet")
        s.searchEnabled = false
        compare(s.searchText, "", "a section without a search filters nothing")
        s.searchEnabled = true
        compare(s.searchText, "wallet")
        s.closeSearch()
        compare(s.searchText, "")
    }

    // A keyboard shortcut is shown beside the list, not on a phone.
    function test_shortcut_hint_beside_the_list_only() {
        const s = create(1000, { searchShortcutHint: "Ctrl+K" })
        s.currentIndex = 1
        compare(s.searchItem.shortcutHint, "Ctrl+K")
        s.width = 390
        verify(s.showingSection)
        compare(s.searchItem.shortcutHint, "")
    }

    // Given a query, it searches for that, open on a phone.
    function test_openSearch_with_a_query_data() {
        return [
            { tag: "phone",   width: 390 },
            { tag: "desktop", width: 1000 },
        ]
    }

    function test_openSearch_with_a_query(data) {
        const s = create(data.width)
        s.currentIndex = 1
        s.openSearch("wallet")
        compare(s.searchText, "wallet")
        verify(s.searchItem.expanded)
    }

    function test_enter_submits_the_query() {
        const s = create(1000)
        const spy = createTemporaryObject(submittedSpy, root, { target: s })
        s.currentIndex = 1
        s.openSearch()
        s.searchItem.text = "chat"
        keyClick(Qt.Key_Return)
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], "chat")
    }

    // openSearch() focuses the search with its query selected, opening it on
    // a phone; without a search it does nothing.
    function test_openSearch_data() {
        return [
            { tag: "phone",   width: 390 },
            { tag: "desktop", width: 1000 },
        ]
    }

    function test_openSearch(data) {
        const s = create(data.width)
        s.currentIndex = 0
        s.openSearch()
        verify(!s.searchItem.searchBarItem.textInput.activeFocus, "the Dashboard has no search")

        s.currentIndex = 1
        s.openSearch()
        verify(s.searchItem.expanded)
        tryVerify(() => s.searchItem.searchBarItem.textInput.activeFocus)
        s.searchItem.text = "chat"
        s.pages.children[1].forceActiveFocus()
        s.openSearch()
        tryVerify(() => s.searchItem.searchBarItem.textInput.activeFocus)
        compare(s.searchItem.searchBarItem.textInput.selectedText, "chat")
    }

    // On a phone the list is the page; a tap opens the section under "‹ Settings".
    function test_phone_list_is_the_page() {
        const s = create(390)
        verify(!s.twoPane)
        verify(!s.showingSection)
        verify(s.phoneListItem.visible)
        verify(!s.listItem.visible)
        verify(!s.sectionItem.visible)
        verify(s.titleItem.visible)
        verify(!s.backRowItem.visible)
    }

    function test_phone_tap_opens_the_section_and_back_returns() {
        const s = create(390)
        mouseClick(findChild(s.phoneListItem, "sectionRow1"))
        compare(s.currentIndex, 1)
        verify(s.showingSection)
        verify(s.sectionItem.visible)
        verify(!s.phoneListItem.visible)
        verify(!s.titleItem.visible, "the back row names the page instead")
        verify(s.backRowItem.visible)
        verify(s.backRowItem.height >= Theme.size.touchTarget)
        verify(s.searchItem.visible, "the section's search")
        verify(within(s.searchItem, s))

        mouseClick(s.backRowItem)
        verify(!s.showingSection)
        verify(s.phoneListItem.visible)
    }

    // On a phone the search never takes a row of its own: a 🔍 at the end of
    // the back row, the section right under the row.
    function test_phone_search_folds_into_the_back_row() {
        const s = create(390)
        s.currentIndex = 1
        waitForRendering(s)
        const search = s.searchItem, back = s.backRowItem
        verify(search.visible)
        verify(search.folds && !search.expanded, "an icon")
        compare(search.width, Theme.size.touchTarget)
        fuzzyCompare(search.mapToItem(s, 0, search.height / 2).y, back.mapToItem(s, 0, back.height / 2).y, 1,
                     "on the back row")
        verify(search.mapToItem(s, 0, 0).x >= back.mapToItem(s, 0, 0).x + back.width, "at its end")
        verify(within(search, s))
        const rowBottom = back.mapToItem(s, 0, 0).y + back.height
        verify(s.sectionItem.mapToItem(s, 0, 0).y <= rowBottom + Theme.spacing.medium + 0.5,
               "no row of its own between the back row and the section")
    }

    // A tap opens it across the row, in place of the row's title; ✕ clears
    // and folds it, and the row is back.
    function test_phone_search_opens_across_the_back_row() {
        const s = create(390)
        s.currentIndex = 1
        waitForRendering(s)
        const search = s.searchItem
        mouseClick(search.openButtonItem)
        verify(search.expanded)
        verify(!s.backRowItem.visible)
        tryVerify(() => search.searchBarItem.textInput.activeFocus)
        waitForRendering(s)
        verify(within(search, s))
        verify(search.width > s.width / 2, "across the row")
        keyClick("c")
        compare(s.searchText, "c")

        waitForRendering(s)
        mouseClick(search.closeButtonItem)
        verify(!search.expanded)
        compare(s.searchText, "")
        verify(s.backRowItem.visible)
        verify(s.showingSection)
    }

    // Esc and the phone's Back key fold an open search before they go back,
    // from the field or from the page under it.
    function test_phone_escape_and_back_fold_the_search_first_data() {
        return [
            { tag: "escape in the field", key: Qt.Key_Escape, inField: true },
            { tag: "escape",              key: Qt.Key_Escape, inField: false },
            { tag: "back",                key: Qt.Key_Back,   inField: false },
        ]
    }

    function test_phone_escape_and_back_fold_the_search_first(data) {
        const s = create(390)
        s.currentIndex = 1
        s.openSearch()
        s.searchItem.text = "chat"
        if (!data.inField)
            s.pages.children[1].forceActiveFocus()
        keyClick(data.key)
        verify(!s.searchItem.expanded)
        compare(s.searchText, "")
        verify(s.showingSection, "still in the section")
        verify(s.backRowItem.visible)

        keyClick(data.key)
        verify(!s.showingSection, "then back to the list")
    }

    // A query survives a change of width: on a phone the search stays open
    // with it, in place of the back row's title.
    function test_query_survives_a_change_of_width() {
        const s = create(1000)
        s.currentIndex = 1
        s.searchItem.text = "chat"
        s.width = 390
        waitForRendering(s)
        verify(s.showingSection)
        verify(s.searchItem.expanded)
        verify(!s.backRowItem.visible)
        compare(s.searchText, "chat")
        s.width = 1000
        waitForRendering(s)
        compare(s.searchText, "chat")
        verify(!s.searchItem.folds)
    }

    function test_setting_currentIndex_opens_the_section_on_a_phone() {
        const s = create(390)
        s.currentIndex = 2
        verify(s.showingSection)
        compare(s.pages.currentIndex, 2)
    }

    function test_escape_and_back_return_to_the_list_data() {
        return [
            { tag: "escape", key: Qt.Key_Escape },
            { tag: "back",   key: Qt.Key_Back },
        ]
    }

    function test_escape_and_back_return_to_the_list(data) {
        const s = create(390)
        s.currentIndex = 1
        s.pages.children[1].forceActiveFocus()
        keyClick(data.key)
        verify(!s.showingSection)
        verify(s.phoneListItem.visible)
    }

    function test_untitled_shows_no_header() {
        const s = create(1000, { title: "", subtitle: "" })
        verify(!s.titleItem.visible)
        verify(!s.subtitleItem.visible)
    }

    // A label over the list only when there is one; the list starts at the
    // top without it.
    function test_list_title_is_optional() {
        failOnWarning(/Binding loop/)
        const s = create(1000, { listTitle: "" })
        compare(s.listItem.headerItem, null)
        compare(pill(s, 0).y, 0)

        s.listTitle = "Sections"
        s.sections = [{ title: "Dashboard" }, { title: "Apps" }]
        waitForRendering(s)
        compare(s.listItem.headerItem.text, "Sections")
        verify(pill(s, 0).mapToItem(s.listItem, 0, 0).y >= s.listItem.headerItem.height)

        s.listTitle = ""
        waitForRendering(s)
        compare(s.listItem.headerItem, null)
    }

    // A section a level deeper: on a phone the same row names where back goes
    // and asks the section to go up one, rather than leave it.
    function test_phone_a_level_deeper_goes_back_one_level() {
        const s = create(390)
        const spy = createTemporaryObject(spyComp, root, { target: s })
        s.currentIndex = 1
        s.backTitle = "Apps"
        s.canGoBack = true
        verify(s.backRowItem.visible)
        compare(s.backRowItem.label, "Apps")
        compare(s.backRowItem.Accessible.name, "Back to Apps")
        verify(!s.sectionBackRowItem.visible, "one way back")

        mouseClick(s.backRowItem)
        compare(spy.count, 1)
        verify(s.showingSection, "still in the section")

        s.canGoBack = false
        compare(s.backRowItem.label, "Settings")
        mouseClick(s.backRowItem)
        verify(!s.showingSection)
        compare(spy.count, 1)
    }

    // Two quick taps on the row are two steps back, not one double-click.
    function test_two_quick_taps_go_back_two_levels() {
        const s = create(390)
        s.currentIndex = 1
        s.canGoBack = true
        s.backTitle = "Apps"
        s.backRequested.connect(() => s.canGoBack = false)
        mouseDoubleClickSequence(s.backRowItem)
        verify(!s.canGoBack, "up from the level")
        verify(!s.showingSection, "and out of the section")
    }

    // Beside the list, a level of the section's own gets the same row, at the
    // top of the section's card.
    function test_beside_the_list_a_level_shows_its_back_in_the_card() {
        const s = create(1000)
        const spy = createTemporaryObject(spyComp, root, { target: s })
        verify(!s.sectionBackRowItem.visible)
        verify(!s.backRowItem.visible)

        s.backTitle = "Module Inspector"
        s.canGoBack = true
        waitForRendering(s)
        verify(s.sectionBackRowItem.visible)
        verify(!s.backRowItem.visible, "one way back")
        compare(s.sectionBackRowItem.label, "Module Inspector")
        verify(within(s.sectionBackRowItem, s))
        const rowTop = s.sectionBackRowItem.mapToItem(s.sectionItem, 0, 0).y
        verify(rowTop >= 0)
        verify(s.pages.mapToItem(s.sectionItem, 0, 0).y >= rowTop + s.sectionBackRowItem.height,
               "the section's page is under it")

        mouseClick(s.sectionBackRowItem)
        compare(spy.count, 1)
    }

    function test_escape_goes_back_one_level_data() {
        return [
            { tag: "phone",   width: 390 },
            { tag: "desktop", width: 1000 },
        ]
    }

    function test_escape_goes_back_one_level(data) {
        const s = create(data.width)
        const spy = createTemporaryObject(spyComp, root, { target: s })
        s.currentIndex = 1
        s.canGoBack = true
        s.backTitle = "Apps"
        s.pages.children[1].forceActiveFocus()
        keyClick(Qt.Key_Escape)
        compare(spy.count, 1)
        compare(s.showingSection, data.width < 600, "a phone stays in the section")

        // Beside the list there is nothing to go back to at the top level.
        s.canGoBack = false
        s.pages.children[1].forceActiveFocus()
        keyClick(Qt.Key_Escape)
        compare(spy.count, 1)
    }
}
