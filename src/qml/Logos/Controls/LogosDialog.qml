import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Icons
import Logos.Controls

// LogosDialog — a modal dialog: a title, a message or your own content, and
// actions on the left and right of its footer.
//
// It places itself in its parent: centred, at preferredWidth but never wider
// than the parent less its page margins. In a phone-wide parent it is a sheet
// across the bottom instead, or with fullPage it fills the parent, for long
// content such as a form. On a phone its actions stack full width with the
// right-hand ones last, where the thumb is. A sheet that closes on a press
// outside also closes, rejected, when dragged down by its handle or title (a
// swipe in the body scrolls it), and shows a handle for it; a full
// page that closes on Escape has a ✕. The body scrolls when the dialog is
// shorter than it; title and actions stay. Setting anchors.centerIn or width
// yourself places it off a phone; on one, the sheet or the page takes over.
// A dialog the app centres measures its window for that, one that places
// itself its parent. On a phone it stays above the on-screen keyboard and clear
// of the safe area, and the field with focus scrolls into view.
//
// Public API:
//     title, message                 the header and the text at the top of the body
//     body                           your own content, below the message; one
//                                    replaced or cleared is taken out
//     leftActions, rightActions      footer buttons; the main ones on the right
//     preferredWidth                 its width when centred (default: its content's)
//     fullPage                       on a phone, fill the parent instead of a sheet
//     sheet                          read-only; it is a bottom sheet
//     dragToClose                    read-only; a sheet that closes when dragged down
//     borderColor, backgroundColor
// Setting contentItem replaces the scrolling body; prefer body.
//
// Read-only inspection aliases: backgroundItem, headerItem, footerItem,
// messageItem, handleItem, dragAreaItem, closeButtonItem, scrollViewItem.
//
// Example:
//     LogosDialog {
//         id: confirm
//         title: qsTr("Remove repository?")
//         message: qsTr("You can add it again later.")
//         preferredWidth: 420
//         body: LogosCheckbox { text: qsTr("Also remove its packages") }
//         leftActions: [ LogosButton { text: qsTr("Cancel"); onClicked: confirm.close() } ]
//         rightActions: [ LogosButton { text: qsTr("Remove"); onClicked: confirm.accept() } ]
//     }
Dialog {
    id: root

    property color borderColor: Theme.palette.border
    property color backgroundColor: Theme.palette.backgroundSecondary
    property string message: ""
    property Item body: null
    property real preferredWidth: implicitWidth
    property bool fullPage: false
    readonly property bool sheet: d.phone && !fullPage
    readonly property bool dragToClose: sheet && (closePolicy & Popup.CloseOnPressOutside) !== 0

    property list<Item> leftActions
    property list<Item> rightActions

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias backgroundItem: bg
    readonly property alias headerItem:     titleLabel
    readonly property alias footerItem:     footerWrap
    readonly property alias messageItem:    messageText
    readonly property alias handleItem:     handle
    readonly property alias dragAreaItem:   dragArea
    readonly property alias closeButtonItem: closeButton
    readonly property alias scrollViewItem: scroller

    QtObject {
        id: d

        // A dialog the app centres goes by its window, whatever it is centred
        // on; one that places itself, by its parent.
        readonly property Item host: root.anchors.centerIn || centredOn ? root.Overlay.overlay : root.parent
        // "parent" or "overlay", the two a popup centres in; "" if it isn't.
        property string centredOn: ""
        // Decided while it shows: an app may still be placing it until then.
        property bool showing: false
        readonly property bool phone: showing && host !== null && Theme.windowClass(host.width) === "phone"
        readonly property real hostHeight: host ? host.height : 0
        // The host's corner in the parent's coordinates, where x and y are.
        readonly property point origin: phone && root.parent && host !== root.parent
                                        && host.width + host.height + root.parent.width >= 0
                                        ? root.parent.mapFromItem(host, 0, 0) : Qt.point(0, 0)
        readonly property bool page: phone && root.fullPage
        readonly property bool hasActions: root.leftActions.length > 0 || root.rightActions.length > 0
        // On a phone: lifted above the keyboard, padded over the safe area.
        readonly property real keyboard: phone ? Theme.keyboardInset(host) : 0
        readonly property real safeArea: phone ? Math.max(0, Theme.bottomInset(host) - keyboard) : 0
        readonly property real notch: page ? Theme.topInset(host) : 0
        onKeyboardChanged: reveal()

        function reveal() {
            if (phone && host && host.Window.window)
                Theme.scrollIntoView(host.Window.window.activeFocusItem, scroller)
        }
        readonly property real margin: root.parent ? Theme.pageMargin(root.parent.width) : 0
        property real offset: 0
        property Item shownBody: null

        readonly property Transition slideIn: Transition {
            NumberAnimation { target: d; property: "offset"; from: root.height; to: 0; duration: 200; easing.type: Easing.OutCubic }
        }
        readonly property Transition slideOut: Transition {
            NumberAnimation { target: d; property: "offset"; to: root.height; duration: 150; easing.type: Easing.InCubic }
        }

        readonly property var stacked: {
            const items = []
            for (let i = 0; i < root.leftActions.length; ++i)
                items.push(root.leftActions[i])
            for (let i = 0; i < root.rightActions.length; ++i)
                items.push(root.rightActions[i])
            return items
        }

        onStackedChanged: {
            for (let i = 0; i < stacked.length; ++i)
                stacked[i].Layout.fillWidth = true
        }

        // A Binding wouldn't give the anchor back, so it is set again, live.
        onPhoneChanged: {
            if (phone) {
                root.anchors.centerIn = undefined
            } else {
                if (centredOn === "parent")
                    root.anchors.centerIn = Qt.binding(() => root.parent)
                else if (centredOn === "overlay")
                    root.anchors.centerIn = Qt.binding(() => root.Overlay.overlay)
                Qt.callLater(unstack)
            }
        }

        // The stack's layout sized and placed them; a Row sets only x, and keeps
        // the size and y it finds.
        function unstack() {
            for (let i = 0; i < stacked.length; ++i) {
                stacked[i].width = undefined
                stacked[i].height = undefined
                stacked[i].y = 0
            }
        }
    }

    modal: true
    padding: Theme.spacing.large

    x: !parent ? 0 : (parent.width - width) / 2
    y: !parent ? 0 : (parent.height - height) / 2
    width: !parent ? preferredWidth : Math.min(preferredWidth, parent.width - 2 * d.margin)
    height: !parent || anchors.centerIn ? implicitHeight
          : Math.min(implicitHeight, parent.height - 2 * d.margin)

    // On a phone the sheet or the page places it, over the app's own centring
    // and size; they come back when it closes or the host widens.
    Binding { target: root; property: "x"; value: d.origin.x; when: d.phone }
    Binding {
        target: root; property: "y"; when: d.phone
        value: d.origin.y + (d.page ? d.offset : d.hostHeight - d.keyboard - root.height + d.offset)
    }
    Binding { target: root; property: "width"; value: d.host ? d.host.width : 0; when: d.phone }
    Binding {
        target: root; property: "height"; when: d.phone
        value: d.page ? d.hostHeight - d.keyboard
                      : Math.min(root.implicitHeight, d.hostHeight - d.keyboard - Theme.controls.dialog.sheetTopGap)
    }
    Connections {
        target: d.phone && d.host ? d.host.Window.window : null
        function onActiveFocusItemChanged() { d.reveal() }
    }
    onAboutToShow: {
        d.centredOn = !anchors.centerIn ? "" : anchors.centerIn === parent ? "parent" : "overlay"
        d.showing = true
    }

    // Not a disabled Transition: a popup runs it anyway, and opened and
    // closed would come 200 ms late.
    enter: d.phone ? d.slideIn : null
    exit: d.phone ? d.slideOut : null

    onClosed: {
        d.showing = false
        d.offset = 0
    }
    // A body it no longer shows is taken out.
    onBodyChanged: {
        if (d.shownBody && d.shownBody !== body)
            d.shownBody.parent = null
        d.shownBody = body
        if (!body)
            return
        body.parent = bodyColumn
        body.Layout.fillWidth = true
    }

    Overlay.modal: Rectangle {
        objectName: "modalScrim"
        color: Theme.palette.scrim

        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    background: Rectangle {
        id: bg
        color: root.backgroundColor
        border.color: root.borderColor
        border.width: d.page ? 0 : Theme.size.borderWidth
        radius: root.sheet ? Theme.spacing.radiusXlarge : d.page ? 0 : Theme.spacing.radiusLarge
        // Only for a sheet: setting any corner's radius redraws the whole border.
        Binding on bottomLeftRadius { when: root.sheet; value: 0 }
        Binding on bottomRightRadius { when: root.sheet; value: 0 }

        Rectangle {
            id: handle
            visible: root.dragToClose
            anchors.horizontalCenter: parent.horizontalCenter
            y: Theme.spacing.small
            width: Theme.controls.dialog.handleWidth
            height: Theme.controls.dialog.handleHeight
            radius: height / 2
            color: Theme.palette.borderStrong
        }

        // The handle and the title drag it, not the body: a swipe there scrolls.
        Item {
            id: dragArea
            anchors.left: parent.left
            anchors.right: parent.right
            height: Math.max(Theme.size.touchTarget, root.header ? root.header.height : 0)

            // Scene positions, so moving the sheet doesn't move the measure.
            DragHandler {
                enabled: root.dragToClose
                target: null
                xAxis.enabled: false
                onCentroidChanged: if (active)
                    d.offset = Math.max(0, centroid.scenePosition.y - centroid.scenePressPosition.y)
                onActiveChanged: {
                    if (active || !root.sheet)
                        return
                    if (d.offset > root.height / 4)
                        root.reject()
                    else
                        snapBack.start()
                }
            }
        }

        NumberAnimation { id: snapBack; target: d; property: "offset"; to: 0; duration: 150; easing.type: Easing.OutCubic }

        Rectangle {
            visible: d.page
            y: root.header ? root.header.height : 0
            width: parent.width
            height: Theme.size.borderWidth
            color: Theme.palette.borderSubtle
        }

        LogosIconButton {
            id: closeButton
            visible: d.page && (root.closePolicy & Popup.CloseOnEscape) !== 0
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacing.tiny
            y: d.notch + (root.header ? Math.max(0, (root.header.height - d.notch - height) / 2) : 0)
            size: Theme.size.touchTarget
            flat: true
            iconSource: LogosIcons.close
            Accessible.name: qsTr("Close")
            onClicked: root.reject()
        }
    }

    header: LogosText {
        id: titleLabel
        text: root.title
        color: Theme.palette.text
        font.pixelSize: Theme.typography.primaryText
        font.weight: Theme.typography.weightBold
        leftPadding: Theme.spacing.large
        topPadding: d.notch + (root.dragToClose ? Theme.spacing.large + Theme.spacing.small : Theme.spacing.large)
        rightPadding: closeButton.visible ? closeButton.width + Theme.spacing.tiny : Theme.spacing.large
        bottomPadding: Theme.spacing.small
        visible: root.title.length > 0
    }

    contentItem: LogosScrollView {
        id: scroller
        implicitWidth: bodyColumn.implicitWidth
        implicitHeight: bodyColumn.implicitHeight + bottomPadding
        // Clear of the safe area; with buttons, the footer is.
        bottomPadding: d.hasActions ? 0 : d.safeArea

        ColumnLayout {
            id: bodyColumn
            width: scroller.availableWidth
            spacing: Theme.spacing.medium

            LogosText {
                id: messageText
                Layout.fillWidth: true
                visible: root.message.length > 0
                text: root.message
                color: Theme.palette.textSecondary
                font.pixelSize: Theme.typography.secondaryText
                wrapMode: Text.WordWrap
            }
        }
    }

    footer: Rectangle {
        id: footerWrap
        color: "transparent"
        visible: root.leftActions.length > 0 || root.rightActions.length > 0
        implicitHeight: visible
                        ? (d.phone ? stack.implicitHeight : footerLayout.implicitHeight)
                          + Theme.spacing.medium + Theme.spacing.large + d.safeArea
                        : 0

        RowLayout {
            id: footerLayout
            visible: !d.phone
            anchors.fill: parent
            anchors.leftMargin: Theme.spacing.large
            anchors.rightMargin: Theme.spacing.large
            anchors.topMargin: Theme.spacing.medium
            anchors.bottomMargin: Theme.spacing.large
            spacing: Theme.spacing.small

            Row {
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                spacing: Theme.spacing.small
                children: d.phone ? [] : root.leftActions
            }

            Item { Layout.fillWidth: true }

            Row {
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                spacing: Theme.spacing.small
                children: d.phone ? [] : root.rightActions
            }
        }

        ColumnLayout {
            id: stack
            visible: d.phone
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: Theme.spacing.large
            anchors.rightMargin: Theme.spacing.large
            anchors.topMargin: Theme.spacing.medium
            spacing: Theme.spacing.small
            children: d.phone ? d.stacked : []
        }
    }
}
