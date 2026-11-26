import QtQuick
import QtQuick.Layouts
// Its AbstractButton is the base of every style's switch and checkbox; the
// QtQuick.Controls name doesn't match them in a type check.
import QtQuick.Templates as T

import Logos.Theme
import Logos.Icons
import Logos.Controls

// LogosListRow — a row in a list or in grouped settings:
//     [icon]  Title                     value  ⋯  ›
//             subtitle
//             caption
// The whole row is the tap target. For on/off settings put a control on the
// right with `accessory` (a LogosSwitch); a tap anywhere on the row toggles
// it. A chevron says the row goes somewhere; `selected` marks the row whose
// detail is open beside the list. A row with a `menu` shows ⋯ for it, which a
// long press or a right-click on the row opens too.
//
// Public API:
//     title, subtitle, value     text; value is the current setting, right-aligned
//     subtitleWraps              let the subtitle wrap instead of eliding
//     caption                    a third line, e.g. an inbox row's preview
//     iconSource                 a leading icon
//     showChevron                a trailing ›
//     showSeparator              a hairline under the row (default true)
//     destructive                title and icon in the error colour
//     selected                   the open row in list → detail
//     accessory                  an item on the right, e.g. a LogosSwitch
//     menu                       the row's actions, a LogosMenu
//     clicked()                  a tap or click on the row
//
// Read-only inspection aliases: titleItem, subtitleItem, captionItem,
// valueItem, menuButtonItem, chevronItem, backgroundItem, separatorItem.
//
// Example:
//     LogosListRow { title: qsTr("Network"); value: qsTr("Testnet"); showChevron: true; onClicked: openNetwork() }
//     LogosListRow { title: qsTr("Notifications"); accessory: LogosSwitch { checked: true } }
LogosAbstractButton {
    id: root

    property string title: ""
    property string subtitle: ""
    property string caption: ""
    property bool subtitleWraps: false
    property string value: ""
    property url iconSource: ""
    property bool showChevron: false
    property bool showSeparator: true
    property bool destructive: false
    property bool selected: false
    property Item accessory: null
    property LogosMenu menu: null

    readonly property alias titleItem: titleText
    readonly property alias subtitleItem: subtitleText
    readonly property alias captionItem: captionText
    readonly property alias menuButtonItem: menuButton
    readonly property alias valueItem: valueText
    readonly property alias chevronItem: chevron
    readonly property alias backgroundItem: bg
    readonly property alias separatorItem: separator

    QtObject {
        id: d
        readonly property bool hasIcon: root.iconSource.toString() !== ""
    }

    implicitHeight: Math.max(subtitle !== "" ? Theme.controls.listRow.subtitleHeight : Theme.controls.listRow.height,
                             implicitContentHeight + topPadding + bottomPadding)
    leftPadding: Theme.controls.listRow.paddingX
    rightPadding: Theme.spacing.medium
    topPadding: Theme.spacing.tiny
    bottomPadding: Theme.spacing.tiny

    Accessible.name: title
    Accessible.description: [subtitle, caption].filter(text => text !== "").join(", ")

    // Not click(): it needs Qt 6.8, and the Windows build uses Qt 6.7.
    onClicked: {
        const button = root.accessory as T.AbstractButton
        if (!button || !button.checkable || !button.enabled)
            return
        button.toggle()
        button.toggled()
        button.clicked()
    }

    onAccessoryChanged: if (accessory) accessory.parent = accessorySlot
    onMenuChanged: if (menu) menu.contextFor = root

    bottomInset: separator.visible ? separator.height : 0

    background: Rectangle {
        id: bg
        color: root.pressed ? Theme.palette.pressed
             : root.selected ? Theme.colors.getColor(Theme.palette.primary, 0.18)
             : root.hovered || root.visualFocus ? Theme.palette.hover
             : "transparent"
    }

    contentItem: RowLayout {
        id: contentRow
        spacing: Theme.spacing.medium

        LogosIcon {
            visible: d.hasIcon
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
            LogosText {
                id: captionText
                Layout.fillWidth: true
                visible: root.caption !== ""
                text: root.caption
                elide: Text.ElideRight
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
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

        LogosIconButton {
            id: menuButton
            visible: root.menu !== null
            size: Theme.size.touchTarget
            flat: true
            iconSource: LogosIcons.more
            Accessible.name: qsTr("More")
            onClicked: root.menu.popupUnder(menuButton)
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

    Rectangle {
        id: separator
        visible: root.showSeparator
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: root.leftPadding + (d.hasIcon ? Theme.controls.listRow.iconSize + contentRow.spacing : 0)
        height: Theme.size.borderWidth
        color: Theme.palette.borderSubtle
    }
}
