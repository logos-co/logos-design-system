import QtQuick

import Logos.Theme

// LogosListDetail — a list and the detail of its open item. From tablet width
// up, measured on itself, it shows both: the list in a fixed-width pane, the
// detail filling the rest; the detail always shows something (the first item
// by default). At phone width the list is the page and the detail replaces
// it while `detailOpen` is true; a page bar shows ‹ from `showingDetail` and
// sets `detailOpen` back to false. Narrowing to phone width with a detail open
// keeps it open.
//
// Public API:
//     list            the list pane's item
//     detail          the detail pane's item
//     detailOpen      the user opened an item (matters at phone width)
//     twoPane         read-only; list and detail side by side
//     showingDetail   read-only; the detail fills the page (phone width)
//
// Read-only inspection aliases: listPaneItem, detailPaneItem.
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
    readonly property bool twoPane: Theme.windowClass(width) !== "phone"
    readonly property bool showingDetail: !twoPane && detailOpen

    readonly property alias listPaneItem: listPane
    readonly property alias detailPaneItem: detailPane

    onListChanged: d.adopt(list, listPane)
    onDetailChanged: d.adopt(detail, detailPane)

    QtObject {
        id: d
        function adopt(item, pane) {
            if (!item)
                return
            item.parent = pane
            item.anchors.fill = pane
        }
    }

    Rectangle {
        id: listPane
        visible: root.twoPane || !root.detailOpen
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: !root.twoPane ? root.width
             : Theme.windowClass(root.width) === "tablet" ? Theme.layouts.listDetail.tabletListWidth
             : Theme.layouts.listDetail.desktopListWidth
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
    }
}
