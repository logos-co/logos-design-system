import QtQuick
import QtTest

import Logos.Theme
import Logos.Layouts

TestCase {
    id: root
    name: "LogosCardPair"
    width: 1100
    height: 600
    when: windowShown

    Component {
        id: pair
        LogosCardPair {
            side: Rectangle { implicitHeight: 100 }
            main: Rectangle { implicitHeight: 200 }
        }
    }

    Component { id: card; Rectangle { implicitHeight: 120 } }

    function create(width) {
        const p = createTemporaryObject(pair, root, { width: width })
        waitForRendering(p)
        return p
    }

    // Two parts to one while both keep a usable width.
    function test_side_by_side_when_both_are_usable() {
        const p = create(900)
        verify(p.sideBySide)
        const third = (900 - Theme.spacing.large) / 3
        fuzzyCompare(p.main.width, 2 * third, 0.5)
        fuzzyCompare(p.side.width, third, 0.5)
        compare(p.main.mapToItem(p, 0, 0).x, 0)
        // Side by side, they line up and are as tall as each other.
        compare(p.side.mapToItem(p, 0, 0).y, p.main.mapToItem(p, 0, 0).y)
        compare(p.side.height, p.main.height)
    }

    // Otherwise one above the other, the main card first, whatever order
    // they were set in.
    function test_stacked_main_first_when_too_narrow() {
        const p = create(600)
        verify(!p.sideBySide)
        compare(p.main.width, 600)
        compare(p.side.width, 600)
        verify(p.side.mapToItem(p, 0, 0).y > p.main.mapToItem(p, 0, 0).y)
    }

    function test_the_threshold_follows_the_minimum_widths() {
        const needed = Math.max(Theme.layouts.cardPair.minimumMainWidth * 3 / 2,
                                Theme.layouts.cardPair.minimumSideWidth * 3) + Theme.spacing.large
        verify(create(Math.ceil(needed)).sideBySide)
        verify(!create(Math.floor(needed) - 1).sideBySide)
    }

    // A card replaced or cleared leaves the pair.
    function test_a_replaced_or_cleared_card_is_taken_out() {
        const p = create(900)
        const oldMain = p.main, oldSide = p.side
        const grid = oldMain.parent
        const newMain = createTemporaryObject(card, root)
        p.main = newMain
        compare(oldMain.parent, null)
        compare(newMain.parent, grid)
        p.side = null
        compare(oldSide.parent, null)
        waitForRendering(p)
        verify(!p.sideBySide || p.side === null)
        compare(newMain.mapToItem(p, 0, 0).x, 0)
    }
}
