import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import Logos.Layouts

TestCase {
    id: root
    name: "LogosPageBar"
    width: 900
    height: 200
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
    when: windowShown

    Component { id: pageBar; LogosPageBar { title: "Packages"; searchEnabled: true } }
    Component { id: withMenu; LogosPageBar { title: "Packages"; menu: LogosMenu { LogosMenuItem { text: "Reload" } } } }
    Component { id: withPicker; LogosPageBar { title: "Packages"; leading: LogosComboBox { model: ["All", "Installed"] } } }
    Component { id: backSpy; SignalSpy { signalName: "backRequested" } }

    function createRendered(component, width) {
        const item = createTemporaryObject(component, root, { width: width })
        waitForRendering(item)
        return item
    }

    function cleanup() {
        mouseMove(root, root.width - 1, root.height - 1)
    }

    function test_phone_width_bar_data() {
        return [
            { tag: "phone",   width: 390, phone: true,  height: Theme.layouts.pageBar.phoneHeight, title: Theme.typography.subtitleText },
            { tag: "tablet",  width: 700, phone: false, height: Theme.layouts.pageBar.height,      title: Theme.typography.panelTitleText },
            { tag: "desktop", width: 900, phone: false, height: Theme.layouts.pageBar.height,      title: Theme.typography.panelTitleText },
        ]
    }

    // The bar measures its own width.
    function test_phone_width_bar(data) {
        const b = createRendered(pageBar, data.width)
        compare(b.phone, data.phone)
        compare(b.implicitHeight, data.height)
        compare(b.titleItem.font.pixelSize, data.title)
        compare(b.searchItem.folds, data.phone)
    }

    // At phone width the open search takes the bar.
    function test_phone_search_takes_the_bar() {
        const b = createRendered(pageBar, 390)
        verify(b.titleItem.visible)
        mouseClick(b.searchItem.openButtonItem)
        verify(b.searchItem.expanded)
        verify(!b.titleItem.visible)
        mouseClick(b.searchItem.closeButtonItem)
        verify(b.titleItem.visible)
    }

    function test_wide_search_is_a_field_beside_the_title() {
        const b = createRendered(pageBar, 900)
        verify(b.searchItem.expanded)
        verify(b.titleItem.visible)
    }

    // One field at every width, so a query survives a change of width.
    function test_query_survives_a_width_change() {
        const b = createRendered(pageBar, 900)
        b.searchItem.text = "wallet"
        compare(b.searchText, "wallet")
        b.width = 390
        compare(b.searchText, "wallet")
        verify(b.searchItem.expanded)
    }

    function test_back() {
        const b = createRendered(pageBar, 390)
        verify(!b.backButtonItem.visible)
        b.canGoBack = true
        verify(b.backButtonItem.visible)
        const spy = createTemporaryObject(backSpy, root, { target: b })
        mouseClick(b.backButtonItem)
        compare(spy.count, 1)
    }

    function test_back_from_the_keyboard_data() {
        return [
            { tag: "space",  key: Qt.Key_Space },
            { tag: "return", key: Qt.Key_Return },
            { tag: "enter",  key: Qt.Key_Enter },
        ]
    }

    // ‹ answers the keys every Logos button does.
    function test_back_from_the_keyboard(data) {
        const b = createRendered(pageBar, 390)
        b.canGoBack = true
        const spy = createTemporaryObject(backSpy, root, { target: b })
        b.backButtonItem.forceActiveFocus()
        keyClick(data.key)
        compare(spy.count, 1)
    }

    function test_overflow_menu() {
        const b = createRendered(pageBar, 900)
        verify(!b.moreButtonItem.visible)
        const m = createRendered(withMenu, 900)
        verify(m.moreButtonItem.visible)
        mouseClick(m.moreButtonItem)
        tryCompare(m.menu, "opened", true)
        m.menu.close()
    }

    // At phone width, text that starts the bar lines up with the page's margin.
    function test_phone_text_lines_up_with_the_page_margin() {
        const b = createRendered(pageBar, 390)
        compare(b.titleItem.mapToItem(b, 0, 0).x, Theme.pageMargin(390))
        const p = createRendered(withPicker, 390)
        compare(p.leading.mapToItem(p, 0, 0).x, Theme.pageMargin(390))
    }

    function test_back_sits_on_the_page_margin_data() {
        return [
            { tag: "phone",   width: 390 },
            { tag: "tablet",  width: 700 },
            { tag: "desktop", width: 900 },
        ]
    }

    // ‹ lines up with the page's text and the title follows it closely, at
    // every width; its tap area runs from the bar's edge, a touch target wide.
    function test_back_sits_on_the_page_margin(data) {
        const b = createRendered(pageBar, data.width)
        b.canGoBack = true
        waitForRendering(b)
        const margin = Theme.pageMargin(data.width)
        compare(b.titleItem.mapToItem(b, 0, 0).x, margin + Theme.size.iconXSmall + Theme.spacing.tiny)
        compare(b.backIconItem.mapToItem(b, 0, 0).x, margin)
        compare(b.backButtonItem.mapToItem(b, 0, 0).x, 0)
        verify(b.backButtonItem.width >= Theme.size.touchTarget)
        verify(b.backButtonItem.height >= Theme.size.touchTarget)
    }

    // Opened on a phone, the bar becomes the search: a field with no box of its
    // own, its icon on the page margin, the bar's line marking it.
    function test_phone_search_becomes_the_bar() {
        const b = createRendered(pageBar, 390)
        compare(b.dividerItem.color, Theme.palette.borderSubtle)
        mouseClick(b.searchItem.openButtonItem)
        waitForRendering(b)
        const field = b.searchItem.searchBarItem
        verify(!field.background.visible)
        compare(field.iconItem.mapToItem(b, 0, 0).x, Theme.pageMargin(390))
        compare(b.dividerItem.color, Theme.palette.primary)
        mouseClick(b.searchItem.closeButtonItem)
        compare(b.dividerItem.color, Theme.palette.borderSubtle)
    }

    function test_leading_replaces_the_title() {
        const b = createRendered(withPicker, 900)
        verify(!b.titleItem.visible)
        verify(b.leading.visible)
    }
}
