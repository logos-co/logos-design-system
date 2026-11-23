import QtQuick
import QtQuick.Layouts
import QtTest

import Logos.Theme
import Logos.Icons
import Logos.Controls
import Logos.Layouts

// One line of an item that may become two, by what fits, not by width class.
// With the default spacing (12) and minimumContentWidth (120), the publisher
// below needs 32 + 12 + 120 + 12 + (140 + 12 + 20) + 12 + 32 = 392 on one line.
TestCase {
    id: root
    name: "LogosItemLayout"
    width: 700
    height: 400
    // Effective visibility is read below; TestCase is invisible by default.
    visible: true
    when: windowShown

    Component {
        id: publisher
        LogosItemLayout {
            readonly property alias titleItem: title
            leading: Rectangle { implicitWidth: 32; implicitHeight: 32 }
            LogosText { id: title; text: "A publisher"; elide: Text.ElideRight }
            meta: [
                Rectangle { implicitWidth: 140; implicitHeight: 16; Layout.fillWidth: true },
                Rectangle { implicitWidth: 20; implicitHeight: 20 }
            ]
            trailing: Rectangle { implicitWidth: 32; implicitHeight: 32 }
        }
    }

    // Badges: none fills, and five don't fit in a phone's row.
    Component {
        id: badges
        LogosItemLayout {
            LogosText { text: "A repository" }
            meta: [
                Rectangle { implicitWidth: 60; implicitHeight: 16 },
                Rectangle { implicitWidth: 60; implicitHeight: 16 },
                Rectangle { implicitWidth: 60; implicitHeight: 16 },
                Rectangle { implicitWidth: 60; implicitHeight: 16 },
                Rectangle { implicitWidth: 60; implicitHeight: 16 }
            ]
        }
    }

    // A line of text and a taller button, as a key and its copy button are
    // at touch size.
    Component {
        id: keyAndCopy
        LogosItemLayout {
            LogosText { text: "Other publisher" }
            meta: [
                Rectangle { implicitWidth: 140; implicitHeight: 16; Layout.fillWidth: true },
                Rectangle { implicitWidth: 44; implicitHeight: 44 }
            ]
            trailing: Rectangle { implicitWidth: 32; implicitHeight: 32 }
        }
    }

    // Two that fill and a narrow one, as a toolbar's pickers and its ⋯.
    Component {
        id: pickers
        LogosItemLayout {
            minimumContentWidth: 400
            LogosText { text: "Packages" }
            meta: [
                Rectangle { implicitWidth: 200; implicitHeight: 40; Layout.fillWidth: true; Layout.minimumWidth: 80; Layout.maximumWidth: 220 },
                Rectangle { implicitWidth: 200; implicitHeight: 40; Layout.fillWidth: true; Layout.minimumWidth: 80; Layout.maximumWidth: 180 },
                Rectangle { implicitWidth: 44; implicitHeight: 40; Layout.fillWidth: true; Layout.minimumWidth: 44 }
            ]
        }
    }

    // An item whose height follows the width it is given, as a row of
    // buttons that folds into a taller ⋯ does.
    Component {
        id: heightFollowsWidth
        LogosItemLayout {
            LogosText { text: "Packages" }
            meta: [
                Rectangle {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 44
                    implicitWidth: 300
                    implicitHeight: width < 200 ? 44 : 40
                },
                Rectangle { implicitWidth: 100; implicitHeight: 20 }
            ]
        }
    }

    // Rows as a page has them, to be torn down.
    Component {
        id: rows
        ColumnLayout {
            Repeater {
                model: 4
                LogosItemLayout {
                    Layout.fillWidth: true
                    leading: LogosTile { label: "Other"; tileSize: 32; interactive: false }
                    LogosText { text: "Other publisher" }
                    meta: [
                        LogosText { Layout.fillWidth: true; text: "AE21 6C2E F524 7A37"; wrapMode: Text.Wrap },
                        LogosCopyButton { value: "did:jwk:other" },
                        LogosBadge { text: "Default" }
                    ]
                    trailing: LogosIconButton { iconSource: LogosIcons.trash; flat: true }
                }
            }
        }
    }

    // Each of the content's items fills the room left, up to its own
    // Layout.maximumWidth.
    Component {
        id: cappedContent
        LogosItemLayout {
            readonly property alias free: free
            readonly property alias capped: capped
            LogosText { id: free; text: "A publisher" }
            LogosText { id: capped; text: "A key"; Layout.maximumWidth: 80 }
            trailing: Rectangle { implicitWidth: 32; implicitHeight: 32 }
        }
    }

    function init() {
        failOnWarning(/Binding loop/)
    }

    function create(component, width) {
        const item = createTemporaryObject(component, root, { width: width })
        verify(item)
        waitForRendering(item)
        return item
    }

    function xOf(item, layout) { return item.mapToItem(layout, 0, 0).x }
    function yOf(item, layout) { return item.mapToItem(layout, 0, 0).y }

    function test_the_content_fills_up_to_its_maximum_width() {
        const l = create(cappedContent, 600)
        compare(l.free.width, 600 - 32 - l.spacing, "the room left")
        compare(l.capped.width, 80, "its own maximum")
    }

    function test_one_line_while_it_fits() {
        const l = create(publisher, 600)
        verify(!l.wrapped)
        fuzzyCompare(l.implicitWidth, 392 - 120 + l.titleItem.implicitWidth, 1)
        const lead = l.leading[0], fill = l.meta[0], copy = l.meta[1], end = l.trailing[0]
        compare(xOf(lead, l), 0)
        verify(xOf(l.titleItem, l) >= lead.width + l.spacing)
        verify(xOf(fill, l) >= xOf(l.titleItem, l) + 120, "beside the content, which keeps its room")
        compare(fill.width, 140, "beside the content, one that fills gets no more than its own")
        compare(xOf(copy, l), xOf(fill, l) + 140 + l.spacing)
        compare(xOf(end, l) + end.width, 600, "trailing at the end")
        compare(yOf(fill, l), (l.height - fill.height) / 2)
        // A layout in a layout fills by default, which put the content at the top.
        fuzzyCompare(yOf(l.titleItem, l), (l.height - l.titleItem.height) / 2, 1)
    }

    function test_meta_goes_under_the_content_when_it_does_not_fit() {
        const l = create(publisher, 250)
        verify(l.wrapped)
        const lead = l.leading[0], fill = l.meta[0], copy = l.meta[1], end = l.trailing[0]
        verify(yOf(fill, l) >= yOf(l.titleItem, l) + l.titleItem.height, "under the content")
        compare(xOf(fill, l), xOf(l.titleItem, l), "where the content starts")
        compare(yOf(lead, l), 0, "leading at the top")
        compare(yOf(end, l), 0, "trailing at the top, on the first line")
        compare(xOf(end, l) + end.width, 250)
        verify(yOf(copy, l) >= yOf(end, l) + end.height, "under trailing, clear of it")
    }

    // Under the content the line runs to the end, under trailing too: the
    // last item ends where trailing does, a key's copy button under its
    // delete button. It had stopped where trailing starts, the copy button
    // short of the delete button's edge.
    function test_under_the_content_the_last_item_ends_with_trailing() {
        const l = create(publisher, 250)
        verify(l.wrapped)
        const copy = l.meta[1], end = l.trailing[0]
        compare(xOf(copy, l) + copy.width, xOf(end, l) + end.width)
    }

    // Under the content, one that fills takes the room left on the line.
    function test_a_meta_that_fills_takes_the_room_left() {
        const l = create(publisher, 250)
        const line = 250 - 32 - l.spacing
        compare(l.meta[0].width, line - l.spacing - 20)
    }

    // When even a row of them doesn't fit under the content, they wrap.
    function test_meta_wraps_when_a_row_does_not_fit() {
        const l = create(badges, 250)
        verify(l.wrapped)
        const first = l.meta[0], last = l.meta[4]
        verify(yOf(last, l) > yOf(first, l), "on a line of their own")
        for (let i = 0; i < 5; ++i) {
            const badge = l.meta[i]
            verify(xOf(badge, l) >= 0 && xOf(badge, l) + badge.width <= 250, "badge " + i + " inside")
        }
    }

    // Under the content, one that fills stops at its Layout.maximumWidth and the
    // others share what it leaves: two pickers had taken an even share of the
    // line with a ⋯ beside them, cut short with room to spare.
    function test_a_meta_that_fills_stops_at_its_maximum_width() {
        const l = create(pickers, 700)
        verify(l.wrapped)
        compare(l.meta[0].width, 220)
        compare(l.meta[1].width, 180)
        compare(l.meta[2].width, 700 - 220 - 180 - 2 * l.spacing)
        // Short of their maximums, they share evenly.
        l.width = 400
        waitForRendering(l)
        fuzzyCompare(l.meta[0].width, l.meta[1].width, 0.5)
        fuzzyCompare(l.meta[2].width, 44 + (l.meta[0].width - 80), 0.5)
    }

    // The width it gives an item changes the item's height: laying out had
    // changed what the line measures in the middle of measuring it, a binding
    // loop.
    function test_an_items_height_may_follow_its_width() {
        const l = create(heightFollowsWidth, 250)
        verify(l.wrapped)
        compare(l.meta[0].height, 44, "narrower than 200 beside the other")
        // The other going, the line is laid out again, the first wider.
        l.meta[1].visible = false
        waitForRendering(l)
        compare(l.meta[0].width, 250)
        compare(l.meta[0].height, 40)
        verify(l.implicitHeight >= l.meta[0].mapToItem(l, 0, 0).y + 40, "as tall as it now is")
    }

    function test_hidden_items_take_no_room() {
        const l = create(publisher, 600)
        l.trailing[0].visible = false
        waitForRendering(l)
        compare(xOf(l.meta[1], l) + l.meta[1].width, 600, "no gap where trailing was")
        l.leading[0].visible = false
        waitForRendering(l)
        compare(xOf(l.titleItem, l), 0, "no gap where leading was")
        l.meta[0].visible = false
        l.meta[1].visible = false
        waitForRendering(l)
        verify(!l.wrapped)
        compare(l.titleItem.width, 600, "the content takes it all")
    }

    // A phone's width (under 600) on which it all fits keeps one line.
    function test_measured_not_by_width_class() {
        const l = create(publisher, 560)
        compare(Theme.windowClass(l.width), "phone")
        verify(!l.wrapped)
    }

    // Back on one line, an item the row under the content stretched takes its
    // own width again.
    function test_back_on_one_line_items_take_their_own_widths() {
        const l = create(publisher, 250)
        verify(l.meta[0].width !== 140, "stretched under the content")
        l.width = 600
        waitForRendering(l)
        verify(!l.wrapped)
        compare(l.meta[0].width, 140)
    }

    // A width a layout would give an item, its Layout.preferredWidth, is the
    // one it is measured at, and the one it gets.
    function test_an_items_preferred_width_counts() {
        const l = create(publisher, 600)
        verify(!l.wrapped)
        l.meta[1].Layout.preferredWidth = 300
        verify(l.wrapped, "392 - 20 + 300 no longer fits 600")
        l.width = 900
        waitForRendering(l)
        verify(!l.wrapped)
        compare(l.meta[1].width, 300)
    }

    function test_minimumContentWidth_moves_meta_under_sooner() {
        const l = create(publisher, 600)
        verify(!l.wrapped)
        l.minimumContentWidth = 400
        verify(l.wrapped)
    }

    // The layout is as tall as its two lines, and as its one line again.
    function test_height_follows_the_lines() {
        const l = create(publisher, 600)
        compare(l.implicitHeight, 32)
        l.width = 250
        waitForRendering(l)
        verify(l.implicitHeight >= l.titleItem.height + Theme.layouts.itemLayout.lineSpacing + 20)
    }

    // Made in a page not yet shown, as a list's rows that arrive while
    // another page shows: reading its line's children placed its items in
    // the hidden page mid-layout, which changed what it measured, a binding
    // loop that could leave the line laid out for the other place.
    Component { id: hiddenPage; Item { visible: false } }

    function test_made_in_a_hidden_page() {
        const page = createTemporaryObject(hiddenPage, root)
        const l = publisher.createObject(page)
        page.visible = true
        l.width = 250
        waitForRendering(l)
        verify(l.wrapped)
        compare(xOf(l.meta[1], l) + l.meta[1].width, 250, "laid out under the content")
        l.width = 600
        waitForRendering(l)
        verify(!l.wrapped)
        compare(l.meta[0].width, 140, "and beside it again")
        l.destroy()
    }

    // Torn down, its items call nothing in it: with connections they did, as
    // they went, and the storybook crashed leaving its page.
    function test_torn_down_its_items_call_nothing_in_it() {
        failOnWarning(/invalid context/)
        for (let n = 0; n < 30; ++n) {
            const page = rows.createObject(root, { width: n % 2 ? 250 : 600 })
            waitForRendering(page)
            page.destroy()
            if (n % 5 === 0)
                gc()
            wait(0)
        }
    }

    // On the line under the content, items are centred on each other, as
    // beside it: a short text and a tall button no longer meet at the top,
    // which put the button's icon a line below the text.
    function test_a_line_under_the_content_centres_its_items() {
        const l = create(keyAndCopy, 250)
        verify(l.wrapped)
        const key = l.meta[0], copy = l.meta[1]
        fuzzyCompare(yOf(key, l) + key.height / 2, yOf(copy, l) + copy.height / 2, 0.5)
    }

    // An item's own vertical Layout.alignment wins.
    function test_an_items_vertical_alignment_counts() {
        const l = create(keyAndCopy, 250)
        l.meta[0].Layout.alignment = Qt.AlignTop
        wait(0)
        compare(yOf(l.meta[0], l), yOf(l.meta[1], l))
        l.meta[0].Layout.alignment = Qt.AlignBottom
        wait(0)
        compare(yOf(l.meta[0], l) + l.meta[0].height, yOf(l.meta[1], l) + l.meta[1].height)
    }
}
