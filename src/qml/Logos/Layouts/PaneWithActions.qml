import QtQuick
import QtQuick.Layouts

import Logos.Theme

// Internal. A pane holding one item and its actions, as LogosListDetail's
// detail and LogosSidePanel's panel do: when `wide`, the actions are a row
// across the top, wrapping; otherwise an equal-width bar pinned to the
// bottom, in thumb reach, above the keyboard and the safe area. An item that
// is replaced or cleared is taken out.
//
// API: item, actions, wide; areaItem (where the item goes), rowItem, barItem.
Item {
    id: root

    property Item item: null
    property list<Item> actions
    property bool wide: true

    readonly property alias areaItem: area
    readonly property alias rowItem: actionRow
    readonly property alias barItem: actionBar

    onItemChanged: {
        if (d.shown && d.shown !== item)
            d.shown.parent = null
        if (item) {
            item.parent = area
            item.anchors.fill = area
        }
        d.shown = item
    }
    onActionsChanged: {
        for (let i = 0; i < actions.length; ++i) {
            actions[i].Layout.fillWidth = true
            // Equal widths in the bar, whatever their text.
            actions[i].Layout.preferredWidth = 0
        }
    }
    onWideChanged: if (wide) Qt.callLater(d.unbar)

    QtObject {
        id: d
        property Item shown: null

        // The bar's layout sized them; a Flow keeps the size it finds.
        function unbar() {
            for (let i = 0; i < root.actions.length; ++i) {
                root.actions[i].width = undefined
                root.actions[i].height = undefined
            }
        }
    }

    Flow {
        id: actionRow
        visible: root.wide && root.actions.length > 0
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: visible ? Theme.pageMargin(root.width) : 0
        height: visible ? implicitHeight : 0
        spacing: Theme.spacing.small
        children: root.wide ? root.actions : []
    }

    Item {
        id: area
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: actionRow.visible ? actionRow.bottom : parent.top
        anchors.topMargin: actionRow.visible ? Theme.spacing.medium : 0
        anchors.bottom: actionBar.visible ? actionBar.top : parent.bottom
    }

    Rectangle {
        id: actionBar
        visible: !root.wide && root.actions.length > 0
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        implicitHeight: actionBarRow.implicitHeight + 2 * Theme.spacing.medium + Theme.bottomInset(root)
        color: Theme.palette.backgroundSecondary

        Rectangle {
            width: parent.width
            height: Theme.size.borderWidth
            color: Theme.palette.borderSubtle
        }

        RowLayout {
            id: actionBarRow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: Theme.spacing.medium
            anchors.leftMargin: Theme.pageMargin(root.width)
            anchors.rightMargin: Theme.pageMargin(root.width)
            spacing: Theme.spacing.medium
            children: root.wide ? [] : root.actions
        }
    }
}
