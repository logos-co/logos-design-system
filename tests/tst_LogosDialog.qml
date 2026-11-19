import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtTest

import Logos.Controls
import Logos.Theme

TestCase {
    id: root
    name: "LogosDialog"
    width: 400
    height: 300
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
    when: windowShown

    Item { id: phoneHost; width: 390; height: 300 }
    Item { id: wideHost; width: 700; height: 300 }

    Component {
        id: placedByItself
        LogosDialog {
            title: "Remove repository?"
            message: "You can add it again later."
            preferredWidth: 420
            leftActions: [ LogosButton { text: "Cancel" } ]
            rightActions: [ LogosButton { text: "Remove" } ]
        }
    }

    Component {
        id: withTallBody
        LogosDialog {
            title: "Edit profile"
            message: "Everything here is shared with your contacts."
            preferredWidth: 420
            body: Rectangle { implicitHeight: 600; color: "transparent" }
            leftActions: [ LogosButton { text: "Cancel" } ]
            rightActions: [ LogosButton { text: "Save" } ]
        }
    }

    Component { id: rejectedSpy; SignalSpy { signalName: "rejected" } }

    Component {
        id: placedByTheApp
        LogosDialog {
            anchors.centerIn: parent
            width: 300
            title: "Remove repository?"
        }
    }

    function openIn(host, component, properties) {
        const dialog = createTemporaryObject(component || placedByItself, host, properties || {})
        dialog.open()
        tryCompare(dialog, "opened", true)
        return dialog
    }

    function settledY(dialog) {
        return dialog.sheet ? dialog.parent.height - dialog.height : (dialog.parent.height - dialog.height) / 2
    }

    LogosDialog {
        id: dlg
        title: "Confirm"
        leftActions: [
            LogosButton { text: "Help" }
        ]
        rightActions: [
            LogosButton { text: "Cancel" },
            LogosButton { text: "OK" }
        ]
    }

    function init() {
        Theme.keyboardHeight = 0
        Theme.safeAreaTop = 0
        Theme.safeAreaBottom = 0
        dlg.close()
        dlg.title = "Confirm"
        dlg.message = ""
    }

    // ── Existing alias / structural contract ─────────────────────────────

    function test_aliases_resolve() {
        verify(dlg.backgroundItem)
        verify(dlg.headerItem)
        verify(dlg.footerItem)
    }

    function test_title_round_trips() {
        dlg.title = "Renamed"
        tryCompare(dlg.headerItem, "text", "Renamed")
    }

    function test_modal_default() {
        compare(dlg.modal, true)
    }

    function test_actions_present() {
        compare(dlg.leftActions.length, 1)
        compare(dlg.rightActions.length, 2)
    }

    function test_footer_visible_when_actions_set() {
        dlg.open()
        tryCompare(dlg.footerItem, "visible", true)
        dlg.close()
    }

    function test_modal_scrim_dims_the_background() {
        dlg.open()
        tryCompare(dlg, "opened", true)
        // The overlay owns the scrim instance, so no dialog alias can reach it;
        // it is found by name instead.
        var dim = findChild(dlg.Overlay.overlay, "modalScrim")
        verify(dim)
        compare(dim.color, Theme.palette.scrim)
        tryCompare(dim, "opacity", 1)
        dlg.close()
    }

    function test_can_open_close() {
        dlg.open()
        tryCompare(dlg, "opened", true)
        dlg.close()
        tryCompare(dlg, "opened", false)
    }

    // ── message / messageItem (new API) ───────────────────────────────────

    function test_messageItem_alias_resolves() {
        verify(dlg.messageItem !== null)
    }

    function test_message_empty_by_default() {
        compare(dlg.message, "")
    }

    function test_message_round_trips() {
        dlg.message = "Are you sure?"
        compare(dlg.message, "Are you sure?")
        dlg.message = ""
        compare(dlg.message, "")
    }

    function test_messageItem_text_tracks_message() {
        dlg.message = "Confirmation needed."
        tryCompare(dlg.messageItem, "text", "Confirmation needed.")
    }

    // ── Placement: centred, or a sheet in a phone-wide parent ─────────────

    function test_a_centred_dialog_opens_and_closes_at_once() {
        const d = createTemporaryObject(placedByItself, wideHost)
        d.open()
        verify(d.opened)
        d.close()
        verify(!d.visible)
    }

    function test_centred_at_its_preferred_width() {
        const d = openIn(wideHost)
        verify(!d.sheet)
        compare(d.width, 420)
        compare(d.x, (wideHost.width - d.width) / 2)
        compare(d.y, settledY(d))
        verify(!d.handleItem.visible)
    }

    function test_never_wider_than_the_parent_less_its_margins() {
        const d = openIn(wideHost, placedByItself, { preferredWidth: 900 })
        compare(d.width, wideHost.width - 2 * Theme.pageMargin(wideHost.width))
    }

    function test_a_sheet_in_a_phone_wide_parent() {
        const d = openIn(phoneHost)
        verify(d.sheet)
        compare(d.x, 0)
        compare(d.width, phoneHost.width)
        tryCompare(d, "y", settledY(d))
        compare(d.backgroundItem.bottomLeftRadius, 0)
        compare(d.backgroundItem.bottomRightRadius, 0)
        verify(d.dragToClose)
        verify(d.handleItem.visible)
        // Room for the handle above the title.
        compare(d.headerItem.topPadding, Theme.spacing.large + Theme.spacing.small)
    }

    // Its actions stack full width, the right-hand (main) ones last.
    function test_a_sheet_stacks_its_actions_main_last() {
        const d = openIn(phoneHost)
        const cancel = d.leftActions[0]
        const remove = d.rightActions[0]
        tryCompare(cancel, "width", d.footerItem.width - 2 * Theme.spacing.large)
        compare(remove.width, cancel.width)
        verify(remove.mapToItem(d.footerItem, 0, 0).y > cancel.mapToItem(d.footerItem, 0, 0).y)
    }

    function test_widening_turns_a_sheet_into_a_centred_dialog() {
        const host = createTemporaryObject(hostComponent, root, { width: 390, height: 300 })
        const d = openIn(host)
        verify(d.sheet)
        host.width = 700
        verify(!d.sheet)
        compare(d.width, 420)
        tryCompare(d.leftActions[0], "width", d.leftActions[0].implicitWidth)
        // Back in one row: both buttons on the same line.
        compare(d.rightActions[0].mapToItem(d.footerItem, 0, 0).y,
                d.leftActions[0].mapToItem(d.footerItem, 0, 0).y)
    }
    Component { id: hostComponent; Item {} }

    Component {
        id: windowWithSlot
        Window {
            property alias slot: slot
            visible: true
            height: 600
            Item { id: slot; width: 200; height: 100 }
        }
    }
    Component {
        id: centredOnTheOverlay
        LogosDialog {
            anchors.centerIn: Overlay.overlay
            width: 300
            title: "Remove repository?"
        }
    }

    // Most apps centre their dialogs and give them a width. On a phone the
    // sheet takes over both, across the window, even from a narrow item; off
    // one the app's placement stands.
    function test_centred_by_the_app_it_goes_by_the_window_data() {
        return [
            { tag: "on its parent, phone", dialog: placedByTheApp, windowWidth: 390, sheet: true },
            { tag: "on its parent, desktop", dialog: placedByTheApp, windowWidth: 900, sheet: false },
            { tag: "on the overlay, phone", dialog: centredOnTheOverlay, windowWidth: 390, sheet: true },
            { tag: "on the overlay, desktop", dialog: centredOnTheOverlay, windowWidth: 900, sheet: false }
        ]
    }
    function test_centred_by_the_app_it_goes_by_the_window(data) {
        const w = createTemporaryObject(windowWithSlot, root, { width: data.windowWidth })
        verify(waitForRendering(w.contentItem))
        const d = openIn(w.slot, data.dialog)
        compare(d.sheet, data.sheet)
        compare(d.width, data.sheet ? data.windowWidth : 300)
        const bottom = () => d.parent.mapToItem(null, 0, d.y + d.height).y
        if (data.sheet) {
            compare(d.parent.mapToItem(null, d.x, 0).x, 0)
            tryCompare(d, "y", w.height - d.height - d.parent.mapToItem(null, 0, 0).y)
            compare(bottom(), w.height)
        }
    }

    function test_widening_gives_the_app_its_placement_back() {
        const w = createTemporaryObject(windowWithSlot, root, { width: 390 })
        verify(waitForRendering(w.contentItem))
        const d = openIn(w.slot, placedByTheApp)
        verify(d.sheet)
        w.width = 900
        tryVerify(() => !d.sheet)
        compare(d.anchors.centerIn, w.slot)
        compare(d.width, 300)
        // Its own binding, not a copy: it follows a new parent.
        d.parent = w.contentItem
        compare(d.anchors.centerIn, w.contentItem)
    }

    function test_dragging_a_sheet_down_closes_it() {
        const d = openIn(phoneHost)
        tryCompare(d, "y", settledY(d))
        mouseDrag(d.backgroundItem, d.width / 2, Theme.spacing.small, 0, d.height / 2)
        tryCompare(d, "visible", false)
    }

    function test_a_short_drag_puts_it_back() {
        const d = openIn(phoneHost)
        tryCompare(d, "y", settledY(d))
        mouseDrag(d.backgroundItem, d.width / 2, Theme.spacing.small, 0, d.height / 8)
        tryCompare(d, "y", settledY(d))
        verify(d.opened)
    }

    // ── A tall body scrolls; title and actions stay ───────────────────────

    function test_a_tall_body_scrolls_and_the_actions_stay_data() {
        return [
            { tag: "centred", host: wideHost, maxHeight: wideHost.height - 2 * Theme.pageMargin(wideHost.width) },
            { tag: "sheet",   host: phoneHost, maxHeight: phoneHost.height - Theme.controls.dialog.sheetTopGap },
        ]
    }

    function test_a_tall_body_scrolls_and_the_actions_stay(data) {
        const d = openIn(data.host, withTallBody)
        tryCompare(d, "y", settledY(d))
        compare(d.height, data.maxHeight)
        verify(d.scrollViewItem.contentHeight > d.scrollViewItem.height)
        const footerBottom = d.footerItem.mapToItem(d.backgroundItem, 0, 0).y + d.footerItem.height
        verify(footerBottom <= d.height + 0.5, "footer ends at " + footerBottom)
        verify(d.headerItem.mapToItem(d.backgroundItem, 0, 0).y >= 0)
    }

    function test_the_body_follows_the_message_full_width() {
        const d = openIn(wideHost, withTallBody)
        verify(d.body.mapToItem(d.messageItem, 0, 0).y >= d.messageItem.height)
        compare(d.body.width, d.messageItem.width)
    }

    // ── fullPage: on a phone it fills its parent ──────────────────────────

    function test_a_full_page_fills_a_phone_wide_parent() {
        const d = openIn(phoneHost, withTallBody, { fullPage: true })
        tryCompare(d, "y", 0)
        compare(d.x, 0)
        compare(d.width, phoneHost.width)
        compare(d.height, phoneHost.height)
        verify(!d.sheet)
        verify(!d.dragToClose)
        verify(!d.handleItem.visible)
        compare(d.backgroundItem.radius, 0)
        verify(d.closeButtonItem.visible)
        tryCompare(d.leftActions[0], "width", d.footerItem.width - 2 * Theme.spacing.large)
    }

    function test_a_full_page_closes_with_its_close_button() {
        const d = openIn(phoneHost, withTallBody, { fullPage: true })
        tryCompare(d, "y", 0)
        const spy = createTemporaryObject(rejectedSpy, root, { target: d })
        mouseClick(d.closeButtonItem)
        compare(spy.count, 1)
        tryCompare(d, "visible", false)
    }

    function test_a_full_page_that_must_be_answered_has_no_close_button() {
        const d = openIn(phoneHost, withTallBody, { fullPage: true, closePolicy: Popup.NoAutoClose })
        verify(!d.closeButtonItem.visible)
    }

    function test_a_full_page_is_centred_from_tablet_width() {
        const d = openIn(wideHost, withTallBody, { fullPage: true })
        compare(d.width, 420)
        compare(d.x, (wideHost.width - d.width) / 2)
        verify(!d.closeButtonItem.visible)
    }

    // A sheet that must be answered shows no handle and doesn't drag away.
    function test_a_sheet_that_must_be_answered_stays() {
        const d = openIn(phoneHost, placedByItself, { closePolicy: Popup.CloseOnEscape })
        tryCompare(d, "y", settledY(d))
        verify(!d.dragToClose)
        verify(!d.handleItem.visible)
        compare(d.headerItem.topPadding, Theme.spacing.large)
        mouseDrag(d.backgroundItem, d.width / 2, Theme.spacing.small, 0, d.height / 2)
        verify(d.opened)
        compare(d.y, settledY(d))
    }

    Component { id: plainItem; Rectangle { implicitHeight: 40 } }

    // A swipe in a sheet's body scrolls it, both ways; only the handle and the
    // title drag the sheet.
    function test_a_swipe_in_the_body_scrolls_and_leaves_the_sheet() {
        const d = openIn(phoneHost, withTallBody)
        tryCompare(d, "y", settledY(d))
        const y0 = d.y, s = d.scrollViewItem, flick = s.contentItem
        const cx = s.width / 2
        const up = touchEvent(s)
        up.press(0, s, cx, s.height - 5).commit()
        for (let i = 1; i <= 10; ++i) { up.move(0, s, cx, s.height - 5 - i * 8).commit(); wait(16) }
        up.release(0, s, cx, s.height - 85).commit()
        tryVerify(() => flick.contentY > 0, 2000, "swiping up scrolls the body")
        tryVerify(() => !flick.moving)
        const scrolled = flick.contentY
        const down = touchEvent(s)
        down.press(0, s, cx, 5).commit()
        for (let i = 1; i <= 10; ++i) {
            down.move(0, s, cx, 5 + i * 8).commit()
            wait(16)
            compare(d.y, y0, "the sheet stays while the body scrolls")
        }
        down.release(0, s, cx, 85).commit()
        tryVerify(() => flick.contentY < scrolled, 2000, "swiping down scrolls it back")
        verify(d.visible)
    }

    // Dragged away it is rejected, as when closed by Escape or a press outside.
    function test_dragging_a_sheet_closed_rejects_it() {
        const d = openIn(phoneHost)
        tryCompare(d, "y", settledY(d))
        const rejected = createTemporaryObject(rejectedSpy, root, { target: d })
        mouseDrag(d.backgroundItem, d.width / 2, Theme.spacing.small, 0, d.height / 2)
        tryCompare(d, "visible", false)
        compare(rejected.count, 1)
    }

    function test_a_replaced_or_cleared_body_is_taken_out() {
        const d = openIn(wideHost)
        const first = createTemporaryObject(plainItem, root), second = createTemporaryObject(plainItem, root)
        d.body = first
        const column = first.parent
        verify(column)
        d.body = second
        compare(first.parent, null)
        compare(second.parent, column)
        d.body = null
        compare(second.parent, null)
    }

    Component {
        id: centredForm
        LogosDialog {
            anchors.centerIn: Overlay.overlay
            title: "Edit profile"
            readonly property alias field: lastField
            body: Column {
                spacing: 8
                Repeater { model: 12; LogosText { text: "Line " + index; height: 40 } }
                LogosTextField { id: lastField; width: 200 }
            }
            rightActions: [ LogosButton { text: "Save" } ]
        }
    }
    Component { id: bare; LogosDialog { title: "Done" } }

    // On a phone a sheet sits above the keyboard, and a full page gives way to it.
    function test_a_sheet_sits_above_the_keyboard() {
        Theme.keyboardHeight = 120
        const d = openIn(phoneHost)
        tryCompare(d, "y", phoneHost.height - 120 - d.height)
        verify(d.height <= phoneHost.height - 120 - Theme.controls.dialog.sheetTopGap)
    }

    function test_a_full_page_gives_way_to_the_keyboard() {
        const d = openIn(phoneHost, withTallBody, { fullPage: true })
        Theme.keyboardHeight = 100
        compare(d.height, phoneHost.height - 100)
    }

    // The buttons, or the body without them, stay clear of the safe area; the
    // sheet still reaches the bottom.
    function test_the_safe_area_pads_a_sheet() {
        const d = openIn(phoneHost)
        tryCompare(d, "y", settledY(d))
        const footer = d.footerItem.height
        Theme.safeAreaBottom = 30
        compare(d.footerItem.height, footer + 30)
        tryCompare(d, "y", phoneHost.height - d.height)
        const plain = openIn(phoneHost, bare)
        compare(plain.scrollViewItem.bottomPadding, 30)
    }

    function test_a_full_page_clears_the_notch() {
        Theme.safeAreaTop = 40
        const d = openIn(phoneHost, withTallBody, { fullPage: true })
        verify(d.headerItem.topPadding >= 40 + Theme.spacing.large)
        verify(d.closeButtonItem.mapToItem(d.backgroundItem, 0, 0).y >= 40)
    }

    // The field with focus scrolls into the part of the sheet the keyboard leaves.
    function test_the_field_with_focus_scrolls_into_view() {
        const w = createTemporaryObject(windowWithSlot, root, { width: 390 })
        verify(waitForRendering(w.contentItem))
        Theme.keyboardHeight = 200
        const d = openIn(w.slot, centredForm)
        verify(d.sheet)
        d.field.forceActiveFocus()
        const s = d.scrollViewItem
        tryVerify(() => {
            const top = d.field.mapToItem(s, 0, 0).y
            return top >= 0 && top + d.field.height <= s.height
        }, 2000, "the field shows in the body")
        verify(d.field.mapToItem(null, 0, d.field.height).y <= w.height - 200)
    }
}
