import QtQuick
import QtTest

import Logos.Theme
import LogosTests
import "qrc:/PhoneChecks.js" as PhoneChecks

// The storybook's reference app, a wallet, at a phone's, a tablet's and a
// desktop's width: in every section and level nothing reaches past the sides,
// and where targets are touch-sized none is smaller than a fingertip. Then its
// navigation: one way back, a level at a time.
TestCase {
    id: root
    name: "ReferenceApp"
    width: 1280
    height: 844
    // Effective visibility and real clicks need a visible TestCase.
    visible: true
    when: windowShown

    readonly property url appUrl: Qt.resolvedUrl("../storybook/pages/reference/WalletApp.qml")
    property Component appComponent: null

    function initTestCase() {
        appComponent = Qt.createComponent(appUrl)
    }

    function init() {
        failOnWarning(/Binding loop|TypeError|ReferenceError/)
    }

    function cleanup() {
        Theme.viewWidth = 0
        ThemeManager.setDensity("")
    }

    // An installed test binary has no storybook beside it.
    function create(width, density) {
        if (appComponent.status !== Component.Ready) {
            if (appComponent.status === Component.Error)
                fail(appComponent.errorString())
            skip("no storybook beside the tests")
        }
        Theme.viewWidth = width
        if (density)
            ThemeManager.setDensity(density)
        const app = createTemporaryObject(appComponent, root, { width: width, height: root.height })
        verify(app)
        waitForRendering(app)
        return app
    }

    function show(app, index) {
        app.sectionsItem.currentIndex = index
        waitForRendering(app)
    }

    // Two clicks in a row on one spot would make a double-click.
    function clickAgain(item) {
        wait(Qt.styleHints.mouseDoubleClickInterval + 50)
        mouseClick(item)
    }

    function check(app, state) {
        waitForRendering(app)
        const found = PhoneChecks.find(app, Theme.size.touchTarget)
        compare(found.overflow.map(item => PhoneChecks.describe(item, app)).join("; "), "",
                state + ": past the sides")
        if (Theme.touch)
            compare(found.small.map(item => PhoneChecks.describe(item, app)).join("; "), "",
                    state + ": smaller than a fingertip")
    }

    function test_every_state_fits_data() {
        return [
            { tag: "phone",   width: 390,  density: "" },
            { tag: "tablet",  width: 700,  density: "touch" },
            { tag: "desktop", width: 1280, density: "" },
        ]
    }

    function test_every_state_fits(data) {
        const app = create(data.width, data.density)
        const sections = app.sectionsItem
        if (!sections.twoPane)
            check(app, "the list of sections")
        for (let i = 0; i < 4; ++i) {
            sections.currentIndex = i
            check(app, sections.sections[i].title)
        }

        sections.currentIndex = 1
        app.activityItem.open(4)
        check(app, "a payment's detail")
        app.activityItem.goBack()

        show(app, 2)
        mouseClick(app.sendItem.sendButtonItem)
        check(app, "the form's errors")

        show(app, 3)
        mouseClick(app.settingsItem.networkRowItem)
        verify(sections.canGoBack)
        check(app, "the networks")
    }

    // On a phone the app's back row closes a payment's detail, then goes back
    // to the list of sections; the detail draws no back of its own.
    function test_phone_back_goes_up_a_level_at_a_time() {
        const app = create(390)
        const sections = app.sectionsItem, activity = app.activityItem
        mouseClick(findChild(sections.phoneListItem, "sectionRow1"))
        verify(sections.showingSection)

        activity.open(4)
        verify(activity.panelItem.showingPanel)
        verify(sections.canGoBack)
        compare(sections.backRowItem.label, "Activity")
        verify(!activity.panelItem.closeButtonItem.visible, "one way back")

        mouseClick(sections.backRowItem)
        verify(!activity.panelItem.panelOpen)
        verify(sections.showingSection)

        clickAgain(sections.backRowItem)
        verify(!sections.showingSection)
    }

    // Beside the list a payment's detail is beside the table, which keeps its
    // place, and the search filters the table.
    function test_desktop_detail_beside_the_table_and_search() {
        const app = create(1280)
        const sections = app.sectionsItem, activity = app.activityItem
        sections.currentIndex = 1
        activity.open(4)
        verify(activity.panelItem.beside)
        verify(activity.tableItem.visible)
        verify(!sections.canGoBack)

        sections.openSearch("bob")
        tryCompare(activity.tableItem.view, "count", 1)
        sections.closeSearch()
        tryCompare(activity.tableItem.view, "count", 6)
    }

    // An overview row opens its payment in Activity.
    function test_a_recent_payment_opens_in_activity() {
        const app = create(1280)
        mouseClick(findChild(app.overviewItem, "recent0"))
        compare(app.sectionsItem.currentIndex, 1)
        verify(app.activityItem.panelItem.panelOpen)
        compare(app.activityItem.panelItem.title, "Alice")
    }

    // The stat cards sit on the section's card, and stand apart from it.
    function test_stat_cards_stand_apart_from_the_section() {
        const app = create(1280)
        const card = findChild(app.overviewItem, "stat.balance")
        verify(!Qt.colorEqual(card.backgroundItem.color, Theme.palette.surfaceRaised))
    }

    // On a desktop the form is left-aligned in the section, as settings are.
    function test_desktop_form_is_left_aligned() {
        const app = create(1280)
        show(app, 2)
        const send = app.sendItem, field = findChild(send, "send.to")
        const left = field.mapToItem(send, 0, 0).x
        verify(left < send.width - (left + field.width), "room on the right, not both sides")
    }

    // Send says what's wrong under the field, asks first, then records the
    // payment and says so.
    function test_send() {
        const app = create(1280)
        const send = app.sendItem
        const to = findChild(send, "send.to"), amount = findChild(send, "send.amount")
        show(app, 2)
        compare(to.error, "", "nothing to judge yet")
        mouseClick(send.sendButtonItem)
        verify(!send.confirmItem.opened)
        compare(to.error, "Enter who to pay.")
        compare(amount.error, "Enter an amount.")

        send.toFieldItem.text = "0x12"
        send.amountFieldItem.text = "5000"
        clickAgain(send.sendButtonItem)
        verify(!send.confirmItem.opened)
        compare(to.error, "An address is 0x and 40 hex digits.")
        compare(amount.error, "That's more than your balance.")

        send.toFieldItem.text = "0x" + "ab".repeat(20)
        send.amountFieldItem.text = "10"
        clickAgain(send.sendButtonItem)
        tryVerify(() => send.confirmItem.opened)
        send.confirmItem.rightActions[0].clicked()
        tryVerify(() => !send.confirmItem.visible)
        compare(app.activityItem.tableItem.view.count, 7)
        verify(app.toastItem.visible)
        compare(send.toFieldItem.text, "")
    }

    // Choosing a network goes back to Settings and shows it there.
    function test_network_level() {
        const app = create(1280)
        const sections = app.sectionsItem, settings = app.settingsItem
        show(app, 3)
        mouseClick(settings.networkRowItem)
        verify(sections.canGoBack)
        compare(sections.backTitle, "Settings")
        clickAgain(findChild(settings, "network.Mainnet"))
        verify(!sections.canGoBack)
        compare(settings.networkRowItem.value, "Mainnet")
    }
}
