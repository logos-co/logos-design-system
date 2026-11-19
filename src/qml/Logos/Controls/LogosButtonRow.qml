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
    implicitHeight: stacked ? stack.implicitHeight : row.implicitHeight

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

        onAllChanged: {
            for (let i = 0; i < all.length; ++i)
                all[i].Layout.fillWidth = true
        }

        // The stack's layout sized and placed them; a Row sets only x, and keeps
        // the size and y it finds.
        function unstack() {
            for (let i = 0; i < all.length; ++i) {
                all[i].width = undefined
                all[i].height = undefined
                all[i].y = 0
            }
        }
    }

    onStackedChanged: if (!stacked) Qt.callLater(d.unstack)

    RowLayout {
        id: row
        visible: !root.stacked
        anchors.fill: parent
        spacing: Theme.spacing.small

        Item {
            visible: root.alignment === Qt.AlignHCenter || root.alignment === Qt.AlignRight
            Layout.fillWidth: true
        }

        Row {
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            spacing: Theme.spacing.small
            children: root.stacked ? [] : root.leftActions
        }

        Item {
            visible: root.alignment === Qt.AlignJustify
            Layout.fillWidth: true
        }

        Row {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            spacing: Theme.spacing.small
            children: root.stacked ? [] : root.rightActions
        }

        Item {
            visible: root.alignment === Qt.AlignHCenter || root.alignment === Qt.AlignLeft
            Layout.fillWidth: true
        }
    }

    ColumnLayout {
        id: stack
        visible: root.stacked
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Theme.spacing.small
        children: root.stacked ? d.all : []
    }
}
