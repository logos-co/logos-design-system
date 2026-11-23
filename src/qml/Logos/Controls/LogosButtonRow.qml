import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

// LogosButtonRow — the buttons under a form, a card or a status message. While
// they fit, each at least buttonRow.minButtonWidth wide, they are one row: the
// left-hand ones at the start, the right-hand (main) ones at the end. When they
// don't fit, or when the row is phone-wide, they stack full width with the main
// ones last, where the thumb is. Give it a width, e.g. Layout.fillWidth.
//
// Public API:
//     leftActions, rightActions   the buttons; the main ones on the right
//     stackOnPhone                stack in a phone-wide row even when they fit
//                                 (default true); false for buttons in a card
//     alignment                   in a row: Qt.AlignJustify (default) puts the left
//                                 and right ones at the two ends; Qt.AlignLeft,
//                                 AlignHCenter or AlignRight keeps them together
//     stacked                     read-only; the buttons are stacked
//
// Example:
//     LogosButtonRow {
//         Layout.fillWidth: true
//         leftActions: [ LogosButton { text: qsTr("Cancel") } ]
//         rightActions: [ LogosButton { text: qsTr("Save") } ]
//     }
Item {
    id: root

    property list<Item> leftActions
    property list<Item> rightActions
    property bool stackOnPhone: true
    property int alignment: Qt.AlignJustify
    readonly property bool stacked: (stackOnPhone && Theme.windowClass(width) === "phone") || d.rowWidth > width

    implicitWidth: d.rowWidth
    implicitHeight: grid.implicitHeight

    QtObject {
        id: d

        readonly property var all: {
            const items = []
            for (let i = 0; i < root.leftActions.length; ++i)
                items.push(root.leftActions[i])
            for (let i = 0; i < root.rightActions.length; ++i)
                items.push(root.rightActions[i])
            return items
        }

        readonly property real rowWidth: {
            let w = 0
            for (let i = 0; i < all.length; ++i)
                w += Math.max(all[i].implicitWidth, Theme.controls.buttonRow.minButtonWidth)
            return w + Math.max(0, all.length - 1) * Theme.spacing.small
        }

        // The grid's cells: room before, between and after the two sides, as
        // the alignment asks. A row, or a stack; never moved between two, as
        // a Row hides for good an item it held hidden once it leaves (Qt
        // culls it).
        readonly property Item before: Item {
            Layout.fillWidth: true
            visible: !root.stacked && (root.alignment === Qt.AlignHCenter || root.alignment === Qt.AlignRight)
        }
        readonly property Item between: Item {
            Layout.fillWidth: true
            visible: !root.stacked && root.alignment === Qt.AlignJustify
        }
        readonly property Item after: Item {
            Layout.fillWidth: true
            visible: !root.stacked && (root.alignment === Qt.AlignHCenter || root.alignment === Qt.AlignLeft)
        }
        readonly property var cells: {
            const items = [before]
            for (let i = 0; i < root.leftActions.length; ++i)
                items.push(root.leftActions[i])
            items.push(between)
            for (let i = 0; i < root.rightActions.length; ++i)
                items.push(root.rightActions[i])
            items.push(after)
            return items
        }

        onAllChanged: stretch()

        // Full width in the stack, their own in the row.
        function stretch() {
            for (let i = 0; i < all.length; ++i)
                all[i].Layout.fillWidth = root.stacked
        }
    }

    onStackedChanged: d.stretch()

    GridLayout {
        id: grid
        anchors.left: parent.left
        anchors.right: parent.right
        y: root.stacked ? 0 : (root.height - height) / 2
        flow: root.stacked ? GridLayout.TopToBottom : GridLayout.LeftToRight
        rowSpacing: Theme.spacing.small
        columnSpacing: Theme.spacing.small
        children: d.cells
    }
}
