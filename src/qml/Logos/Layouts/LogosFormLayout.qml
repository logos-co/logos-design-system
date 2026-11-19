import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

// LogosFormLayout — a form: its fields, then its buttons, at most form.maximumWidth
// wide and centred inside the page margins. On desktop, measured on itself, each
// LogosFormField has its label in a column beside the control and the buttons
// are together at the end, the main one last. Narrower, labels go above the
// controls; on a tablet neighbouring narrow fields share a row. On a phone every
// field is full width and the buttons stack, the main one last. Other items,
// such as a heading, take the full width. Put it in a scroll view if it can be
// taller than the page: while the on-screen keyboard is up, the field with
// focus scrolls into view, and the form has room below to scroll it there.
//
// Public API:
//     leftActions, rightActions   the buttons; the main ones on the right
//     maximumWidth                the form's widest (default form.maximumWidth)
//     labelsBeside                read-only; labels are beside their controls
//     content (default)           the fields and anything between them
//
// Read-only inspection aliases: buttonRowItem.
//
// Example:
//     LogosFormLayout {
//         width: parent.width
//         rightActions: [ LogosButton { text: qsTr("Save"); onClicked: save() } ]
//         LogosFormField { label: qsTr("Name"); LogosTextField {} }
//         LogosFormField { label: qsTr("City"); narrow: true; LogosTextField {} }
//         LogosFormField { label: qsTr("Postcode"); narrow: true; LogosTextField {} }
//     }
Item {
    id: root

    property list<Item> leftActions
    property list<Item> rightActions
    property real maximumWidth: Theme.layouts.form.maximumWidth
    readonly property bool labelsBeside: Theme.windowClass(width) === "desktop"
    default property alias content: grid.data

    readonly property alias buttonRowItem: buttons

    implicitWidth: maximumWidth
    implicitHeight: column.implicitHeight + d.keyboardRoom

    QtObject {
        id: d

        // The field with focus, if it is in this form.
        property Item focusField: null
        readonly property real keyboardRoom: focusField ? Theme.keyboardHeight : 0
        onKeyboardRoomChanged: Qt.callLater(reveal)

        function follow(item) {
            let inside = item
            while (inside && inside !== root)
                inside = inside.parent
            focusField = inside ? item : null
            reveal()
        }
        function reveal() {
            if (focusField && Theme.keyboardHeight > 0)
                Theme.scrollIntoView(focusField, root)
        }

        readonly property bool pairShortFields: Theme.windowClass(root.width) === "tablet"

        readonly property var items: {
            const list = []
            for (let i = 0; i < grid.children.length; ++i)
                if (!(grid.children[i] instanceof Repeater))
                    list.push(grid.children[i])
            return list
        }

        function isField(item) {
            return item instanceof LogosFormField
        }

        // Spans: a narrow field next to another narrow one takes half the row on
        // a tablet; everything else the whole row.
        function arrange() {
            for (let i = 0; i < items.length; ++i) {
                const item = items[i]
                item.Layout.fillWidth = true
                item.Layout.alignment = Qt.AlignTop
                item.Layout.columnSpan = 2
                item.Layout.preferredWidth = -1
                if (isField(item))
                    item.labelBeside = root.labelsBeside
            }
            if (!pairShortFields)
                return
            for (let i = 0; i + 1 < items.length; ++i) {
                if (isField(items[i]) && items[i].narrow && isField(items[i + 1]) && items[i + 1].narrow) {
                    for (const item of [items[i], items[i + 1]]) {
                        item.Layout.columnSpan = 1
                        // Equal halves: the same preferred width, both filling.
                        item.Layout.preferredWidth = 0
                    }
                    ++i
                }
            }
        }

        onItemsChanged: Qt.callLater(arrange)
        onPairShortFieldsChanged: arrange()
    }

    onLabelsBesideChanged: d.arrange()

    Connections {
        target: root.Window.window
        function onActiveFocusItemChanged() { d.follow(root.Window.window.activeFocusItem) }
    }

    ColumnLayout {
        id: column
        x: (root.width - width) / 2
        width: Math.min(root.width - 2 * Theme.pageMargin(root.width), root.maximumWidth)
        spacing: Theme.spacing.xlarge

        GridLayout {
            id: grid
            Layout.fillWidth: true
            columns: 2
            columnSpacing: Theme.spacing.large
            rowSpacing: Theme.spacing.large
        }

        LogosButtonRow {
            id: buttons
            visible: root.leftActions.length > 0 || root.rightActions.length > 0
            Layout.fillWidth: true
            alignment: root.labelsBeside ? Qt.AlignRight : Qt.AlignJustify
            // The form's own width decides, not its narrower column.
            stackOnPhone: Theme.windowClass(root.width) === "phone"
            leftActions: root.leftActions
            rightActions: root.rightActions
        }
    }
}
