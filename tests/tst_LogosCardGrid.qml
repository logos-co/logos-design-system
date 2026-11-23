import QtQuick
import QtQuick.Layouts
import QtTest

import Logos.Theme
import Logos.Controls
import Logos.Layouts

TestCase {
    id: root
    name: "LogosCardGrid"
    width: 1700
    height: 600
    // Cards are counted by visibility; TestCase is invisible by default.
    visible: true
    when: windowShown

    Component {
        id: grid
        LogosCardGrid {
            id: g
            property int count: 4
            Repeater {
                model: g.count
                delegate: Rectangle {
                    required property int index
                    implicitHeight: index === 1 ? 120 : 80
                }
            }
        }
    }

    function create(properties) {
        const g = createTemporaryObject(grid, root, properties)
        waitForRendering(g)
        return g
    }

    function cards(g) {
        const items = []
        const layout = g.children[0]
        for (let i = 0; i < layout.children.length; ++i)
            if (!(layout.children[i] instanceof Repeater))
                items.push(layout.children[i])
        return items
    }

    function test_columns_data() {
        return [
            { tag: "4 wide",              count: 4, width: 1100, columns: 4 },
            { tag: "4 where 3 fit",       count: 4, width: 600,  columns: 2 },
            { tag: "4 on a phone",        count: 4, width: 300,  columns: 1 },
            { tag: "5 where 4 fit",       count: 5, width: 760,  columns: 3 },
            { tag: "3 where 2 fit",       count: 3, width: 400,  columns: 2 },
            { tag: "fewer cards than fit", count: 2, width: 1100, columns: 2 },
        ]
    }

    // As many as fit at the minimum width, but never one card alone on the
    // last row when fewer columns (two or more) avoid it.
    function test_columns(data) {
        const g = create({ width: data.width, count: data.count })
        compare(g.columns, data.columns)
    }

    // A catalogue keeps every column that fits, whatever is left on the last row.
    function test_unbalanced_keeps_every_column_that_fits() {
        const g = create({ width: 600, count: 4, balanced: false })
        compare(g.columns, 3)
    }

    function test_maximum_columns() {
        const g = create({ width: 1100, count: 6, maximumColumns: 3 })
        compare(g.columns, 3)
    }

    function test_equal_columns_across_the_content() {
        const g = create({ width: 1000, count: 4 })
        const cs = cards(g)
        compare(cs.length, 4)
        const expected = (1000 - 3 * Theme.spacing.large) / 4
        for (let i = 0; i < cs.length; ++i)
            fuzzyCompare(cs[i].width, expected, 0.5)
        fuzzyCompare(cs[3].mapToItem(g, 0, 0).x + cs[3].width, 1000, 0.5)
    }

    // The gap is the grid's spacing, across and down, and the columns that
    // fit are counted with it.
    function test_spacing() {
        let g = create({ width: 1000, count: 4, spacing: 24 })
        const cs = cards(g)
        fuzzyCompare(cs[1].mapToItem(g, 0, 0).x - (cs[0].mapToItem(g, 0, 0).x + cs[0].width), 24, 0.5)
        fuzzyCompare(cs[0].width, (1000 - 3 * 24) / 4, 0.5)
        g = create({ width: 2 * 300 + 16, count: 2, minimumCellWidth: 300 })
        compare(g.columns, 2)
        g = create({ width: 2 * 300 + 16, count: 2, minimumCellWidth: 300, spacing: 24 })
        compare(g.columns, 1)
        g = create({ width: 300, count: 2, minimumCellWidth: 300, spacing: 24 })
        fuzzyCompare(cards(g)[1].mapToItem(g, 0, 0).y - (cards(g)[0].mapToItem(g, 0, 0).y + cards(g)[0].height), 24, 0.5)
    }

    // Wider than maximumWidth, the content keeps to it, centred.
    function test_content_is_capped_and_centred() {
        const g = create({ width: 1600, count: 8 })
        const cs = cards(g)
        const left = cs[0].mapToItem(g, 0, 0).x
        fuzzyCompare(left, (1600 - Theme.layouts.cardGrid.maximumWidth) / 2, 0.5)
    }

    // The cards in a row line up at the top and are as tall as the tallest.
    function test_a_row_is_one_height() {
        const g = create({ width: 1100, count: 4 })
        const cs = cards(g)
        for (let i = 1; i < cs.length; ++i) {
            compare(cs[i].mapToItem(g, 0, 0).y, cs[0].mapToItem(g, 0, 0).y)
            compare(cs[i].height, 120)
        }
    }

    function test_hidden_cards_do_not_count() {
        const g = create({ width: 1100, count: 4 })
        cards(g)[3].visible = false
        compare(g.columns, 3)
    }
}
