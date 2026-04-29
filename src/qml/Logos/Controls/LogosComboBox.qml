import QtQuick
import QtQuick.Controls
import QtQuick.Effects

import Logos.Theme
import Logos.Controls


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

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias contentLabel: contentText
    readonly property alias backgroundItem: bg
    readonly property alias popupItem: dropdownPopup
    readonly property alias popupListView: popupList

    implicitHeight: 32

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
            source: Qt.resolvedUrl("icons/arrow-right-s-line.svg")
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
        border.color: root.enabled ? Theme.palette.border : Theme.palette.borderSubtle
        border.width: 1
    }

    popup: Popup {
        id: dropdownPopup

        y: root.height + 2
        width: root.width
        implicitHeight: contentItem.implicitHeight
        padding: 1

        contentItem: ListView {
            id: popupList

            clip: true
            implicitHeight: contentHeight
            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex
        }

        background: Rectangle {
            color: Theme.palette.backgroundSecondary
            border.color: Theme.palette.border
            radius: Theme.spacing.radiusSmall
        }
    }

    delegate: ItemDelegate {
        width: root.width
        highlighted: root.highlightedIndex === index

        contentItem: LogosText {
            text: root.textAt(index)
            color: Theme.palette.text
            font.pixelSize: Theme.typography.secondaryText
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        background: Rectangle {
            color: parent.highlighted ? Theme.palette.surface : "transparent"
        }
    }
}
