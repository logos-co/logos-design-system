import QtQuick
import QtQuick.Layouts

import Logos.Theme

// LogosListDetail — a list and the detail of its open item. From tablet width
// up, measured on itself, it shows both: the list in a fixed-width pane, the
// detail filling the rest; the detail always shows something (the first item
// by default). At phone width the list is the page and the detail replaces
// it while `detailOpen` is true; a page bar shows ‹ from `showingDetail` and
// sets `detailOpen` back to false, as Esc and the phone's Back key do.
// Narrowing to phone width with a detail open keeps it open.
//
// The detail's actions (Reply, Archive) are buttons, never hover-only: from
// tablet width up a row across the top of the detail, wrapping; at phone width
// an equal-width bar pinned to the bottom, in thumb reach, above the keyboard
// and the safe area. A list or detail that is replaced or cleared is taken out.
//
// Public API:
//     list            the list pane's item
//     detail          the detail pane's item
//     detailOpen      the user opened an item (matters at phone width)
//     listWidth       the list pane's width beside the detail
//     twoPane         read-only; list and detail side by side
//     showingDetail   read-only; the detail fills the page (phone width)
//     detailActions   the detail's buttons, the main one first
//
// Read-only inspection aliases: listPaneItem, detailPaneItem, actionRowItem,
// actionBarItem.
//
// Example:
//     LogosListDetail {
//         id: inbox
//         list: ListView { … delegate: LogosListRow { selected: …; onClicked: { open(index); inbox.detailOpen = true } } }
//         detail: MessageView { message: current }
//     }
//     // in the page bar: canGoBack: inbox.showingDetail; onBackRequested: inbox.detailOpen = false
Item {
    id: root

    property Item list: null
    property Item detail: null
    property bool detailOpen: false
    property list<Item> detailActions
    property int listWidth: Theme.windowClass(width) === "tablet" ? Theme.layouts.listDetail.tabletListWidth
                                                                  : Theme.layouts.listDetail.desktopListWidth
    readonly property bool twoPane: Theme.windowClass(width) !== "phone"
    readonly property bool showingDetail: !twoPane && detailOpen

    readonly property alias listPaneItem: listPane
    // Where the detail goes: the pane less its actions.
    readonly property alias detailPaneItem: detailArea
    readonly property alias actionRowItem: actionRow
    readonly property alias actionBarItem: actionBar

    onListChanged: d.shownList = d.adopt(list, d.shownList, listPane)
    onDetailChanged: d.shownDetail = d.adopt(detail, d.shownDetail, detailArea)
    onDetailActionsChanged: {
        for (let i = 0; i < detailActions.length; ++i) {
            detailActions[i].Layout.fillWidth = true
            // Equal widths in the bar, whatever their text.
            detailActions[i].Layout.preferredWidth = 0
        }
    }
    onTwoPaneChanged: if (twoPane) Qt.callLater(d.unbar)

    Keys.onEscapePressed: function(event) { d.back(event) }
    Keys.onBackPressed: function(event) { d.back(event) }

    QtObject {
        id: d
        property Item shownList: null
        property Item shownDetail: null

        function adopt(item, shown, pane) {
            if (shown && shown !== item)
                shown.parent = null
            if (item) {
                item.parent = pane
                item.anchors.fill = pane
            }
            return item
        }

        // The bar's layout sized them; a Flow keeps the size it finds.
        function unbar() {
            for (let i = 0; i < root.detailActions.length; ++i) {
                root.detailActions[i].width = undefined
                root.detailActions[i].height = undefined
            }
        }
        
        function back(event) {
            event.accepted = root.showingDetail
            if (!root.showingDetail)
                return
            root.detailOpen = false
            root.forceActiveFocus()
        }
    }

    Rectangle {
        id: listPane
        visible: root.twoPane || !root.detailOpen
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.twoPane ? root.listWidth : root.width
        color: root.twoPane ? Theme.palette.backgroundSecondary : "transparent"
        clip: true

        Rectangle {
            visible: root.twoPane
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Theme.size.borderWidth
            color: Theme.palette.borderSubtle
        }
    }

    Item {
        id: detailPane
        visible: root.twoPane || root.detailOpen
        anchors.left: root.twoPane ? listPane.right : parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        clip: true

        Flow {
            id: actionRow
            visible: root.twoPane && root.detailActions.length > 0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: visible ? Theme.pageMargin(detailPane.width) : 0
            height: visible ? implicitHeight : 0
            spacing: Theme.spacing.small
            children: root.twoPane ? root.detailActions : []
        }

        Item {
            id: detailArea
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: actionRow.visible ? actionRow.bottom : parent.top
            anchors.topMargin: actionRow.visible ? Theme.spacing.medium : 0
            anchors.bottom: actionBar.visible ? actionBar.top : parent.bottom
        }

        Rectangle {
            id: actionBar
            visible: !root.twoPane && root.detailActions.length > 0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            implicitHeight: actionBarRow.implicitHeight + 2 * Theme.spacing.medium + Theme.bottomInset(detailPane)
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
                children: root.twoPane ? [] : root.detailActions
            }
        }
    }
}
