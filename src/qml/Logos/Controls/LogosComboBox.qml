import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Window

import Logos.Theme
import Logos.Controls
import Logos.Icons


// Public API (in addition to ComboBox's own model / currentIndex / currentText
// / displayText / textRole / activated() / accepted()):
//     placeholderText  shown in the closed control when no selection yet
//                      (i.e. currentIndex === -1 or displayText is empty)
//     textColor        color of the selected/displayed value (default = textPrimary)
//                      placeholderText keeps its own muted color
//     indicatorColor   color of the chevron (default = same as textColor when enabled)
//
// Read-only inspection aliases:
//     contentLabel     the LogosText rendered in the closed control
//     backgroundItem   the Rectangle drawn behind the closed control
//     popupItem        the dropdown Popup
//     popupListView    the ListView inside the popup (delegate model is owned
//                      by ComboBox via root.delegateModel)
//     popupHandleItem, popupDragAreaItem   the sheet's handle and the strip
//                      that drags it
//
// The closed control keeps whatever width it is given; the dropdown widens to
// fit its widest entry, up to maxPopupWidthFactor times the control and never
// past the width of the window, and is kept inside the window when the control
// sits near an edge. It is as tall as its rows up to the height of the window,
// and scrolls past that.
//
// In a phone-wide window the list opens as a sheet across the bottom
// instead, as LogosMenu's does: the page dims, the entries span the width, and
// a tap on the page or a drag down on the handle closes it. `sheet` says when
// it is open as one.
//
// Example:
//     LogosComboBox {
//         model: ["alpha", "beta", "gamma"]
//         currentIndex: 0
//         onActivated: function(index) { console.log("picked", index) }
//     }
ComboBox {
    id: root

    property string placeholderText: ""
    property color textColor: Theme.palette.text
    property color indicatorColor: textColor
    // How far the dropdown may outgrow the control to fit its entries.
    property real maxPopupWidthFactor: 3
    // Horizontal inset of a dropdown entry; also what the width allows for.
    readonly property real entryPadding: Theme.spacing.medium

    readonly property bool sheet: sheetState.active

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias contentLabel: contentText
    readonly property alias backgroundItem: bg
    readonly property alias popupItem: dropdownPopup
    readonly property alias popupListView: popupList
    readonly property alias popupHandleItem: handle
    readonly property alias popupDragAreaItem: dragArea

    // The list as a sheet across the bottom of a phone-wide window.
    QtObject {
        id: sheetState

        readonly property Item overlay: dropdownPopup.Overlay.overlay
        readonly property bool phone: overlay !== null && Theme.windowClass(overlay.width) === "phone"
        // Decided as it opens, where the window is phone-wide.
        property bool active: false
        // Placed against the window's overlay, which goes when the box leaves
        // the window, as a list's row does.
        readonly property bool placed: active && overlay !== null
        // Where the window's top left is, in the control.
        property point origin: Qt.point(0, 0)
        // How far a drag on the handle has pulled it down.
        property real offset: 0

        readonly property Transition slideIn: Transition {
            NumberAnimation { target: sheetState; property: "offset"; from: dropdownPopup.height; to: 0; duration: 200; easing.type: Easing.OutCubic }
        }
        readonly property Transition slideOut: Transition {
            NumberAnimation { target: sheetState; property: "offset"; to: dropdownPopup.height; duration: 150; easing.type: Easing.InCubic }
        }
    }

    QtObject {
        id: d

        // Bumped when a row's text changes in place, by the Connections below.
        property int entryRevision: 0

        // textAt() notifies nothing, so every read of it is paired with reads
        // of what it does depend on: the model it indexes, the role it picks
        // out of a row, and entryRevision for a row edited in place.
        function entryText(index) {
            void d.entryRevision
            void root.model
            void root.textRole
            return root.textAt(index) || ""
        }

        // Widest of the probes below, in whole pixels.
        readonly property real widestEntryWidth: {
            var widest = 0
            for (var i = 0; i < entryProbes.count; ++i) {
                var probe = entryProbes.itemAt(i)
                if (probe)
                    widest = Math.max(widest, probe.implicitWidth)
            }
            return Math.ceil(widest)
        }
    }

    component EntryText: LogosText {
        font.pixelSize: Theme.typography.secondaryText
    }

    // A hidden copy of every entry, laid out but never drawn, is what sizes the
    // dropdown
    Repeater {
        id: entryProbes

        model: dropdownPopup.visible && root.model ? root.count : 0

        EntryText {
            required property int index

            visible: false
            text: d.entryText(index)
        }
    }

    Connections {
        target: (root.model && root.model.dataChanged !== undefined) ? root.model : null
        ignoreUnknownSignals: true
        function onDataChanged() { d.entryRevision += 1 }
    }

    implicitHeight: Theme.controls.combo.height

    focusPolicy: Qt.StrongFocus
    activeFocusOnTab: true

    contentItem: LogosText {
        id: contentText

        leftPadding: Theme.controls.combo.paddingX
        rightPadding: (root.indicator ? root.indicator.width : Theme.controls.combo.indicatorSize) + Theme.controls.combo.paddingX
        text: root.displayText.length > 0 ? root.displayText : root.placeholderText
        font.pixelSize: Theme.typography.secondaryText
        color: !root.enabled
               ? Theme.palette.textMuted
               : (root.displayText.length > 0
                  ? root.textColor
                  : Theme.palette.textTertiary)
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    indicator: Item {
        id: chevronHolder

        width: Theme.controls.combo.indicatorSize
        height: Theme.controls.combo.indicatorSize
        x: root.width - width - root.rightPadding
        y: root.topPadding + (root.availableHeight - height) / 2
        rotation: 90

        Image {
            id: chevronImg
            anchors.fill: parent
            source: LogosIcons.arrowRight
            sourceSize: Qt.size(parent.width * 2, parent.height * 2)
            fillMode: Image.PreserveAspectFit
            visible: false
        }
        MultiEffect {
            anchors.fill: chevronImg
            source: chevronImg
            colorization: 1.0
            colorizationColor: root.enabled
                               ? root.indicatorColor
                               : Theme.palette.textMuted
        }
    }

    background: Rectangle {
        id: bg

        color: root.enabled
               ? (root.pressed ? Theme.palette.pressed : Theme.palette.backgroundButton)
               : Theme.palette.backgroundSecondary
        radius: Theme.spacing.radiusSmall
        border.color: root.visualFocus ? Theme.palette.overlayOrange
                     : (root.enabled ? Theme.palette.border : Theme.palette.borderSubtle)
        border.width: Theme.size.borderWidth
    }

    popup: Popup {
        id: dropdownPopup

        x: sheetState.placed ? sheetState.origin.x : 0
        y: sheetState.placed ? sheetState.origin.y + sheetState.overlay.height - height + sheetState.offset
                             : root.height + Theme.controls.combo.popupGap
        width: {
            if (sheetState.placed)
                return sheetState.overlay.width
            var wanted = Math.max(root.width,
                                  Math.min(implicitWidth, root.width * root.maxPopupWidthFactor))
            return root.Window.window
                   ? Math.min(wanted, root.Window.width - leftMargin - rightMargin)
                   : wanted
        }
        implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
        height: sheetState.placed
                ? Math.min(implicitHeight, sheetState.overlay.height - Theme.controls.dialog.sheetTopGap)
                : root.Window.window
                  ? Math.min(implicitHeight, root.Window.height - topMargin - bottomMargin)
                  : implicitHeight
        padding: Theme.size.borderWidth
        // As a sheet: a strip for the handle above the entries, a fingertip tall.
        topPadding: sheetState.active ? Theme.size.touchTarget : padding
        bottomPadding: sheetState.active ? Theme.spacing.large + Theme.bottomInset(sheetState.overlay) : padding
        // Kept inside the window, a sheet couldn't slide in or follow a drag.
        margins: sheetState.active ? -1 : Theme.spacing.small
        modal: sheetState.phone

        // Not a disabled Transition, which a popup runs anyway.
        enter: sheetState.active ? sheetState.slideIn : null
        exit: sheetState.active ? sheetState.slideOut : null

        onAboutToShow: {
            sheetState.active = sheetState.phone
            if (sheetState.active)
                sheetState.origin = root.mapFromItem(sheetState.overlay, 0, 0)
        }
        onClosed: {
            sheetState.active = false
            sheetState.offset = 0
        }

        Overlay.modal: Rectangle {
            color: Theme.palette.scrim
        }

        contentItem: ListView {
            id: popupList

            clip: true
            implicitWidth: d.widestEntryWidth + 2 * root.entryPadding
            implicitHeight: contentHeight
            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex
            highlightRangeMode: ListView.ApplyRange
            highlightMoveDuration: 0
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: LogosScrollBar {
                policy: ScrollBar.AsNeeded
                visible: popupList.contentHeight > popupList.height
                rightPadding: Theme.spacing.tiny
            }
        }

        background: Rectangle {
            color: Theme.palette.backgroundSecondary
            border.color: Theme.palette.border
            radius: sheetState.active ? Theme.spacing.radiusXlarge : Theme.spacing.radiusSmall
            // Only for a sheet: setting any corner's radius redraws the whole border.
            Binding on bottomLeftRadius { when: sheetState.active; value: 0 }
            Binding on bottomRightRadius { when: sheetState.active; value: 0 }

            Rectangle {
                id: handle
                visible: sheetState.active
                anchors.horizontalCenter: parent.horizontalCenter
                y: Theme.spacing.small
                width: Theme.controls.dialog.handleWidth
                height: Theme.controls.dialog.handleHeight
                radius: height / 2
                color: Theme.palette.borderStrong
            }

            // Only the handle's strip drags it: a swipe on the entries scrolls them.
            Item {
                id: dragArea
                anchors.left: parent.left
                anchors.right: parent.right
                height: dropdownPopup.topPadding

                // Scene positions, so moving the sheet doesn't move the measure.
                DragHandler {
                    enabled: sheetState.active
                    target: null
                    xAxis.enabled: false
                    onCentroidChanged: if (active)
                        sheetState.offset = Math.max(0, centroid.scenePosition.y - centroid.scenePressPosition.y)
                    onActiveChanged: {
                        if (active || !sheetState.active)
                            return
                        if (sheetState.offset > dropdownPopup.height / 4)
                            dropdownPopup.close()
                        else
                            snapBack.start()
                    }
                }
            }

            NumberAnimation { id: snapBack; target: sheetState; property: "offset"; to: 0; duration: 150; easing.type: Easing.OutCubic }
        }
    }

    delegate: ItemDelegate {
        id: comboItem
        width: ListView.view ? ListView.view.width : root.width
        leftPadding: root.entryPadding
        rightPadding: root.entryPadding
        highlighted: root.highlightedIndex === index
        implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                                 implicitContentHeight + topPadding + bottomPadding,
                                 implicitIndicatorHeight + topPadding + bottomPadding,
                                 Theme.touch ? Theme.size.touchTarget : 0)

        contentItem: EntryText {
            text: d.entryText(index)
            color: Theme.palette.text
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        background: Rectangle {
            color: parent.highlighted ? Theme.palette.surface : "transparent"
        }

        HoverHandler {
            cursorShape: comboItem.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
    }

    HoverHandler {
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
}
