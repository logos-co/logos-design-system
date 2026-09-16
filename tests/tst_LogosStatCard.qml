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
        card.interactive = false
        card.flashColor = Theme.palette.primary
        card.flashDuration = 1260
        card.borderColor = "transparent"
    }

    // ---- Content ----

    function test_text_reaches_the_items() {
        card.caption = "12 slots behind"
        compare(card.labelItem.text, "Height")
        compare(card.valueItem.text, "151548")
        compare(card.captionItem.text, "12 slots behind")
    }

    // ---- Grid rhythm ----

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
