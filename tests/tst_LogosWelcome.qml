import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import Logos.Layouts
import Logos.Icons

TestCase {
    id: root
    name: "LogosWelcome"
    width: 1000
    height: 700
    visible: true
    when: windowShown

    Component {
        id: welcome
        LogosWelcome {
            height: 700
            title: "Blockchain Node"
            subtitle: "Run a node in a few steps."
            primaryText: "Quick start"
            secondaryText: "Advanced"
        }
    }
    Component { id: spy; SignalSpy {} }
    Component { id: box; Rectangle { implicitWidth: 120; implicitHeight: 40 } }

    function cleanup() {
        Theme.safeAreaTop = 0
        Theme.safeAreaBottom = 0
    }

    function within(item, w) {
        const p = item.mapToItem(w, 0, 0)
        return { x: p.x, y: p.y, right: p.x + item.width, bottom: p.y + item.height }
    }

    function create(width, properties) {
        const w = createTemporaryObject(welcome, root, Object.assign({ width: width }, properties || {}))
        waitForRendering(w)
        return w
    }

    // Centred, at most welcome.maximumWidth wide, the buttons at most buttonWidth.
    function test_centred_and_capped() {
        const w = create(1000)
        compare(w.columnItem.width, Theme.layouts.welcome.maximumWidth)
        fuzzyCompare(w.columnItem.mapToItem(w, 0, 0).x + w.columnItem.width / 2, 500, 1)
        compare(w.primaryButtonItem.width, Theme.layouts.welcome.buttonWidth)
        compare(w.primaryButtonItem.height, Theme.layouts.welcome.buttonHeight)
        compare(w.secondaryButtonItem.width, w.primaryButtonItem.width)
    }

    // On a phone the column keeps to the page margins.
    function test_phone_keeps_to_the_margins() {
        const w = create(390)
        compare(w.columnItem.width, 390 - 2 * Theme.pageMargin(390))
        verify(w.primaryButtonItem.width <= w.columnItem.width)
    }

    function test_the_main_way_in_comes_first() {
        const w = create(1000)
        verify(w.primaryButtonItem.mapToItem(w, 0, 0).y < w.secondaryButtonItem.mapToItem(w, 0, 0).y)
        const primary = createTemporaryObject(spy, root, { target: w, signalName: "primaryClicked" })
        const secondary = createTemporaryObject(spy, root, { target: w, signalName: "secondaryClicked" })
        mouseClick(w.primaryButtonItem)
        mouseClick(w.secondaryButtonItem)
        compare(primary.count, 1)
        compare(secondary.count, 1)
    }

    function test_one_way_in() {
        const w = create(1000, { secondaryText: "" })
        verify(!w.secondaryButtonItem.visible)
    }

    function test_busy_shows_a_spinner_instead() {
        const w = create(1000, { busy: true })
        verify(w.spinnerItem.visible)
        verify(!w.primaryButtonItem.visible)
    }

    // Aligned left, as Basecamp's design: the column at the page margin, the
    // text left, the main button at its own width with its arrow.
    function test_aligned_left() {
        const w = create(1000, { alignment: Qt.AlignLeft, actionsFillWidth: false, primaryText: "Continue",
                                 primaryIcon: LogosIcons.arrowRight, secondaryText: "" })
        compare(within(w.columnItem, w).x, Theme.pageMargin(1000))
        compare(within(w.primaryButtonItem, w).x, Theme.pageMargin(1000))
        verify(w.primaryButtonItem.width < Theme.layouts.welcome.buttonWidth)
        compare(w.primaryButtonItem.trailingIcon.source, LogosIcons.arrowRight)
    }

    function test_status_sits_over_the_title() {
        const pill = createTemporaryObject(box, root)
        const w = create(1000, { status: pill })
        verify(pill.visible)
        verify(pill.parent.visible)
        verify(within(pill, w).bottom <= within(w.primaryButtonItem, w).y)
        verify(within(pill, w).y > within(w.columnItem, w).y - 1)
    }

    function corners() {
        return { topLeft: createTemporaryObject(box, root), topRight: createTemporaryObject(box, root),
                 bottomLeft: createTemporaryObject(box, root), bottomRight: createTemporaryObject(box, root) }
    }

    // The corners, inside the page margins.
    function test_corners_on_a_desktop() {
        const c = corners()
        const w = create(1000, c)
        const m = Theme.pageMargin(1000)
        for (const slot of [w.topLeftItem, w.topRightItem, w.bottomLeftItem, w.bottomRightItem])
            verify(slot.visible)
        compare(within(c.topLeft, w).x, m)
        compare(within(c.topLeft, w).y, m)
        compare(within(c.topRight, w).right, 1000 - m)
        compare(within(c.bottomLeft, w).bottom, w.height - m)
        compare(within(c.bottomRight, w).right, 1000 - m)
        compare(within(c.bottomRight, w).bottom, w.height - m)
    }

    // On a phone the bottom ones stack, the left one first, and nothing
    // overlaps the column.
    function test_corners_on_a_phone() {
        const c = corners()
        const w = create(390, c)
        const m = Theme.pageMargin(390)
        compare(within(c.bottomRight, w).x, m)
        verify(within(c.bottomRight, w).y > within(c.bottomLeft, w).bottom - 1)
        verify(within(w.columnItem, w).bottom <= within(c.bottomLeft, w).y)
        verify(within(c.topLeft, w).bottom <= within(w.columnItem, w).y)
    }

    function test_clear_of_the_safe_area() {
        const c = corners()
        Theme.safeAreaTop = 40
        Theme.safeAreaBottom = 30
        const w = create(390, c)
        const m = Theme.pageMargin(390)
        compare(within(c.topLeft, w).y, m + 40)
        compare(within(c.bottomRight, w).bottom, w.height - m - 30)
    }

    function test_a_replaced_or_cleared_corner_is_taken_out() {
        const c = corners()
        const w = create(1000, c)
        const other = createTemporaryObject(box, root)
        w.topLeft = other
        compare(c.topLeft.parent, null)
        compare(other.parent, w.topLeftItem)
        w.bottomRight = null
        compare(c.bottomRight.parent, null)
        verify(!w.bottomRightItem.visible)
    }

    Component {
        id: declared
        LogosWelcome {
            height: 700
            title: "Welcome"
            topLeft: Rectangle { implicitWidth: 80; implicitHeight: 30 }
            bottomRight: Rectangle { implicitWidth: 80; implicitHeight: 30 }
        }
    }

    // Corners declared in QML, not only passed in: they show too.
    function test_declared_corners_show() {
        const w = createTemporaryObject(declared, root, { width: 1000 })
        waitForRendering(w)
        verify(w.topLeftItem.visible)
        verify(w.bottomRightItem.visible)
        compare(within(w.topLeft, w).x, Theme.pageMargin(1000))
    }

    Component {
        id: ownBackground
        LogosWelcome {
            height: 700
            title: "Welcome"
            background: Rectangle { objectName: "gradient"; color: "#202020" }
        }
    }

    // An app can put its own behind it (a video, a gradient).
    function test_the_background_can_be_replaced() {
        const w = createTemporaryObject(ownBackground, root, { width: 1000 })
        waitForRendering(w)
        compare(w.background.objectName, "gradient")
        compare(w.background.width, 1000)
        verify(w.columnItem.visible)
    }
}
