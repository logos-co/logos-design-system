import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import Logos.Layouts

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
}
