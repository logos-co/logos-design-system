import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Icons
import Logos.Controls

// LogosStateView — what a page or pane shows in place of its content while it
// loads, when there is nothing to show, or when loading failed: an icon (a
// spinner while loading), a title, a message and buttons, centred. It keeps to
// a readable width, inside the page margins on a phone, where its buttons
// stack full width.
//
// Public API:
//     kind                        LogosStateView.Empty (default), .Loading or .Error
//     title, message
//     iconSource                  the icon (default: info, or warning for Error)
//     leftActions, rightActions   buttons, e.g. Try again
//
// Read-only inspection aliases: iconItem, spinnerItem, titleItem, messageItem,
// buttonRowItem.
//
// Example:
//     LogosStateView {
//         anchors.fill: parent
//         kind: LogosStateView.Error
//         title: qsTr("Couldn't load packages")
//         message: qsTr("Check your connection and try again.")
//         rightActions: [ LogosButton { text: qsTr("Try again"); onClicked: reload() } ]
//     }
Control {
    id: root

    enum Kind { Empty, Loading, Error }

    property int kind: LogosStateView.Empty
    property string title: ""
    property string message: ""
    property url iconSource: kind === LogosStateView.Error ? LogosIcons.warning : LogosIcons.info
    property list<Item> leftActions
    property list<Item> rightActions

    readonly property alias iconItem: icon
    readonly property alias spinnerItem: spinner
    readonly property alias titleItem: titleText
    readonly property alias messageItem: messageText
    readonly property alias buttonRowItem: buttons

    implicitWidth: Theme.controls.stateView.maxWidth
    implicitHeight: column.implicitHeight

    Accessible.role: Accessible.StaticText
    Accessible.name: title
    Accessible.description: message

    contentItem: Item {
        ColumnLayout {
            id: column
            anchors.centerIn: parent
            width: Math.min(parent.width - 2 * Theme.pageMargin(parent.width), Theme.controls.stateView.maxWidth)
            spacing: Theme.spacing.medium

            LogosSpinner {
                id: spinner
                visible: root.kind === LogosStateView.Loading
                running: visible
                Layout.alignment: Qt.AlignHCenter
            }

            LogosIcon {
                id: icon
                visible: root.kind !== LogosStateView.Loading && root.iconSource.toString() !== ""
                source: root.iconSource
                color: root.kind === LogosStateView.Error ? Theme.palette.error : Theme.palette.textSecondary
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Theme.controls.stateView.iconSize
                Layout.preferredHeight: Theme.controls.stateView.iconSize
            }

            LogosText {
                id: titleText
                visible: root.title !== ""
                Layout.fillWidth: true
                text: root.title
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font.pixelSize: Theme.typography.subtitleText
                font.weight: Theme.typography.weightBold
            }

            LogosText {
                id: messageText
                visible: root.message !== ""
                Layout.fillWidth: true
                text: root.message
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                color: Theme.palette.textSecondary
            }

            LogosButtonRow {
                id: buttons
                visible: root.leftActions.length > 0 || root.rightActions.length > 0
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacing.small
                alignment: Qt.AlignHCenter
                // The column is narrow on any screen; the view's own width decides.
                stackOnPhone: Theme.windowClass(root.width) === "phone"
                leftActions: root.leftActions
                rightActions: root.rightActions
            }
        }
    }
}
