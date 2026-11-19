import QtQuick
import QtQuick.Layouts
import QtTest

import Logos.Theme
import Logos.Controls
import Logos.Layouts

TestCase {
    id: root
    name: "LogosFormLayout"
    width: 1100
    height: 800
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
    when: windowShown

    Component {
        id: form
        LogosFormLayout {
            id: f
            readonly property alias name: nameField
            readonly property alias city: cityField
            readonly property alias postcode: postcodeField
            readonly property alias note: noteField
            leftActions: [ LogosButton { text: "Cancel" } ]
            rightActions: [ LogosButton { text: "Save" } ]
            LogosFormField { id: nameField; label: "Name"; LogosTextField {} }
            LogosFormField { id: cityField; label: "City"; narrow: true; LogosTextField {} }
            LogosFormField { id: postcodeField; label: "Postcode"; narrow: true; LogosComboBox { model: ["1000", "2000"] } }
            LogosFormField { id: noteField; label: "Note"; help: "Only you see this."; LogosTextField {} }
        }
    }

    function cleanup() {
        Theme.keyboardHeight = 0
    }

    function create(width) {
        const f = createTemporaryObject(form, root, { width: width })
        waitForRendering(f)
        return f
    }

    function leftOf(item, f) { return item.mapToItem(f, 0, 0).x }
    function topOf(item, f) { return item.mapToItem(f, 0, 0).y }

    // Wide, the form keeps to its maximum width, centred.
    function test_capped_and_centred_on_desktop() {
        const f = create(1100)
        compare(f.name.width, Theme.layouts.form.maximumWidth)
        fuzzyCompare(leftOf(f.name, f), (1100 - Theme.layouts.form.maximumWidth) / 2, 0.5)
    }

    function test_labels_beside_the_controls_on_desktop() {
        const f = create(1100)
        verify(f.labelsBeside)
        verify(f.name.labelBeside)
        const control = f.name.content[0]
        compare(f.name.labelItem.width, Theme.layouts.form.labelWidth)
        verify(leftOf(control, f) > leftOf(f.name.labelItem, f) + f.name.labelItem.width)
        compare(topOf(control, f), topOf(f.name.labelItem, f))
    }

    // On a tablet, labels above; neighbouring narrow fields share a row.
    function test_tablet_pairs_narrow_fields() {
        const f = create(700)
        verify(!f.labelsBeside)
        verify(topOf(f.name.content[0], f) > topOf(f.name.labelItem, f))
        compare(topOf(f.postcode, f), topOf(f.city, f))
        verify(leftOf(f.postcode, f) > leftOf(f.city, f))
        // Halves, whatever their controls' own widths and heights.
        compare(f.postcode.width, f.city.width)
        compare(topOf(f.postcode.labelItem, f), topOf(f.city.labelItem, f))
        verify(topOf(f.note, f) > topOf(f.city, f))
        compare(f.note.width, f.name.width)
    }

    // On a phone, every field is a row of its own and the buttons stack.
    function test_phone_has_one_field_per_row_and_stacked_buttons() {
        const f = create(390)
        compare(f.name.width, 390 - 2 * Theme.pageMargin(390))
        verify(topOf(f.postcode, f) > topOf(f.city, f))
        compare(f.postcode.width, f.name.width)
        verify(f.buttonRowItem.stacked)
        const cancel = f.leftActions[0], save = f.rightActions[0]
        verify(topOf(save, f) > topOf(cancel, f))
    }

    // On desktop the buttons are together at the end, the main one last.
    function test_desktop_buttons_are_together_at_the_end() {
        const f = create(1100)
        verify(!f.buttonRowItem.stacked)
        const cancel = f.leftActions[0], save = f.rightActions[0]
        compare(topOf(save, f), topOf(cancel, f))
        verify(leftOf(save, f) > leftOf(cancel, f))
        fuzzyCompare(leftOf(save, f) + save.width, leftOf(f.name, f) + f.name.width, 0.5)
        verify(leftOf(cancel, f) > leftOf(f.name, f) + f.name.width / 2)
    }

    // The column is narrower than the form; the form's own width decides.
    function test_a_tablet_form_keeps_its_buttons_in_a_row() {
        const f = create(620)
        verify(!f.buttonRowItem.stacked)
    }

    function test_help_and_errors_sit_under_the_control() {
        const f = create(700)
        const note = f.note
        verify(note.helpItem.visible)
        verify(topOf(note.helpItem, f) > topOf(note.content[0], f))
        note.error = "Too long."
        verify(!note.helpItem.visible)
        verify(note.errorItem.visible)
        compare(note.errorItem.color, Theme.palette.error)
    }

    // A screen reader on the control hears the field's label, and its error
    // or help, as they change.
    function test_the_control_carries_the_label_and_the_error() {
        const f = create(1000)
        const control = f.note.content[0]
        compare(control.Accessible.name, "Note")
        compare(control.Accessible.description, "Only you see this.")
        f.note.error = "Too long."
        compare(control.Accessible.description, "Too long.")
        f.note.error = ""
        compare(control.Accessible.description, "Only you see this.")
        compare(f.postcode.content[0].Accessible.name, "Postcode")
    }

    // With the keyboard up and a field in the form focused, the form has room
    // below to scroll that field clear of it.
    function test_room_below_for_the_keyboard() {
        const f = create(390)
        const height = f.implicitHeight
        Theme.keyboardHeight = 250
        compare(f.implicitHeight, height, "no room while nothing in it has focus")
        f.note.content[0].forceActiveFocus()
        tryCompare(f, "implicitHeight", height + 250)
        root.forceActiveFocus()
        tryCompare(f, "implicitHeight", height)
    }
}
