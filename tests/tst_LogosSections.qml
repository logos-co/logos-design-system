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
        id: wallet
        LogosSections {
            id: sections
            height: 400
            title: "Wallet"
            sections: [{ title: "Assets" }, { title: "Activity" }, { title: "Send" }]
            readonly property alias pages: stack
            StackLayout {
                id: stack
                anchors.fill: parent
                currentIndex: sections.currentIndex
                Item { objectName: "assets" }
                Item { objectName: "activity" }
                Item { objectName: "send" }
            }
        }
    }

    function create(width, properties) {
        const props = Object.assign({ width: width }, properties || {})
        const s = createTemporaryObject(wallet, root, props)
        waitForRendering(s)
        return s
    }

    function row(s, index) {
        return s.listItem.itemAtIndex(index)
    }

    function test_phone_opens_on_the_current_section() {
        const s = create(390)
        verify(!s.twoPane)
        verify(s.showingSection)
        verify(!s.listDetailItem.listPaneItem.visible)
        verify(s.listDetailItem.detailPaneItem.visible)
    }

    // ‹ shows the list; a tap opens that section, the current one included.
    function test_phone_list_opens_the_tapped_section() {
        const s = create(390)
        s.showList()
        verify(!s.showingSection)
        verify(s.listDetailItem.listPaneItem.visible)
        verify(row(s, 0).chevronItem.visible)
        verify(!row(s, 0).selected)
        mouseClick(row(s, 2))
        compare(s.currentIndex, 2)
        verify(s.showingSection)
        s.showList()
        mouseClick(row(s, 2))
        verify(s.showingSection)
    }

    function test_setting_currentIndex_shows_the_section_on_a_phone() {
        const s = create(390)
        s.showList()
        s.currentIndex = 1
        verify(s.showingSection)
        compare(s.pages.currentIndex, 1)
    }

    function test_two_panes_from_tablet_width_data() {
        return [
            { tag: "tablet",  width: 700 },
            { tag: "desktop", width: 1000 },
        ]
    }

    function test_two_panes_from_tablet_width(data) {
        const s = create(data.width)
        verify(s.twoPane)
        verify(!s.showingSection)
        compare(s.listDetailItem.listPaneItem.width, Theme.layouts.sections.listWidth)
        verify(row(s, 0).selected)
        verify(!row(s, 1).selected)
        verify(!row(s, 0).chevronItem.visible)
        mouseClick(row(s, 1))
        compare(s.currentIndex, 1)
        verify(row(s, 1).selected)
        verify(!s.showingSection)
    }

    function test_escape_and_back_return_to_the_list_data() {
        return [
            { tag: "escape", key: Qt.Key_Escape },
            { tag: "back",   key: Qt.Key_Back },
        ]
    }

    function test_escape_and_back_return_to_the_list(data) {
        const s = create(390)
        s.pages.children[0].forceActiveFocus()
        keyClick(data.key)
        verify(!s.showingSection)
        verify(s.listDetailItem.listPaneItem.visible)
    }

    // The title bar beside a section is as tall as the section's own bar.
    function test_title_bar_data() {
        return [
            { tag: "phone",   width: 390,  height: Theme.layouts.pageBar.phoneHeight },
            { tag: "tablet",  width: 700,  height: Theme.layouts.pageBar.phoneHeight },
            { tag: "desktop", width: 1000, height: Theme.layouts.pageBar.height },
        ]
    }

    function test_title_bar(data) {
        const s = create(data.width)
        s.showList()
        verify(s.titleBarItem.visible)
        compare(s.titleBarItem.titleItem.text, "Wallet")
        compare(s.titleBarItem.height, data.height)
        const untitled = create(data.width, { title: "" })
        untitled.showList()
        verify(!untitled.titleBarItem.visible)
    }

    function test_pages_go_into_the_section_pane() {
        const s = create(1000)
        compare(s.pages.parent.parent, s.listDetailItem.detailPaneItem)
        compare(s.pages.width, s.listDetailItem.detailPaneItem.width)
    }
}
