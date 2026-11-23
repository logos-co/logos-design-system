import QtQuick
import QtQuick.Layouts
import QtTest

import Logos.Theme
import Logos.Controls

TestCase {
    id: root
    name: "LogosButtonRow"
    width: 1100
    height: 400
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
    when: windowShown

    Component {
        id: threeButtons
        LogosButtonRow {
            leftActions: [ LogosButton { text: "Cancel" } ]
            rightActions: [ LogosButton { text: "Back" }, LogosButton { text: "Save" } ]
        }
    }

    // Five buttons need 5 × 140 px plus gaps: more than a 700 px row.
    Component {
        id: fiveButtons
        LogosButtonRow {
            leftActions: [ LogosButton { text: "Help" }, LogosButton { text: "Cancel" } ]
            rightActions: [ LogosButton { text: "Back" }, LogosButton { text: "Skip" }, LogosButton { text: "Next" } ]
        }
    }

    Component {
        id: withButtonsShownLater
        LogosButtonRow {
            id: shownLater
            property bool more: false
            leftActions: [ Rectangle { implicitWidth: 80; implicitHeight: 40; color: "#0000ff"; visible: shownLater.more } ]
            rightActions: [ Rectangle { implicitWidth: 80; implicitHeight: 40; color: "#ff0000"; visible: shownLater.more } ]
        }
    }

    function create(component, properties) {
        const r = createTemporaryObject(component, root, properties)
        waitForRendering(r)
        return r
    }

    function leftOf(item, r) { return item.mapToItem(r, 0, 0).x }
    function topOf(item, r) { return item.mapToItem(r, 0, 0).y }

    function test_one_row_while_they_fit() {
        const r = create(threeButtons, { width: 700 })
        verify(!r.stacked)
        const cancel = r.leftActions[0], back = r.rightActions[0], save = r.rightActions[1]
        compare(leftOf(cancel, r), 0)
        compare(leftOf(save, r) + save.width, r.width)
        verify(leftOf(back, r) < leftOf(save, r))
        compare(cancel.width, cancel.implicitWidth)
    }

    function test_a_phone_wide_row_stacks_them_main_last() {
        const r = create(threeButtons, { width: 390 })
        verify(r.stacked)
        const cancel = r.leftActions[0], save = r.rightActions[1]
        tryCompare(cancel, "width", r.width)
        compare(save.width, r.width)
        verify(topOf(save, r) > topOf(cancel, r))
    }

    // Buttons hidden in the row and shown once they stack are drawn, not only
    // placed.
    function test_buttons_shown_once_stacked_are_drawn() {
        const r = create(withButtonsShownLater, { width: 700 })
        verify(!r.stacked)
        r.width = 390
        verify(r.stacked)
        r.more = true
        waitForRendering(r)
        const image = grabImage(root)
        for (const button of [r.leftActions[0], r.rightActions[0]]) {
            const centre = button.mapToItem(root, button.width / 2, button.height / 2)
            compare(String(image.pixel(Math.round(centre.x), Math.round(centre.y))), String(button.color))
        }
    }

    function test_they_stack_when_they_do_not_fit() {
        const r = create(fiveButtons, { width: 700 })
        verify(r.stacked)
        const wide = create(fiveButtons, { width: 800 })
        verify(!wide.stacked)
    }

    // In a card, buttons that fit stay a row however narrow the card.
    function test_in_a_card_they_stack_only_when_they_do_not_fit() {
        const r = create(threeButtons, { width: 450, stackOnPhone: false })
        verify(!r.stacked)
        r.width = 400
        verify(r.stacked)
    }

    function test_widening_gives_them_back_their_own_widths() {
        const r = create(threeButtons, { width: 390 })
        tryCompare(r.leftActions[0], "width", 390)
        r.width = 700
        verify(!r.stacked)
        tryCompare(r.leftActions[0], "width", r.leftActions[0].implicitWidth)
        // Back in one row: every button on the same line.
        compare(topOf(r.rightActions[1], r), topOf(r.leftActions[0], r))
        compare(topOf(r.rightActions[0], r), topOf(r.leftActions[0], r))
    }

    function test_alignment_data() {
        return [
            { tag: "justify", alignment: Qt.AlignJustify },
            { tag: "left",    alignment: Qt.AlignLeft },
            { tag: "centre",  alignment: Qt.AlignHCenter },
            { tag: "right",   alignment: Qt.AlignRight },
        ]
    }

    // Kept together, the buttons sit at the start, the middle or the end.
    function test_alignment(data) {
        const r = create(threeButtons, { width: 700, alignment: data.alignment })
        const first = r.leftActions[0], last = r.rightActions[1]
        const start = leftOf(first, r), end = leftOf(last, r) + last.width
        if (data.alignment === Qt.AlignJustify) {
            compare(start, 0)
            compare(end, r.width)
            return
        }
        const used = end - start
        compare(used, first.width + r.rightActions[0].width + last.width + 2 * Theme.spacing.small)
        const expectedStart = data.alignment === Qt.AlignLeft ? 0
                            : data.alignment === Qt.AlignRight ? r.width - used
                            : (r.width - used) / 2
        fuzzyCompare(start, expectedStart, 1)
    }

    Component {
        id: leftOnly
        LogosButtonRow { leftActions: [ LogosButton { text: "Help" }, LogosButton { text: "Cancel" } ] }
    }
    Component {
        id: rightOnly
        LogosButtonRow { rightActions: [ LogosButton { text: "Back" }, LogosButton { text: "Save" } ] }
    }

    // One side alone sits where the alignment says, with no gap kept for the
    // empty side.
    function test_one_side_alone_data() {
        return [
            { tag: "left, the right-hand ones",   alignment: Qt.AlignLeft,    side: rightOnly },
            { tag: "right, the left-hand ones",   alignment: Qt.AlignRight,   side: leftOnly },
            { tag: "centre, the left-hand ones",  alignment: Qt.AlignHCenter, side: leftOnly },
            { tag: "centre, the right-hand ones", alignment: Qt.AlignHCenter, side: rightOnly },
        ]
    }

    function test_one_side_alone(data) {
        const r = create(data.side, { width: 700, alignment: data.alignment })
        const buttons = r.leftActions.length > 0 ? r.leftActions : r.rightActions
        const first = buttons[0], last = buttons[1]
        const start = leftOf(first, r), used = leftOf(last, r) + last.width - start
        const expectedStart = data.alignment === Qt.AlignLeft ? 0
                            : data.alignment === Qt.AlignRight ? r.width - used
                            : (r.width - used) / 2
        fuzzyCompare(start, expectedStart, 1)
    }

    function test_its_natural_width_is_the_row() {
        const r = create(fiveButtons)
        compare(r.implicitWidth, 5 * Theme.controls.buttonRow.minButtonWidth + 4 * Theme.spacing.small)
    }
}
