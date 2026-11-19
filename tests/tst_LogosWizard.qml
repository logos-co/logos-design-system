import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import Logos.Layouts

TestCase {
    id: root
    name: "LogosWizard"
    width: 1100
    height: 600
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
    when: windowShown

    Component {
        id: wizard
        LogosWizard {
            height: 500
            title: "Set up your node"
            subtitle: "Advanced setup: configure and secure your node."
            steps: ["Setup", "Network", "Keys"]
            Rectangle { objectName: "setup" }
            Rectangle { objectName: "network" }
            Rectangle { objectName: "keys"; implicitHeight: 2000 }
        }
    }

    Component {
        id: shortOfPages
        LogosWizard {
            steps: ["A", "B", "C"]
            Item {}
            Item {}
        }
    }

    Component {
        id: welcomeScreen
        Rectangle { objectName: "welcome" }
    }

    Component { id: spy; SignalSpy {} }

    // In the wizard and showing, not merely visible: a button out of the row
    // has no parent but still reads visible.
    function shown(w, item) {
        for (let p = item; p; p = p.parent) {
            if (!p.visible)
                return false
            if (p === w)
                return true
        }
        return false
    }

    Component {
        id: keyHost
        Item {
            property alias wizard: hosted
            property int escapes: 0
            Keys.onEscapePressed: escapes++
            LogosWizard {
                id: hosted
                width: 900
                height: 500
                steps: ["Setup", "Network", "Keys"]
                welcome: welcomeScreen
                Item {}
                Item {}
                Item {}
            }
        }
    }

    function cleanup() {
        Theme.keyboardHeight = 0
        Theme.safeAreaBottom = 0
    }

    function create(width, properties) {
        const w = createTemporaryObject(wizard, root, Object.assign({ width: width }, properties || {}))
        waitForRendering(w)
        return w
    }

    function test_next_and_back() {
        const w = create(1000)
        compare(w.currentIndex, 0)
        verify(!shown(w, w.backButtonItem))
        mouseClick(w.nextButtonItem)
        compare(w.currentIndex, 1)
        verify(shown(w, w.backButtonItem))
        verify(findChild(w, "network").visible)
        verify(!findChild(w, "setup").visible)
        mouseClick(w.backButtonItem)
        compare(w.currentIndex, 0)
    }

    // The main button names what it does; on the last step it finishes.
    function test_the_last_step_finishes_under_the_apps_name() {
        const w = create(1000, { currentIndex: 2, nextText: "Start node" })
        compare(w.nextButtonItem.text, "Start node")
        const finished = createTemporaryObject(spy, root, { target: w, signalName: "finished" })
        mouseClick(w.nextButtonItem)
        compare(finished.count, 1)
        compare(w.currentIndex, 2)
    }

    function test_continue_by_default() {
        compare(create(1000).nextButtonItem.text, "Continue")
    }

    function test_the_main_button_is_never_narrower_than_its_token() {
        const w = create(1000, { nextText: "Go" })
        compare(w.nextButtonItem.width, Theme.layouts.wizard.nextMinWidth)
    }

    // While the step is incomplete the main button holds, and the hint says why.
    function test_an_incomplete_step_says_why() {
        const w = create(1000, { canGoNext: false, nextHint: "Confirm you saved your keys to continue" })
        verify(!w.nextButtonItem.enabled)
        w.next()
        compare(w.currentIndex, 0)
        verify(w.hintItem.visible)
        compare(w.hintItem.text, "Confirm you saved your keys to continue")
        w.canGoNext = true
        verify(!w.hintItem.visible)
    }

    // From tablet width up the hint sits just left of the main button, on its line.
    function test_the_hint_is_beside_the_main_button() {
        const w = create(1000, { currentIndex: 1, canGoNext: false, nextHint: "Pick a network" })
        waitForRendering(w)
        const hint = w.hintItem.mapToItem(w, 0, 0), next = w.nextButtonItem.mapToItem(w, 0, 0)
        verify(hint.x + w.hintItem.width <= next.x)
        verify(hint.x > w.backButtonItem.mapToItem(w, 0, 0).x + w.backButtonItem.width)
        fuzzyCompare(hint.y + w.hintItem.height / 2, next.y + w.nextButtonItem.height / 2, 1)
    }

    function test_cancel() {
        const w = create(1000, { cancellable: true })
        verify(shown(w, w.cancelButtonItem))
        compare(w.cancelButtonItem.text, "Exit")
        const cancelled = createTemporaryObject(spy, root, { target: w, signalName: "cancelled" })
        mouseClick(w.cancelButtonItem)
        compare(cancelled.count, 1)
    }

    function test_a_second_way_forward() {
        const w = create(1000)
        verify(!shown(w, w.secondaryButtonItem))
        w.secondaryText = "Retry"
        waitForRendering(w)
        verify(shown(w, w.secondaryButtonItem))
        const clicked = createTemporaryObject(spy, root, { target: w, signalName: "secondaryClicked" })
        mouseClick(w.secondaryButtonItem)
        compare(clicked.count, 1)
        // Left of the main button.
        verify(w.secondaryButtonItem.mapToItem(w, 0, 0).x < w.nextButtonItem.mapToItem(w, 0, 0).x)
    }

    // A step past which there is no going back, e.g. once a wallet exists.
    function test_back_can_be_withheld() {
        const w = create(1000, { currentIndex: 2, canGoBack: false })
        verify(!shown(w, w.backButtonItem))
    }

    // The rail: one equal column per step, reached ones in the primary colour,
    // the current one named in bold.
    function test_the_rail_across_the_top() {
        const w = create(1000, { currentIndex: 1 })
        verify(w.railItem.visible)
        verify(w.headerItem.visible)
        verify(w.railItem.mapToItem(w, 0, 0).y < findChild(w, "network").mapToItem(w, 0, 0).y)
        const first = findChild(w, "railStep0"), second = findChild(w, "railStep1"), third = findChild(w, "railStep2")
        compare(first.width, third.width)
        compare(second.children[0].color, Theme.palette.primary)
        compare(third.children[0].color, Theme.palette.border)
        compare(second.children[1].text, "2. Network")
        compare(second.children[1].font.weight, Theme.typography.weightBold)
        verify(!w.railLabelItem.visible)
    }

    function test_no_rail_for_a_single_step() {
        const w = create(1000, { steps: ["Setup"] })
        verify(!w.railItem.visible)
    }

    function test_a_long_page_scrolls_and_the_buttons_stay() {
        const w = create(1000, { currentIndex: 2 })
        const next = w.nextButtonItem.mapToItem(w, 0, 0)
        verify(next.y + w.nextButtonItem.height <= w.height)
        verify(findChild(w, "keys").height >= 2000)
    }

    // A welcome screen comes first; begin() starts, and Back from the first
    // step returns to it.
    function test_a_welcome_screen_comes_first() {
        const w = create(1000, { welcome: welcomeScreen })
        verify(w.atWelcome)
        verify(w.welcomeItem.item)
        verify(!shown(w, w.nextButtonItem))
        w.begin()
        verify(!w.atWelcome)
        compare(w.currentIndex, 0)
        verify(shown(w, w.backButtonItem))
        mouseClick(w.backButtonItem)
        verify(w.atWelcome)
    }

    // On a phone: only the current step named under the rail, and the buttons
    // stacked, the main one last, with the hint above them.
    function test_phone() {
        const w = create(390, { currentIndex: 1, canGoNext: false, nextHint: "Pick a network" })
        verify(w.phone)
        verify(w.railLabelItem.visible)
        compare(w.railLabelItem.text, "2. Network")
        verify(!findChild(w, "railStep1").children[1].visible)
        waitForRendering(w)
        const back = w.backButtonItem, next = w.nextButtonItem
        verify(next.mapToItem(w, 0, 0).y > back.mapToItem(w, 0, 0).y)
        compare(next.width, back.width)
        verify(w.hintItem.visible)
        verify(w.hintItem.mapToItem(w, 0, 0).y < back.mapToItem(w, 0, 0).y)
    }

    // One page per step: it says when they don't match, not while it is built.
    function test_it_warns_when_steps_and_pages_differ() {
        ignoreWarning(/LogosWizard: 3 steps but 2 pages/)
        createTemporaryObject(shortOfPages, root, { width: 900, height: 500 })
        failOnWarning(/LogosWizard:/)
        create(1000)
    }

    // Esc and the phone's Back key go back, to the welcome screen in the end;
    // there they go on to the app.
    function test_esc_and_back_go_back() {
        const host = createTemporaryObject(keyHost, root)
        const w = host.wizard
        w.begin()
        w.currentIndex = 2
        w.forceActiveFocus()
        keyClick(Qt.Key_Escape)
        compare(w.currentIndex, 1)
        keyClick(Qt.Key_Back)
        compare(w.currentIndex, 0)
        keyClick(Qt.Key_Escape)
        verify(w.atWelcome)
        compare(host.escapes, 0)
        w.forceActiveFocus()
        keyClick(Qt.Key_Escape)
        compare(host.escapes, 1)
    }

    function test_back_withheld_lets_esc_go_on() {
        const host = createTemporaryObject(keyHost, root)
        const w = host.wizard
        w.begin()
        w.currentIndex = 1
        w.canGoBack = false
        w.forceActiveFocus()
        keyClick(Qt.Key_Escape)
        compare(w.currentIndex, 1)
        compare(host.escapes, 1)
    }

    // A screen reader hears where the user is.
    function test_the_rail_says_the_step() {
        const w = create(1000, { currentIndex: 1 })
        compare(w.railItem.Accessible.name, "Step 2 of 3: Network")
        compare(w.railItem.Accessible.role, Accessible.ProgressBar)
    }

    // The buttons stay above the keyboard.
    function test_the_buttons_stay_above_the_keyboard() {
        const w = create(390, { currentIndex: 1 })
        const coveredFrom = root.height - 300
        Theme.keyboardHeight = 300
        tryVerify(() => w.nextButtonItem.mapToItem(null, 0, w.nextButtonItem.height).y <= coveredFrom)
    }

    // A wizard that runs past the bottom of the window, as in a scrolled page,
    // keeps its layout.
    function test_past_the_bottom_of_the_window() {
        const w = createTemporaryObject(wizard, root, { width: 900, height: 500, y: root.height - 200 })
        waitForRendering(w)
        compare(w.headerItem.width, 900 - 2 * Theme.pageMargin(900))
        // No keyboard and no safe area: nothing is taken off its height.
        compare(w.headerItem.parent.height, 500 - 2 * Theme.pageMargin(900))
    }
}
