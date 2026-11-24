import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

// Settings: one column of grouped rows, at most a form's width, left-aligned
// in its card. A chevron goes somewhere, a value is the current setting, a
// switch turns something on or off; the destructive group is last. Network
// opens a level of its own, which the app's back row closes.
Item {
    id: root

    required property WalletData wallet

    readonly property bool canGoBack: levels.currentIndex === 1
    readonly property string backTitle: qsTr("Settings")

    readonly property alias networkRowItem: networkRow
    readonly property alias removeDialogItem: removeDialog

    function goBack() {
        levels.currentIndex = 0
    }

    component GroupTitle: LogosText {
        Layout.fillWidth: true
        Layout.topMargin: Theme.spacing.large
        Layout.bottomMargin: Theme.spacing.small
        font.pixelSize: Theme.typography.secondaryText
        font.weight: Theme.typography.weightMedium
        color: Theme.palette.textSecondary
        wrapMode: Text.Wrap
    }

    StackLayout {
        id: levels
        anchors.fill: parent
        anchors.margins: Theme.pageMargin(root.width)

        LogosScrollView {
            id: scroll
            contentWidth: availableWidth

            ColumnLayout {
                width: Math.min(scroll.availableWidth, Theme.layouts.form.maximumWidth)
                spacing: 0

                LogosText {
                    Layout.fillWidth: true
                    text: qsTr("Settings")
                    font.pixelSize: Theme.typography.panelTitleText
                    font.weight: Theme.typography.weightBold
                    wrapMode: Text.Wrap
                }

                GroupTitle { text: qsTr("Network") }
                LogosListRow {
                    id: networkRow
                    Layout.fillWidth: true
                    title: qsTr("Network")
                    value: root.wallet.network
                    showChevron: true
                    onClicked: levels.currentIndex = 1
                }

                GroupTitle { text: qsTr("Preferences") }
                LogosListRow {
                    Layout.fillWidth: true
                    title: qsTr("Notifications")
                    subtitle: qsTr("When a payment arrives or settles")
                    accessory: LogosSwitch {
                        checked: root.wallet.notifications
                        onToggled: root.wallet.notifications = checked
                    }
                }
                LogosListRow {
                    Layout.fillWidth: true
                    title: qsTr("Hide small payments")
                    subtitle: qsTr("Under %1 %2").arg(root.wallet.smallPayment).arg(root.wallet.symbol)
                    accessory: LogosSwitch {
                        checked: root.wallet.hideSmallPayments
                        onToggled: root.wallet.hideSmallPayments = checked
                    }
                }

                GroupTitle { text: qsTr("This device") }
                LogosListRow {
                    Layout.fillWidth: true
                    title: qsTr("Remove wallet")
                    subtitle: qsTr("From this device only")
                    destructive: true
                    onClicked: removeDialog.open()
                }
            }
        }

        LogosScrollView {
            id: networksScroll
            contentWidth: availableWidth

            ColumnLayout {
                id: networks
                width: Math.min(networksScroll.availableWidth, Theme.layouts.form.maximumWidth)
                spacing: 0

                LogosText {
                    Layout.fillWidth: true
                    text: qsTr("Network")
                    font.pixelSize: Theme.typography.panelTitleText
                    font.weight: Theme.typography.weightBold
                    wrapMode: Text.Wrap
                }
                Repeater {
                    model: root.wallet.networks
                    delegate: LogosListRow {
                        required property string modelData
                        objectName: "network." + modelData
                        Layout.fillWidth: true
                        title: modelData
                        selected: modelData === root.wallet.network
                        value: selected ? qsTr("In use") : ""
                        onClicked: {
                            root.wallet.network = modelData
                            root.goBack()
                        }
                    }
                }
            }
        }
    }

    LogosWarningDialog {
        id: removeDialog
        accentColor: Theme.palette.error
        title: qsTr("Remove this wallet?")
        message: qsTr("Without your recovery phrase you can't get it back.")
        leftActions: [ LogosButton { text: qsTr("Cancel"); onClicked: removeDialog.reject() } ]
        rightActions: [ LogosButton { text: qsTr("Remove"); onClicked: removeDialog.accept() } ]
    }
}
