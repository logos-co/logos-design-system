import QtQuick
import QtTest

import Logos.Theme
import Logos.Icons
import Logos.Controls

TestCase {
    id: root
    name: "LogosStateView"
    width: 1100
    height: 600
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
    when: windowShown

    Component {
        id: errorView
        LogosStateView {
            height: 500
            kind: LogosStateView.Error
            title: "Couldn't load packages"
            message: "Check your connection and try again. If it keeps failing, the catalogue may be down."
            leftActions: [ LogosButton { text: "Details" } ]
            rightActions: [ LogosButton { text: "Try again" } ]
        }
    }

    Component {
        id: plain
        LogosStateView { height: 300; title: "No packages yet" }
    }

    function create(component, properties) {
        const v = createTemporaryObject(component, root, properties)
        waitForRendering(v)
        return v
    }

    function test_kinds_data() {
        return [
            { tag: "empty",   kind: LogosStateView.Empty,   spinner: false, icon: LogosIcons.info,    colour: Theme.palette.textSecondary },
            { tag: "loading", kind: LogosStateView.Loading, spinner: true,  icon: "",                 colour: undefined },
            { tag: "error",   kind: LogosStateView.Error,   spinner: false, icon: LogosIcons.warning, colour: Theme.palette.error },
        ]
    }

    // Loading shows a spinner; the others an icon, in the error colour for Error.
    function test_kinds(data) {
        const v = create(plain, { width: 700, kind: data.kind })
        compare(v.spinnerItem.visible, data.spinner)
        compare(v.spinnerItem.running, data.spinner)
        compare(v.iconItem.visible, !data.spinner)
        if (!data.spinner) {
            compare(v.iconItem.source, data.icon)
            compare(v.iconItem.color, data.colour)
        }
    }

    function test_desktop_keeps_a_readable_width_and_a_centred_row() {
        const v = create(errorView, { width: 1000 })
        compare(v.titleItem.width, Theme.controls.stateView.maxWidth)
        fuzzyCompare(v.titleItem.mapToItem(v, 0, 0).x, (1000 - Theme.controls.stateView.maxWidth) / 2, 1)
        verify(!v.buttonRowItem.stacked)
        const details = v.leftActions[0], retry = v.rightActions[0]
        compare(details.mapToItem(v, 0, 0).y, retry.mapToItem(v, 0, 0).y)
        const used = retry.mapToItem(v, 0, 0).x + retry.width - details.mapToItem(v, 0, 0).x
        fuzzyCompare(details.mapToItem(v, 0, 0).x, (1000 - used) / 2, 1)
    }

    // On a phone it fills the page margins and its buttons stack, main last.
    function test_phone_fills_the_margins_and_stacks_its_buttons() {
        const v = create(errorView, { width: 390 })
        compare(v.titleItem.width, 390 - 2 * Theme.pageMargin(390))
        verify(v.buttonRowItem.stacked)
        const details = v.leftActions[0], retry = v.rightActions[0]
        tryCompare(retry, "width", v.titleItem.width)
        verify(retry.mapToItem(v, 0, 0).y > details.mapToItem(v, 0, 0).y)
    }

    function test_its_content_is_centred_vertically() {
        const v = create(plain, { width: 700 })
        const top = v.iconItem.mapToItem(v, 0, 0).y
        const bottom = v.titleItem.mapToItem(v, 0, 0).y + v.titleItem.height
        fuzzyCompare(top, v.height - bottom, 1)
    }

    function test_without_buttons_there_is_no_button_row() {
        const v = create(plain, { width: 700 })
        verify(!v.buttonRowItem.visible)
        verify(!v.messageItem.visible)
    }
}
