import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

// LogosWelcome — the first screen of an app's onboarding: a backdrop under a
// scrim, a column with a title, a line under it and the ways in, and four
// corners for what the app adds around it (its brand, a close button, the
// version, other ways in). Centred, as Basecamp, Blockchain and LEZ have it,
// or aligned left with the main button at its own width, as Basecamp's design
// has it. On a phone the bottom corners stack, and everything keeps clear of
// the safe area. A LogosWizard shows it before its first step.
//
// Public API:
//     backdrop          an image filling the screen, cropped
//     logo              an icon over the title; none by default
//     title, subtitle
//     status            an item over the title, e.g. a "Network connected" badge
//     alignment         Qt.AlignHCenter (default) or Qt.AlignLeft
//     primaryText       the main way in, e.g. "Continue"
//     primaryIcon       an icon after its text, e.g. LogosIcons.arrowRight
//     secondaryText     another way in, e.g. "Advanced"; hidden when empty
//     actionsFillWidth  the buttons span the column (default true); false keeps
//                       them at their own width
//     busy              a spinner in place of the buttons
//     topLeft, topRight, bottomLeft, bottomRight
//                       items in the corners; one replaced or cleared is taken out
//     primaryClicked(), secondaryClicked()
//
// background (the backdrop and scrim) and contentItem can be replaced, e.g.
// for a video or a gradient behind it.
//
// Read-only inspection aliases: columnItem, primaryButtonItem,
// secondaryButtonItem, spinnerItem, topLeftItem, topRightItem, bottomLeftItem,
// bottomRightItem.
//
// Example:
//     LogosWelcome {
//         backdrop: "qrc:/onboarding.jpg"
//         alignment: Qt.AlignLeft
//         status: LogosBadge { text: qsTr("Network connected") }
//         title: qsTr("Welcome to Basecamp,")
//         subtitle: qsTr("Let's get you set up, it'll only take a moment.")
//         primaryText: qsTr("Continue")
//         primaryIcon: LogosIcons.arrowRight
//         actionsFillWidth: false
//         topLeft: BrandBlock {}
//         bottomRight: Row { LogosLink { text: qsTr("Restore existing device") } }
//         onPrimaryClicked: setup.begin()
//     }
Control {
    id: root

    property url backdrop
    property url logo
    property string title: ""
    property string subtitle: ""
    property Item status: null
    property int alignment: Qt.AlignHCenter
    property string primaryText: ""
    property url primaryIcon
    property string secondaryText: ""
    property bool actionsFillWidth: true
    property bool busy: false
    property Item topLeft: null
    property Item topRight: null
    property Item bottomLeft: null
    property Item bottomRight: null

    signal primaryClicked()
    signal secondaryClicked()

    readonly property alias columnItem: column
    readonly property alias primaryButtonItem: primaryButton
    readonly property alias secondaryButtonItem: secondaryButton
    readonly property alias spinnerItem: spinner
    readonly property alias topLeftItem: topLeftSlot
    readonly property alias topRightItem: topRightSlot
    readonly property alias bottomLeftItem: bottomLeftSlot
    readonly property alias bottomRightItem: bottomRightSlot

    onStatusChanged: d.shownStatus = d.adopt(status, d.shownStatus, statusSlot)
    onTopLeftChanged: d.shownTopLeft = d.adopt(topLeft, d.shownTopLeft, topLeftSlot)
    onTopRightChanged: d.shownTopRight = d.adopt(topRight, d.shownTopRight, topRightSlot)
    onBottomLeftChanged: d.shownBottomLeft = d.adopt(bottomLeft, d.shownBottomLeft, bottomLeftSlot)
    onBottomRightChanged: d.shownBottomRight = d.adopt(bottomRight, d.shownBottomRight, bottomRightSlot)

    QtObject {
        id: d
        readonly property bool phone: Theme.windowClass(root.width) === "phone"
        readonly property bool left: root.alignment === Qt.AlignLeft
        readonly property real margin: Theme.pageMargin(root.width)
        property Item shownStatus: null
        property Item shownTopLeft: null
        property Item shownTopRight: null
        property Item shownBottomLeft: null
        property Item shownBottomRight: null

        function adopt(item, shown, slot) {
            if (shown && shown !== item)
                shown.parent = null
            if (item)
                item.parent = slot
            slot.held = item
            return item
        }
    }

    // A corner or the status: as big as what it holds.
    component Slot: Item {
        property Item held: null
        implicitWidth: held ? held.implicitWidth : 0
        implicitHeight: held ? held.implicitHeight : 0
        visible: held !== null
    }

    leftPadding: d.margin
    rightPadding: d.margin
    topPadding: d.margin + Theme.topInset(root)
    bottomPadding: d.margin + Theme.bottomInset(root)

    background: Item {
        Image {
            anchors.fill: parent
            source: root.backdrop
            fillMode: Image.PreserveAspectCrop
            mipmap: true
        }
        Rectangle {
            anchors.fill: parent
            color: Theme.palette.scrim
        }
    }

    contentItem: ColumnLayout {
        spacing: Theme.spacing.large

        RowLayout {
            // On what the slots hold: a slot in a hidden row reads hidden too.
            visible: topLeftSlot.held !== null || topRightSlot.held !== null
            Layout.fillWidth: true
            Slot { id: topLeftSlot; Layout.alignment: Qt.AlignTop | Qt.AlignLeft }
            Item { Layout.fillWidth: true }
            Slot { id: topRightSlot; Layout.alignment: Qt.AlignTop | Qt.AlignRight }
        }

        Item { Layout.fillHeight: true }

        ColumnLayout {
            id: column
            Layout.fillWidth: true
            Layout.maximumWidth: Theme.layouts.welcome.maximumWidth
            Layout.alignment: d.left ? Qt.AlignLeft : Qt.AlignHCenter
            spacing: Theme.spacing.medium

            LogosIcon {
                visible: root.logo.toString() !== ""
                Layout.alignment: d.left ? Qt.AlignLeft : Qt.AlignHCenter
                Layout.bottomMargin: Theme.spacing.medium
                Layout.preferredWidth: Theme.layouts.welcome.logoSize
                Layout.preferredHeight: Theme.layouts.welcome.logoSize
                source: root.logo
            }

            Slot {
                id: statusSlot
                Layout.alignment: d.left ? Qt.AlignLeft : Qt.AlignHCenter
            }

            LogosText {
                Layout.fillWidth: true
                horizontalAlignment: d.left ? Text.AlignLeft : Text.AlignHCenter
                text: root.title
                wrapMode: Text.Wrap
                font.pixelSize: Theme.typography.pageTitleText
                font.weight: Theme.typography.weightBold
            }

            LogosText {
                visible: root.subtitle !== ""
                Layout.fillWidth: true
                horizontalAlignment: d.left ? Text.AlignLeft : Text.AlignHCenter
                text: root.subtitle
                wrapMode: Text.Wrap
                font.pixelSize: Theme.typography.subtitleText
            }

            ColumnLayout {
                visible: !root.busy
                Layout.alignment: d.left ? Qt.AlignLeft : Qt.AlignHCenter
                Layout.topMargin: Theme.spacing.large
                Layout.fillWidth: root.actionsFillWidth
                Layout.maximumWidth: Theme.layouts.welcome.buttonWidth
                spacing: Theme.spacing.medium

                LogosButton {
                    id: primaryButton
                    visible: root.primaryText !== ""
                    Layout.fillWidth: root.actionsFillWidth
                    Layout.alignment: d.left ? Qt.AlignLeft : Qt.AlignHCenter
                    Layout.preferredHeight: Theme.layouts.welcome.buttonHeight
                    variant: LogosButton.Variant.Primary
                    text: root.primaryText
                    trailingIcon.source: root.primaryIcon
                    onClicked: root.primaryClicked()
                }
                LogosButton {
                    id: secondaryButton
                    visible: root.secondaryText !== ""
                    Layout.fillWidth: root.actionsFillWidth
                    Layout.alignment: d.left ? Qt.AlignLeft : Qt.AlignHCenter
                    Layout.preferredHeight: Theme.layouts.welcome.buttonHeight
                    text: root.secondaryText
                    onClicked: root.secondaryClicked()
                }
            }

            LogosSpinner {
                id: spinner
                visible: root.busy
                running: root.busy
                Layout.alignment: d.left ? Qt.AlignLeft : Qt.AlignHCenter
                Layout.topMargin: Theme.spacing.large
            }
        }

        Item { Layout.fillHeight: true }

        // Side by side at the bottom; stacked on a phone.
        GridLayout {
            visible: bottomLeftSlot.held !== null || bottomRightSlot.held !== null
            Layout.fillWidth: true
            columns: d.phone ? 1 : 3
            rowSpacing: Theme.spacing.medium
            Slot { id: bottomLeftSlot; Layout.alignment: Qt.AlignBottom | Qt.AlignLeft }
            Item { visible: !d.phone; Layout.fillWidth: true }
            Slot { id: bottomRightSlot; Layout.alignment: Qt.AlignBottom | (d.phone ? Qt.AlignLeft : Qt.AlignRight) }
        }
    }
}
