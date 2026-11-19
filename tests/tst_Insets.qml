import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls

// The safe area and the on-screen keyboard, as what they cover of an item.
TestCase {
    id: root
    name: "Insets"
    width: 400
    height: 600
    visible: true
    when: windowShown

    Item { id: topItem; width: 400; height: 100 }
    Item { id: middleItem; y: 250; width: 400; height: 100 }
    Item { id: lowItem; y: 350; width: 400; height: 100 }
    Item { id: bottomItem; y: 500; width: 400; height: 100 }
    // Running past the window's edges, as in a scrolled page.
    Item { id: pastBottom; y: 400; width: 400; height: 900 }
    Item { id: pastTop; y: -300; width: 400; height: 500 }

    Flickable {
        id: flick
        y: 0
        width: 400
        height: 600
        contentHeight: 1400
        Column {
            Item { width: 1; height: 1000 }
            LogosTextField { id: farField; width: 300 }
            Item { width: 1; height: 300 }
        }
    }
    Item { id: elsewhere }

    function cleanup() {
        Theme.keyboardHeight = 0
        Theme.safeAreaTop = 0
        Theme.safeAreaBottom = 0
        flick.contentY = 0
    }

    function test_nothing_covers_a_desktop() {
        compare(Theme.bottomInset(bottomItem), 0)
        compare(Theme.topInset(topItem), 0)
    }

    // The keyboard covers what is in the window's bottom stretch.
    function test_the_keyboard_covers_the_bottom() {
        Theme.keyboardHeight = 250
        compare(Theme.bottomInset(bottomItem), 250)
        compare(Theme.keyboardInset(bottomItem), 250)
        compare(Theme.bottomInset(lowItem), 100)
        compare(Theme.bottomInset(middleItem), 0)
    }

    // The keyboard covers the safe area: the larger of the two counts.
    function test_the_safe_area_under_the_keyboard() {
        Theme.safeAreaBottom = 34
        compare(Theme.bottomInset(bottomItem), 34)
        compare(Theme.keyboardInset(bottomItem), 0)
        Theme.keyboardHeight = 250
        compare(Theme.bottomInset(bottomItem), 250)
    }

    function test_the_safe_area_at_the_top() {
        Theme.safeAreaTop = 40
        compare(Theme.topInset(topItem), 40)
        compare(Theme.topInset(middleItem), 0)
    }

    function test_a_field_scrolls_clear_of_the_keyboard() {
        Theme.keyboardHeight = 300
        Theme.scrollIntoView(farField, flick)
        const bottom = farField.mapToItem(null, 0, farField.height).y
        verify(bottom <= root.height - 300, "above the keyboard: " + bottom)
        verify(farField.mapToItem(null, 0, 0).y >= 0)
    }

    function test_only_a_field_inside_the_given_item() {
        Theme.keyboardHeight = 300
        Theme.scrollIntoView(farField, elsewhere)
        compare(flick.contentY, 0)
    }

    // An item past the window's edge is covered only up to the edge, and with
    // nothing covering the window, not at all. Counting past the edge squeezed
    // a wizard in a scrolled storybook page to nothing.
    function test_an_item_past_the_edge() {
        compare(Theme.bottomInset(pastBottom), 0)
        compare(Theme.topInset(pastTop), 0)
        Theme.safeAreaBottom = 30
        Theme.safeAreaTop = 40
        compare(Theme.bottomInset(pastBottom), 30)
        compare(Theme.topInset(pastTop), 40)
        Theme.keyboardHeight = 250
        compare(Theme.bottomInset(pastBottom), 250)
    }
}
