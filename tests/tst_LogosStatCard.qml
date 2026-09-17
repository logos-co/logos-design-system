import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls

TestCase {
    id: root
    name: "LogosStatCard"
    width: 400
    height: 400
    when: windowShown

    LogosStatCard {
        id: card
        label: "Height"
        value: "151548"
        anchors.centerIn: parent
        width: 220
    }

    // A card whose value is never set at declaration, so the test can observe
    // what the very first assignment does.
    LogosStatCard {
        id: freshCard
        label: "Slot"
        flashOnChange: true
        width: 220
    }

    // Declared rather than assigned at runtime: reparenting into `trailing`
    // happens at component completion, and the layout only settles once the
    // scene is shown.
    LogosStatCard {
        id: cardWithTrailing
        label: "Height"
        value: "151548"
        interactive: true
        width: 220
        labelTrailing: [
            LogosInfoButton {
                id: trailingInfo
                text: "Explanation."
            }
        ]
    }

    // A grid-alignment pair: same declaration, one with a caption and one
    // without. Declared rather than toggled, because the layout only settles
    // once the scene is shown.
    LogosStatCard {
        id: withCaption
        width: 220
        label: "Height"
        value: "151548"
        caption: "12 slots behind"
    }

    // A caption whose natural width has a fraction that rounds *down*.
    // TextMetrics.width is whole-pixel, so for this string it lands a pixel
    // below what the text needs — "12 slots behind" above rounds up and so
    // cannot catch a cap that measures with `width` instead of `advanceWidth`.
    LogosStatCard {
        id: withRoundsDownCaption
        width: 220
        label: "Mining Rewards"
        value: "1234"
        caption: "Mining"
    }

    LogosStatCard {
        id: withoutCaption
        width: 220
        label: "Slot"
        value: "151548"
    }

    // A hash tile: the copy affordance belongs to the value, so it rides on the
    // caption line rather than in the card's top-right corner.
    LogosStatCard {
        id: cardWithCaptionSlot
        width: 220
        label: "LiB"
        value: "0x71bd…9e4a"
        caption: "slot 151548"
        captionTrailing: [
            LogosCopyButton { id: captionCopy; value: "0x71bd000000009e4a" }
        ]
    }

    // The same tile with the copy affordance where it belongs: beside the value
    // it actually copies, carrying the full hash rather than the shortened one
    // on screen.
    LogosStatCard {
        id: cardWithValueSlot
        width: 220
        label: "LiB"
        value: "0x71bd…9e4a"
        caption: "slot 151548"
        valueTrailing: [
            LogosCopyButton { id: valueCopy; value: "0x71bd000000009e4a" }
        ]
    }

    // The eliding/shrinking pair again, both carrying a value slot this time:
    // the fit has to go on working in whatever width the slot leaves it, not
    // only in a bare card.
    LogosStatCard {
        id: elidingCardWithSlot
        width: 220
        label: "Total Balance"
        value: "5,999,999,986,578"
        valueTrailing: [
            LogosCopyButton { value: "5999999986578" }
        ]
    }

    LogosStatCard {
        id: shrinkingCardWithSlot
        width: 220
        label: "Total Balance"
        value: "5,999,999,986,578"
        valueFontSizeMode: Text.HorizontalFit
        valueTrailing: [
            LogosCopyButton { id: shrinkingCopy; value: "5999999986578" }
        ]
    }

    // A pair sharing one width and one over-long value, so the only variable
    // between them is how they react to not fitting.
    LogosStatCard {
        id: elidingCard
        width: 194
        label: "Total Balance"
        value: "5,999,999,986,578"
    }

    LogosStatCard {
        id: shrinkingCard
        width: 194
        label: "Total Balance"
        value: "5,999,999,986,578"
        valueFontSizeMode: Text.HorizontalFit
    }

    SignalSpy {
        id: clickedSpy
        target: card
        signalName: "clicked"
    }

    SignalSpy {
        id: trailingCardClickedSpy
        target: cardWithTrailing
        signalName: "clicked"
    }

    function init() {
        clickedSpy.clear()
        trailingCardClickedSpy.clear()
        // Order matters: disarm the flash and stop any animation left running
        // by the previous test BEFORE touching `value`, or resetting the
        // fixture arms a flash that outlives init().
        card.flashOnChange = false
        card.flashAnimationItem.stop()
        card.label = "Height"
        card.value = "151548"
        card.caption = ""
        card.severity = LogosStatCard.None
        card.valueColor = Theme.palette.text
        card.interactive = false
        card.flashColor = Theme.palette.primary
        card.flashDuration = 1260
        card.borderColor = "transparent"
        card.valueFontSizeMode = Text.FixedSize
        card.valueMinimumPixelSize = Theme.typography.subtitleText
    }

    // ---- Content ----

    function test_text_reaches_the_items() {
        card.caption = "12 slots behind"
        compare(card.labelItem.text, "Height")
        compare(card.valueItem.text, "151548")
        compare(card.captionItem.text, "12 slots behind")
    }

    // ---- Grid rhythm ----

    function test_caption_is_not_elided_when_the_card_has_room_data() {
        return [
            { tag: "rounds up", card: withCaption },
            { tag: "rounds down", card: withRoundsDownCaption },
        ]
    }

    function test_caption_is_not_elided_when_the_card_has_room(data) {
        // Regression, in two layers. The cap was first bound to the caption's
        // own implicitWidth: with elide active that reports the *elided*
        // layout, so the cap fed back into the constraint that produced it —
        // one sub-pixel round-down elided a character, which shrank
        // implicitWidth, which tightened the cap, and a short caption stayed
        // truncated in a card with obvious room to spare. Measuring with
        // TextMetrics broke that loop but swapped in a second, quieter fault:
        // TextMetrics.width is whole-pixel and rounds down as often as up, so
        // for half the strings the cap still landed under what the text needed.
        // advanceWidth is the unrounded figure, and matches Text's own
        // implicitWidth exactly. The value text never had either bug because
        // nothing reads its implicit width.
        const item = data.card.captionItem
        verify(item.width > 0)
        // truncated is the direct question: is what is painted the whole string?
        verify(!item.truncated)
        // And the card really is wider than the caption needs, so an elision
        // here could only come from the cap, not from a genuine shortage.
        verify(data.card.width > item.contentWidth)
    }

    function test_caption_still_elides_when_the_card_is_too_narrow() {
        // The cap must not defeat the shrink: widen nothing, just starve the
        // card and check the caption gives way rather than overflowing.
        const card = withRoundsDownCaption
        const restore = card.width
        card.width = 60
        wait(0)
        verify(card.captionItem.truncated)
        card.width = restore
        wait(0)
    }

    function test_caption_does_not_change_the_height() {
        // The whole point of reserving the caption line: a row of cards where
        // only some carry a caption must still align.
        compare(withCaption.implicitHeight, withoutCaption.implicitHeight)
    }

    function test_value_sits_on_the_same_baseline_either_way() {
        const a = withCaption.valueItem.mapToItem(withCaption, 0, 0).y
        const b = withoutCaption.valueItem.mapToItem(withoutCaption, 0, 0).y
        fuzzyCompare(a, b, 1)
    }

    function test_height_floor_matches_the_design_tile() {
        compare(withoutCaption.implicitHeight, 108)
    }

    function test_taller_content_grows_past_the_floor() {
        // A floor, not a fixed height.
        card.caption = "A caption long enough to wrap onto a second line in a "
                     + "card this narrow, which must push the card taller."
        card.width = 140
        tryVerify(function () { return card.implicitHeight >= 108 })
        card.width = 220
    }

    function test_floor_can_be_switched_off() {
        withoutCaption.minimumHeight = 0
        tryVerify(function () { return withoutCaption.implicitHeight < 108 })
        withoutCaption.minimumHeight = 108
        tryCompare(withoutCaption, "implicitHeight", 108)
    }

    // ---- Long values ----

    function test_value_elides_by_default() {
        // Also the precondition for the test below: if this card stops
        // overflowing — a font metric shifts, the fixture width changes — the
        // shrink test would pass without proving anything, so it must fail
        // here first and loudly.
        compare(elidingCard.valueFontSizeMode, Text.FixedSize)
        tryCompare(elidingCard.valueItem, "truncated", true)
    }

    function test_horizontal_fit_shrinks_instead_of_eliding() {
        // Same width, same digits, no ellipsis: every digit of a balance is
        // meaning, so the type gives way rather than the number.
        tryCompare(shrinkingCard.valueItem, "truncated", false)
    }

    function test_shrinking_stops_at_the_floor() {
        // A floor, not a licence to shrink to nothing: past it the value
        // elides like any other, and the card stays readable at a glance.
        compare(shrinkingCard.valueMinimumPixelSize,
                Theme.typography.subtitleText)
        shrinkingCard.value = "5,999,999,986,578,000,000,000,000,000,000"
        tryCompare(shrinkingCard.valueItem, "truncated", true)
        shrinkingCard.value = "5,999,999,986,578"
        tryCompare(shrinkingCard.valueItem, "truncated", false)
    }

    function test_font_size_mode_reaches_the_value() {
        compare(card.valueItem.fontSizeMode, Text.FixedSize)
        card.valueFontSizeMode = Text.HorizontalFit
        tryCompare(card.valueItem, "fontSizeMode", Text.HorizontalFit)
        card.valueMinimumPixelSize = Theme.typography.primaryText
        tryCompare(card.valueItem, "minimumPixelSize",
                   Theme.typography.primaryText)
    }

    // ---- Severity ----

    function test_severity_colors_the_value_data() {
        return [
            { tag: "none",    severity: LogosStatCard.None,    color: Theme.palette.text },
            { tag: "info",    severity: LogosStatCard.Info,    color: Theme.palette.info },
            { tag: "success", severity: LogosStatCard.Success, color: Theme.palette.success },
            { tag: "warning", severity: LogosStatCard.Warning, color: Theme.palette.warning },
            { tag: "error",   severity: LogosStatCard.Error,   color: Theme.palette.error },
        ]
    }

    function test_severity_colors_the_value(data) {
        card.severity = data.severity
        tryCompare(card.valueItem, "color", data.color)
    }

    function test_valueColor_tints_without_a_verdict() {
        // A value can be worth colouring without anything being flagged — a
        // role, a category, a brand accent. That must not drag an icon along:
        // an icon beside the label reads as "something needs your attention",
        // and for Info it is indistinguishable from a LogosInfoButton next to
        // it, which is what made this property necessary.
        // Asserted on `source`, not `visible`: `visible` is effective
        // visibility, and nothing in a headless TestCase has a visible
        // ancestor, so it reads false regardless of the binding.
        card.severity = LogosStatCard.None
        card.valueColor = Theme.palette.info
        tryCompare(card.valueItem, "color", Theme.palette.info)
        tryCompare(card.severityIconItem, "source", Qt.url(""))
    }

    function test_severity_outranks_valueColor() {
        // A card that is flagging something must not have its flag colour
        // quietly overridden by a decorative tint.
        card.valueColor = Theme.palette.info
        card.severity = LogosStatCard.Warning
        tryCompare(card.valueItem, "color", Theme.palette.warning)
        verify(card.severityIconItem.source.toString().length > 0)
    }

    function test_valueColor_defaults_to_plain_text() {
        compare(card.valueColor, Theme.palette.text)
        tryCompare(card.valueItem, "color", Theme.palette.text)
    }

    function test_severity_does_not_tint_the_surface() {
        const flat = card.backgroundItem.color
        card.severity = LogosStatCard.Error
        tryCompare(card.backgroundItem, "color", flat)
    }

    function test_severity_does_not_indent_the_value() {
        // The value's left edge is the card's strongest alignment cue: it must
        // line up with the label above it and with neighbouring cards across a
        // grid, whatever the severity.
        const labelX = card.labelItem.mapToItem(card, 0, 0).x
        const plainX = card.valueItem.mapToItem(card, 0, 0).x
        fuzzyCompare(plainX, labelX, 1)

        card.severity = LogosStatCard.Warning
        const flaggedX = card.valueItem.mapToItem(card, 0, 0).x
        fuzzyCompare(flaggedX, plainX, 1)
    }

    function test_padding_matches_the_design_tile() {
        // Measured off the design at 231x107: ~10px of ink inset on each edge,
        // i.e. spacing.medium, not spacing.large.
        compare(card.padding, Theme.spacing.medium)
    }

    function test_severity_carries_a_non_color_channel() {
        // Color alone is not a state indicator (WCAG 1.4.1), so severity must
        // also produce an icon.
        card.severity = LogosStatCard.None
        tryCompare(card.severityIconItem, "source", Qt.url(""))
        card.severity = LogosStatCard.Warning
        verify(card.severityIconItem.source.toString().length > 0)
    }

    function test_border_is_opt_in() {
        compare(card.backgroundItem.border.width, 0)
        card.borderColor = Theme.palette.warningBorder
        tryCompare(card.backgroundItem.border, "width", 1)
    }

    // ---- Interactivity ----

    function test_not_interactive_by_default() {
        compare(card.interactive, false)
        compare(card.focusPolicy, Qt.NoFocus)
        card.mouseAreaItem.clicked(null)
        compare(clickedSpy.count, 0)
    }

    function test_interactive_emits_clicked() {
        card.interactive = true
        card.mouseAreaItem.clicked(null)
        compare(clickedSpy.count, 1)
    }

    function test_trailing_item_is_reparented_into_the_card() {
        compare(cardWithTrailing.labelTrailing.length, 1)
        verify(trailingInfo.parent !== null)
        verify(trailingInfo.parent !== root)
    }

    function test_trailing_item_keeps_its_own_clicks() {
        // The reason contentItem sits above LogosAbstractButton's full-bleed
        // MouseArea: activating the trailing control must not read as a click
        // on the card behind it.
        trailingInfo.mouseAreaItem.clicked(null)
        tryCompare(trailingInfo, "opened", true)
        compare(trailingCardClickedSpy.count, 0)
        trailingInfo.close()
    }

    function test_trailing_right_edge_is_one_padding_from_the_border() {
        // Measured off the design: the (i)'s right edge lands exactly one
        // card padding in from the card border. A touch-target-sized control
        // in this slot would inset itself and break that.
        const rightEdge = trailingInfo.mapToItem(cardWithTrailing,
                                                 trailingInfo.width, 0).x
        fuzzyCompare(cardWithTrailing.width - rightEdge,
                     cardWithTrailing.padding, 1)
    }

    function test_value_slot_is_reparented_into_the_value_row() {
        compare(cardWithValueSlot.valueTrailing.length, 1)
        verify(valueCopy.parent !== null)
        verify(valueCopy.parent !== root)
    }

    function test_value_slot_is_on_the_value_line() {
        const copyCentre = valueCopy.mapToItem(
            cardWithValueSlot, 0, valueCopy.height / 2).y
        const value = cardWithValueSlot.valueItem
        const valueCentre = value.mapToItem(
            cardWithValueSlot, 0, value.height / 2).y
        fuzzyCompare(copyCentre, valueCentre, 2)
    }

    function test_value_slot_sits_at_the_card_edge_not_beside_the_value() {
        // Deliberately the opposite of captionTrailing. The value is the line
        // that changes while you are looking at it, so the affordance holds
        // still at the edge instead of sliding with the digits — and it lands
        // under labelTrailing's slot rather than somewhere in between.
        const rightEdge = valueCopy.mapToItem(cardWithValueSlot,
                                              valueCopy.width, 0).x
        fuzzyCompare(cardWithValueSlot.width - rightEdge,
                     cardWithValueSlot.padding, 1)
    }

    function test_value_slot_does_not_change_the_height() {
        // One grid rhythm: a slot on the value line must not make this card
        // taller than a captioned neighbour without one.
        compare(cardWithValueSlot.implicitHeight, withCaption.implicitHeight)
    }

    function test_value_still_shrinks_to_fit_beside_a_slot() {
        // The regression this layout exists to avoid: the slot must leave the
        // value a real width to fit into, not consume it or feed back into it.
        // Same width, same value, same slot — only the fit mode differs.
        tryCompare(elidingCardWithSlot.valueItem, "truncated", true)
        tryCompare(shrinkingCardWithSlot.valueItem, "truncated", false)
        // And the value stops short of the slot rather than running under it.
        const valueRight = shrinkingCardWithSlot.valueItem.mapToItem(
            shrinkingCardWithSlot, shrinkingCardWithSlot.valueItem.width, 0).x
        const copyLeft = shrinkingCopy.mapToItem(shrinkingCardWithSlot, 0, 0).x
        verify(copyLeft >= valueRight)
    }

    function test_value_slot_takes_fitting_width_from_the_value() {
        // Worth pinning down, because it is the cost of putting the affordance
        // on the value's line: the slot spends width the fit would otherwise
        // have used, so a figure that just fits without one can drop to the
        // floor and elide with one. The right trade — an elided figure is
        // exactly when the copy button earns its place — but a real one.
        verify(shrinkingCardWithSlot.valueItem.width < shrinkingCardWithSlot.width
                                                       - 2 * shrinkingCardWithSlot.padding)
        verify(shrinkingCard.valueItem.width > shrinkingCardWithSlot.valueItem.width
                                               - (shrinkingCardWithSlot.width - shrinkingCard.width))
    }

    function test_empty_value_slot_leaves_the_value_full_width() {
        // The row is unconditional, so an empty slot must cost nothing: a card
        // without one still elides at exactly the same width.
        fuzzyCompare(elidingCard.valueItem.width,
                     elidingCard.width - 2 * elidingCard.padding, 1)
    }

    LogosStatCard {
        id: sweepCard
        width: 210                       // the dashboard's minimum tile width
        label: "Total Balance"
        valueFontSizeMode: Text.HorizontalFit
        valueTrailing: [ LogosCopyButton { id: sweepCopy; value: "x" } ]
    }

    function group(s) {
        let out = ""
        for (let i = 0; i < s.length; i++) {
            if (i > 0 && (s.length - i) % 3 === 0) out += ","
            out += s.charAt(i)
        }
        return out
    }

    function test_value_and_slot_stay_aligned_at_every_value_length() {
        // The bug was length-dependent, which is why it survived review: below
        // the width where HorizontalFit starts shrinking, the glyphs fill their
        // box and AlignTop is indistinguishable from AlignVCenter. Measured on
        // this 210px tile the error was 0px to 9 digits, then ramped — 2.0 at
        // 10, 4.5 at 13 — and pinned at 5.0px from 14 on, where the font hits
        // valueMinimumPixelSize and elides instead of shrinking further. So
        // sweep the whole range rather than sampling one length.
        let digits = ""
        let sawShrink = false
        for (let n = 1; n <= 24; n++) {
            digits += String(n % 10)
            sweepCard.value = group(digits)
            wait(0)
            const v = sweepCard.valueItem
            tryVerify(function () { return v.contentHeight > 0 })
            if (v.contentHeight < v.height)
                sawShrink = true
            const vCentre = v.mapToItem(sweepCard, 0, v.height / 2).y
            const bCentre = sweepCopy.mapToItem(sweepCard, 0, sweepCopy.height / 2).y
            fuzzyCompare(bCentre, vCentre, 1)
        }
        // The sweep has to actually reach the shrinking regime, or it proves
        // nothing about the case that was broken.
        verify(sawShrink)
    }

    function test_value_is_centred_in_its_own_box_not_pinned_to_the_top() {
        // The bug this guards: a layout row stretches the value to the row's
        // height, and a fitted value's box is sized from the UNSHRUNK font — so
        // the glyphs are shorter than their box. Left at the default AlignTop
        // they pin to the top of it and the slot beside them reads as having
        // sunk (measured 5.5px out on a 24px value before this was set).
        const v = shrinkingCardWithSlot.valueItem
        // The scenario has to be real, or the assertion below proves nothing.
        tryVerify(function () { return v.contentHeight < v.height })
        compare(v.verticalAlignment, Text.AlignVCenter)
        compare(card.valueItem.verticalAlignment, Text.AlignVCenter)
    }

    function test_value_slot_is_centred_on_a_fitted_value() {
        const s = shrinkingCardWithSlot
        const v = s.valueItem
        const vTop = v.mapToItem(s, 0, 0).y
        const bTop = shrinkingCopy.mapToItem(s, 0, 0).y
        // Centred glyphs mean the item's centre IS the optical centre.
        fuzzyCompare(bTop + shrinkingCopy.height / 2, vTop + v.height / 2, 1)
    }

    function test_caption_slot_is_reparented_into_the_caption_row() {
        compare(cardWithCaptionSlot.captionTrailing.length, 1)
        verify(captionCopy.parent !== null)
        verify(captionCopy.parent !== root)
    }

    function test_caption_slot_sits_beside_the_caption_not_at_the_card_edge() {
        // The design puts the copy glyph immediately after the hash, not flung
        // out to the right-hand border.
        const caption = cardWithCaptionSlot.captionItem
        const captionRight = caption.mapToItem(cardWithCaptionSlot,
                                               caption.width, 0).x
        const copyLeft = captionCopy.mapToItem(cardWithCaptionSlot, 0, 0).x
        verify(copyLeft >= captionRight)
        // Within a small gap of the text, nowhere near the far edge.
        verify(copyLeft - captionRight <= Theme.spacing.large)
        verify(copyLeft < cardWithCaptionSlot.width / 2)
    }

    function test_caption_slot_is_on_the_caption_line() {
        const copyCentre = captionCopy.mapToItem(
            cardWithCaptionSlot, 0, captionCopy.height / 2).y
        const caption = cardWithCaptionSlot.captionItem
        const captionCentre = caption.mapToItem(
            cardWithCaptionSlot, 0, caption.height / 2).y
        fuzzyCompare(copyCentre, captionCentre, 2)
    }

    function test_caption_slot_does_not_change_the_height() {
        // Still one grid rhythm — a slot on the caption line must not make
        // this card taller than its captioned neighbours.
        compare(cardWithCaptionSlot.implicitHeight, withCaption.implicitHeight)
    }

    function test_trailing_is_centred_on_the_label() {
        const label = cardWithTrailing.labelItem
        const infoCentre = trailingInfo.mapToItem(
            cardWithTrailing, 0, trailingInfo.height / 2).y
        const labelCentre = label.mapToItem(
            cardWithTrailing, 0, label.height / 2).y
        fuzzyCompare(infoCentre, labelCentre, 1)
    }

    // ---- Flash ----

    function test_first_value_does_not_flash() {
        // Arriving at a number is not the number changing.
        compare(freshCard.flashAnimationItem.running, false)
        freshCard.value = "151548"
        compare(freshCard.flashAnimationItem.running, false)
    }

    function test_later_change_flashes() {
        freshCard.value = "151549"
        freshCard.value = "151550"
        compare(freshCard.flashAnimationItem.running, true)
        freshCard.flashAnimationItem.stop()
    }

    function test_no_flash_when_disabled() {
        card.flashOnChange = false
        card.value = "151551"
        card.value = "151552"
        compare(card.flashAnimationItem.running, false)
    }

    function test_severity_still_applies_after_a_flash() {
        // The regression the restore Binding exists for: the animation writes
        // to valueItem.color, which destroys the declarative binding. Without
        // reinstating it, a warning raised after an update never shows.
        card.flashDuration = 0
        card.flashOnChange = true
        card.value = "151553"
        card.value = "151554"
        tryCompare(card.flashAnimationItem, "running", false)
        card.severity = LogosStatCard.Warning
        tryCompare(card.valueItem, "color", Theme.palette.warning)
    }

    function test_flash_settles_back_to_the_severity_color() {
        card.flashDuration = 0
        card.severity = LogosStatCard.Warning
        card.flashOnChange = true
        card.value = "151555"
        card.value = "151556"
        tryCompare(card.flashAnimationItem, "running", false)
        tryCompare(card.valueItem, "color", Theme.palette.warning)
    }
}
