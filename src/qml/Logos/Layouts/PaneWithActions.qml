import QtQuick
import QtQuick.Layouts

import Logos.Theme

// Internal. A pane holding one item and its actions, as LogosListDetail's
// detail and LogosSidePanel's panel do: when `wide`, the actions are a row
// across the top, wrapping; otherwise an equal-width bar pinned to the
// bottom, in thumb reach, above the keyboard and the safe area. While every
// action is hidden there is neither. An item that is replaced or cleared is
// taken out.
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

        // Read while the row or bar holding them is visible, which they stay
        // for that: a hidden one would hide its actions too, and never show.
        readonly property bool anyShown: {
            for (let i = 0; i < root.actions.length; ++i)
                if (root.actions[i].visible)
                    return true
            return false
        }

        // The bar's layout sized and placed them; a cell keeps what it finds.
        function unbar() {
            for (let i = 0; i < root.actions.length; ++i) {
                root.actions[i].width = undefined
                root.actions[i].height = undefined
                root.actions[i].x = 0
                root.actions[i].y = 0
            }
        }
    }

    Flow {
        id: actionRow
        readonly property bool shown: visible && d.anyShown
        visible: root.wide && root.actions.length > 0
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: shown ? Theme.pageMargin(root.width) : 0
        height: shown ? implicitHeight : 0
        spacing: Theme.spacing.small

        // Each action in a cell, which stays: a Flow culls a child it holds
        // hidden, and Qt never draws one that leaves it culled.
        Repeater {
            model: root.actions.length
            delegate: Item {
                required property int index
                readonly property Item action: root.wide ? root.actions[index] ?? null : null
                readonly property bool shown: action !== null && action.visible
                width: shown ? action.width : 0
                height: shown ? action.height : 0
                children: action ? [action] : []
            }
        }
    }

    Item {
        id: area
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: actionRow.shown ? actionRow.bottom : parent.top
        anchors.topMargin: actionRow.shown ? Theme.spacing.medium : 0
        anchors.bottom: actionBar.shown ? actionBar.top : parent.bottom
    }

    Rectangle {
        id: actionBar
        readonly property bool shown: visible && d.anyShown
        visible: !root.wide && root.actions.length > 0
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        implicitHeight: shown ? actionBarRow.implicitHeight + 2 * Theme.spacing.medium + Theme.bottomInset(root) : 0
        color: shown ? Theme.palette.backgroundSecondary : "transparent"

        Rectangle {
            visible: actionBar.shown
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
