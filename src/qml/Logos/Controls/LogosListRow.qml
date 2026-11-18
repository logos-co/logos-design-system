import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Icons
import Logos.Controls

// LogosListRow — a row in a list or in grouped settings:
//     [icon]  Title                     value  ›
//             subtitle
// The whole row is the tap target. For on/off settings put a control on the
// right with `accessory` (a LogosSwitch); a tap anywhere on the row toggles
// it. A chevron says the row goes somewhere; `selected` marks the row whose
// detail is open beside the list.
//
// Public API:
//     title, subtitle, value     text; value is the current setting, right-aligned
//     subtitleWraps              let the subtitle wrap instead of eliding
//     iconSource                 a leading icon
//     showChevron                a trailing ›
//     showSeparator              a hairline under the row (default true)
//     destructive                title and icon in the error colour
//     selected                   the open row in list → detail
//     accessory                  an item on the right, e.g. a LogosSwitch
//     clicked()                  a tap or click on the row
//
// Read-only inspection aliases: titleItem, subtitleItem, valueItem,
// chevronItem, backgroundItem.
//
// Example:
//     LogosListRow { title: qsTr("Network"); value: qsTr("Testnet"); showChevron: true; onClicked: openNetwork() }
//     LogosListRow { title: qsTr("Notifications"); accessory: LogosSwitch { checked: true } }
AbstractButton {
    id: root

    property string title: ""
    property string subtitle: ""
    property bool subtitleWraps: false
    property string value: ""
    property url iconSource: ""
    property bool showChevron: false
    property bool showSeparator: true
    property bool destructive: false
    property bool selected: false
    property Item accessory: null

    readonly property alias titleItem: titleText
    readonly property alias subtitleItem: subtitleText
    readonly property alias valueItem: valueText
    readonly property alias chevronItem: chevron
    readonly property alias backgroundItem: bg

    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    implicitHeight: Math.max(subtitle !== "" ? Theme.controls.listRow.subtitleHeight : Theme.controls.listRow.height,
                             implicitContentHeight + topPadding + bottomPadding)
    leftPadding: Theme.controls.listRow.paddingX
    rightPadding: Theme.spacing.medium
    topPadding: Theme.spacing.tiny
    bottomPadding: Theme.spacing.tiny

    Accessible.name: title
    Accessible.description: subtitle

    // A tap on the row toggles the accessory. toggle() doesn't emit toggled()
    // (that is for the user's own taps), so emit it: an app's onToggled must
    // run whichever the user tapped.
    onClicked: {
        if (accessory && accessory.toggle !== undefined) {
            accessory.toggle()
            if (accessory.toggled !== undefined)
                accessory.toggled()
        }
    }

    onAccessoryChanged: if (accessory) accessory.parent = accessorySlot

    background: Rectangle {
        id: bg
        color: root.pressed ? Theme.palette.pressed
             : root.selected ? Theme.colors.getColor(Theme.palette.primary, 0.18)
             : root.hovered || root.visualFocus ? Theme.palette.hover
             : "transparent"

        Rectangle {
            visible: root.showSeparator
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: root.leftPadding
            height: Theme.size.borderWidth
            color: Theme.palette.borderSubtle
        }
    }

    contentItem: RowLayout {
        spacing: Theme.spacing.medium

        LogosIcon {
            visible: root.iconSource.toString() !== ""
            source: root.iconSource
            color: root.destructive ? Theme.palette.error : Theme.palette.textSecondary
            Layout.preferredWidth: Theme.controls.listRow.iconSize
            Layout.preferredHeight: Theme.controls.listRow.iconSize
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.tiny / 2

            LogosText {
                id: titleText
                Layout.fillWidth: true
                text: root.title
                elide: Text.ElideRight
                color: root.destructive ? Theme.palette.error : Theme.palette.text
            }
            LogosText {
                id: subtitleText
                Layout.fillWidth: true
                visible: root.subtitle !== ""
                text: root.subtitle
                elide: root.subtitleWraps ? Text.ElideNone : Text.ElideRight
                wrapMode: root.subtitleWraps ? Text.Wrap : Text.NoWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        LogosText {
            id: valueText
            visible: root.value !== ""
            Layout.maximumWidth: root.width * 0.4
            text: root.value
            elide: Text.ElideRight
            color: Theme.palette.textSecondary
        }

        Item {
            id: accessorySlot
            visible: root.accessory !== null
            implicitWidth: root.accessory ? root.accessory.implicitWidth : 0
            implicitHeight: root.accessory ? root.accessory.implicitHeight : 0
        }

        LogosIcon {
            id: chevron
            visible: root.showChevron
            source: LogosIcons.arrowRight
            color: Theme.palette.textSecondary
            Layout.preferredWidth: Theme.controls.listRow.iconSize
            Layout.preferredHeight: Theme.controls.listRow.iconSize
        }
    }

    LongPressToolTips {
        control: root
    }
}
