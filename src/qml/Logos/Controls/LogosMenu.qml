import QtQuick
import QtQuick.Controls

import Logos.Theme

// LogosMenu — themed Menu.
//
// In a phone-wide window it opens as a sheet across the bottom instead,
// however it was opened: the page dims, the items span the width, and a tap
// on the page or a drag down on the handle closes it.
//
// Public API (plus Menu's own count / items / open / close / popup):
//     borderColor / backgroundColor
//     popupUnder(anchor)  Open under anchor with a Theme.spacing.tiny (4px)
//                         gap below the control. Use this for button/toolbar
//                         menus so keyboard Space/Enter does not place the
//                         menu at the mouse cursor.
//     contextFor          the item it is the context menu of: a right-click
//                         on it opens the menu there, and a long press (the
//                         touch path) opens it at the item
//     sheet               read-only; it is open as a sheet
//
// Read-only inspection aliases:
//     backgroundItem, handleItem, dragAreaItem
Menu {
    id: root

    property color borderColor: Theme.palette.border
    property color backgroundColor: Theme.palette.backgroundSecondary
    readonly property bool sheet: d.sheet
    property Item contextFor: null

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias backgroundItem: bg
    readonly property alias handleItem: handle
    readonly property alias dragAreaItem: dragArea

    // Opens below the anchor with a tiny gap. Prefer over bare popup() when
    // the menu is triggered from a control (mouse or keyboard).
    function popupUnder(anchor) {
        const a = anchor ? anchor : root.parent
        if (!a) {
            root.popup()
            return
        }
        root.popup(a, 0, a.height + Theme.spacing.tiny)
    }

    // A long press: the pressAndHold of whatever takes the item's presses (a
    // Logos button's mouse area, a button, a mouse area), which a handler
    // beside it wouldn't get; otherwise the context area's handler.
    Connections {
        target: d.holdSource
        function onPressAndHold() { root.popupUnder(root.contextFor) }
    }

    // Made on contextFor, not declared here: a pointer handler declared in a
    // popup and bound to another item crashes Qt on macOS
    // (QQuickPointerHandler::setParentItem, in QQuickPopupPrivate::blockInput).
    Component {
        id: contextAreaComponent
        Item {
            id: area
            required property LogosMenu menu
            // The item has no pressAndHold of its own to open it.
            required property bool longPressHere
            anchors.fill: parent

            TapHandler {
                acceptedButtons: Qt.RightButton
                onTapped: point => area.menu.popup(area.parent, point.position.x, point.position.y)
            }
            TapHandler {
                id: longPress
                enabled: area.longPressHere
                onLongPressed: area.menu.popup(area.parent, longPress.point.position.x, longPress.point.position.y)
            }
        }
    }
    onContextForChanged: d.attachContextArea()
    Component.onCompleted: d.attachContextArea()
    Component.onDestruction: if (d.contextArea) d.contextArea.destroy()

    QtObject {
        id: d

        readonly property Item overlay: root.Overlay.overlay
        property Item contextArea: null

        function attachContextArea() {
            if (contextArea)
                contextArea.destroy()
            contextArea = root.contextFor ? contextAreaComponent.createObject(root.contextFor, { menu: root, longPressHere: holdSource === null })
                                       : null
        }

        readonly property Item holdSource: {
            const item = root.contextFor
            if (!item)
                return null
            if ("mouseAreaItem" in item && item.mouseAreaItem)
                return item.mouseAreaItem
            return "pressAndHold" in item ? item : null
        }
        readonly property bool phone: overlay !== null && Theme.windowClass(overlay.width) === "phone"
        property bool sheet: false
        property real offset: 0

        readonly property Transition slideIn: Transition {
            NumberAnimation { target: d; property: "offset"; from: root.height; to: 0; duration: 200; easing.type: Easing.OutCubic }
        }
        readonly property Transition slideOut: Transition {
            NumberAnimation { target: d; property: "offset"; to: root.height; duration: 150; easing.type: Easing.InCubic }
        }

        // Wherever popup() put it, across the bottom of the window. Bound:
        // its items may not have their height yet. The window's overlay goes
        // when the item the menu is in leaves the window, as a list's row does.
        function place() {
            sheet = phone && root.parent !== null
            if (!sheet)
                return
            const origin = root.parent.mapFromItem(overlay, 0, 0)
            root.width = Qt.binding(() => d.overlay ? d.overlay.width : root.implicitWidth)
            root.height = Qt.binding(() => d.overlay ? Math.min(root.implicitHeight, d.overlay.height - Theme.controls.dialog.sheetTopGap)
                                                     : root.implicitHeight)
            root.x = origin.x
            root.y = Qt.binding(() => d.overlay ? origin.y + d.overlay.height - root.height + d.offset : 0)
        }

        function unplace() {
            if (!sheet)
                return
            sheet = false
            offset = 0
            root.width = undefined
            root.height = undefined
            root.y = root.y
        }
    }

    padding: Theme.spacing.tiny
    // As a sheet: a strip for the handle above the items, a fingertip tall.
    topPadding: d.sheet ? Theme.size.touchTarget : padding
    bottomPadding: d.sheet ? Theme.spacing.large + Theme.bottomInset(d.overlay) : padding
    modal: d.phone
    // Kept inside the window, it couldn't slide in or follow a drag.
    margins: d.sheet ? -1 : 0

    // Not a disabled Transition, which a popup runs anyway: as a dialog's.
    enter: d.sheet ? d.slideIn : null
    exit: d.sheet ? d.slideOut : null

    onAboutToShow: d.place()
    onClosed: d.unplace()

    Overlay.modal: Rectangle {
        color: Theme.palette.scrim
    }

    background: Rectangle {
        id: bg
        implicitWidth: Theme.controls.menu.width
        color: root.backgroundColor
        border.color: root.borderColor
        radius: d.sheet ? Theme.spacing.radiusXlarge : Theme.spacing.radiusSmall
        // Only for a sheet: setting any corner's radius redraws the whole border.
        Binding on bottomLeftRadius { when: d.sheet; value: 0 }
        Binding on bottomRightRadius { when: d.sheet; value: 0 }

        Rectangle {
            id: handle
            visible: d.sheet
            anchors.horizontalCenter: parent.horizontalCenter
            y: Theme.spacing.small
            width: Theme.controls.dialog.handleWidth
            height: Theme.controls.dialog.handleHeight
            radius: height / 2
            color: Theme.palette.borderStrong
        }

        // Only the handle's strip drags it: a swipe on the items scrolls them.
        Item {
            id: dragArea
            anchors.left: parent.left
            anchors.right: parent.right
            height: root.topPadding

            // Scene positions, so moving the sheet doesn't move the measure.
            DragHandler {
                enabled: d.sheet
                target: null
                xAxis.enabled: false
                onCentroidChanged: if (active)
                    d.offset = Math.max(0, centroid.scenePosition.y - centroid.scenePressPosition.y)
                onActiveChanged: {
                    if (active || !d.sheet)
                        return
                    if (d.offset > root.height / 4)
                        root.close()
                    else
                        snapBack.start()
                }
            }
        }

        NumberAnimation { id: snapBack; target: d; property: "offset"; to: 0; duration: 150; easing.type: Easing.OutCubic }
    }
}
