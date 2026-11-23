import QtQuick

import Logos.Theme
import Logos.Icons
import Logos.Controls

// LogosSidePanel — a page's content and a panel beside it, opened on demand:
// the details of a table's row, a conversation's info. From tablet width up,
// measured on itself, the panel is `panelWidth` wide beside the content, which
// narrows for it (a table drops columns); at phone width the panel is the
// page while it is open. Narrowing to phone width with the panel open keeps
// it open.
//
// With a `title`, the panel starts with a page bar that closes it: ✕ beside
// the content, ‹ on a phone. Where the page's host draws the way back
// instead, as LogosSections' back row does, set backInHost: on a phone the
// bar then only names the panel, so there is one way back. Without a title,
// give the panel your own way to close (`showingPanel` says when it is the
// page). Esc and the phone's Back key close it too. Closing sets `panelOpen` to false, so keep your state in
// step with onPanelOpenChanged rather than binding panelOpen.
//
// The panel's actions are buttons, never hover-only: beside the content a
// row across the top of the panel, wrapping; on a phone an equal-width bar
// pinned to the bottom, above the keyboard and the safe area. A content or
// panel that is replaced or cleared is taken out and unanchored; it stays the
// app's.
//
// Which layout: if the open item is what the page is for (a message, a
// settings page), LogosListDetail; if the page is (a table, a thread) and the
// item's details are secondary, LogosSidePanel.
//
// Public API:
//     content         the page's item; it fills what the panel leaves
//     panel           the panel's item
//     panelOpen       the panel shows
//     panelWidth      the panel's width beside the content
//     spacing         the space between the content and the panel beside it
//                     (default 0)
//     divider         a hairline down the panel's side beside the content
//                     (default true); off for a panel framed as a card
//     title           the panel's title; shows its page bar
//     backInHost      on a phone the host's back closes the panel, not the bar's ‹
//     panelActions    the panel's buttons, the main one first
//     beside          read-only; the panel goes beside the content
//     showingPanel    read-only; the panel is the page (phone width)
//
// Read-only inspection aliases: contentPaneItem, panelFrameItem, panelPaneItem,
// headerItem, closeButtonItem, actionRowItem, actionBarItem, dividerItem.
//
// Example:
//     LogosSidePanel {
//         id: packages
//         content: LogosTable { onRowClicked: (index, row) => { page.openRow = row; packages.panelOpen = true } }
//         panel: PackageDetails { row: page.openRow }
//         title: page.openRow ? page.openRow.name : ""
//         panelActions: [ LogosButton { text: qsTr("Install") } ]
//         onPanelOpenChanged: if (!panelOpen) page.openRow = null
//     }
Item {
    id: root

    property Item content: null
    property Item panel: null
    property bool panelOpen: false
    property int panelWidth: Theme.layouts.sidePanel.width
    property real spacing: 0
    property bool divider: true
    property string title: ""
    property bool backInHost: false
    property list<Item> panelActions
    readonly property bool beside: Theme.windowClass(width) !== "phone"
    readonly property bool showingPanel: !beside && panelOpen

    readonly property alias contentPaneItem: contentPane
    // The panel as a whole: its page bar, its item and its actions.
    readonly property alias panelFrameItem: panelFrame
    // Where the panel goes: the pane less its page bar and actions.
    readonly property alias panelPaneItem: panelPane.areaItem
    readonly property alias headerItem: header
    readonly property alias closeButtonItem: closeButton
    readonly property alias actionRowItem: panelPane.rowItem
    readonly property alias actionBarItem: panelPane.barItem
    readonly property alias dividerItem: dividerLine

    onContentChanged: {
        if (d.shownContent && d.shownContent !== content) {
            d.shownContent.anchors.fill = undefined
            d.shownContent.parent = null
        }
        if (content) {
            content.parent = contentPane
            content.anchors.fill = contentPane
        }
        d.shownContent = content
    }

    Keys.onEscapePressed: function(event) { d.close(event) }
    Keys.onBackPressed: function(event) { d.close(event) }

    QtObject {
        id: d
        property Item shownContent: null

        function close(event) {
            event.accepted = root.panelOpen
            if (root.panelOpen)
                closePanel()
        }

        // Keys typed next don't go to the hidden panel.
        function closePanel() {
            root.panelOpen = false
            root.forceActiveFocus()
        }
    }

    Item {
        id: contentPane
        visible: !root.showingPanel
        anchors.left: parent.left
        anchors.right: root.beside && root.panelOpen ? panelFrame.left : parent.right
        anchors.rightMargin: root.beside && root.panelOpen ? root.spacing : 0
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        clip: true
    }

    // The page's background, as its page bar has, on whatever it sits on.
    Rectangle {
        id: panelFrame
        visible: root.panelOpen
        color: Theme.palette.background
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.beside ? root.panelWidth : root.width
        clip: true

        Rectangle {
            id: dividerLine
            visible: root.beside && root.divider
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Theme.size.borderWidth
            color: Theme.palette.borderSubtle
        }

        LogosPageBar {
            id: header
            visible: root.title !== ""
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: root.beside ? Theme.size.borderWidth : 0
            title: root.title
            canGoBack: !root.beside && !root.backInHost
            onBackRequested: d.closePanel()
            actions: [
                LogosIconButton {
                    id: closeButton
                    visible: root.beside
                    size: Theme.size.touchTarget
                    flat: true
                    iconSource: LogosIcons.close
                    Accessible.name: qsTr("Close")
                    onClicked: d.closePanel()
                }
            ]
        }

        PaneWithActions {
            id: panelPane
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.visible ? header.bottom : parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: root.beside ? Theme.size.borderWidth : 0
            item: root.panel
            actions: root.panelActions
            wide: root.beside
        }
    }
}
