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
//
// The closed control keeps whatever width it is given; the dropdown widens to
// fit its widest entry, up to maxPopupWidthFactor times the control and never
// past the width of the window, and is kept inside the window when the control
// sits near an edge. It is as tall as its rows up to the height of the window,
// and scrolls past that.
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

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias contentLabel: contentText
    readonly property alias backgroundItem: bg
    readonly property alias popupItem: dropdownPopup
    readonly property alias popupListView: popupList

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

    implicitHeight: 32

    focusPolicy: Qt.StrongFocus
    activeFocusOnTab: true

    contentItem: LogosText {
        id: contentText

        leftPadding: Theme.spacing.medium - 2
        rightPadding: root.indicator ? root.indicator.width + Theme.spacing.medium - 2 : 30
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

        width: 20
        height: 20
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
        border.width: 1
    }

    popup: Popup {
        id: dropdownPopup

        y: root.height + 2
        width: {
            var wanted = Math.max(root.width,
                                  Math.min(implicitWidth, root.width * root.maxPopupWidthFactor))
            return root.Window.window
                   ? Math.min(wanted, root.Window.width - leftMargin - rightMargin)
                   : wanted
        }
        implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
        height: root.Window.window
                ? Math.min(implicitHeight, root.Window.height - topMargin - bottomMargin)
                : implicitHeight
        padding: 1
        margins: Theme.spacing.small

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
            radius: Theme.spacing.radiusSmall
        }
    }

    delegate: ItemDelegate {
        id: comboItem
        width: ListView.view ? ListView.view.width : root.width
        leftPadding: root.entryPadding
        rightPadding: root.entryPadding
        highlighted: root.highlightedIndex === index

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
