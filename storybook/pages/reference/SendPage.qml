import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Layouts

// A form: labels beside the fields on a desktop, above them narrower, narrow
// fields in pairs on a tablet, everything full width on a phone with the main
// button last. Errors show under their field once there is something to judge;
// Send asks first, in a dialog that is a sheet on a phone.
Item {
    id: root

    required property WalletData wallet

    readonly property alias formItem: form
    readonly property alias toFieldItem: toField
    readonly property alias amountFieldItem: amountField
    readonly property alias sendButtonItem: sendButton
    readonly property alias confirmItem: confirm

    signal sent(string to, string amount)

    function prefill(address) {
        clear()
        toField.text = address
    }

    function clear() {
        toField.text = ""
        amountField.text = ""
        noteField.text = ""
        d.tried = false
    }

    QtObject {
        id: d
        // Errors show once the user has tried to send, or typed something wrong.
        property bool tried: false
        readonly property real amount: Number(amountField.text.replace(",", "."))
        readonly property string toError:
            toField.text === "" ? (tried ? qsTr("Enter who to pay.") : "")
            : !/^0x[0-9a-fA-F]{40}$/.test(toField.text) ? qsTr("An address is 0x and 40 hex digits.")
            : ""
        readonly property string amountError:
            amountField.text === "" ? (tried ? qsTr("Enter an amount.") : "")
            : !(amount > 0) ? qsTr("Enter an amount above 0.")
            : amount > root.wallet.balance ? qsTr("That's more than your balance.")
            : ""
        readonly property bool valid: toField.text !== "" && amountField.text !== ""
                                      && toError === "" && amountError === ""
    }

    LogosScrollView {
        id: scroll
        anchors.fill: parent
        anchors.topMargin: Theme.pageMargin(root.width)
        anchors.bottomMargin: Theme.pageMargin(root.width)
        contentWidth: availableWidth

        // At its widest, left-aligned in the section's card, as settings are.
        LogosFormLayout {
            id: form
            width: Math.min(scroll.availableWidth, maximumWidth)

            leftActions: [ LogosButton { text: qsTr("Clear"); onClicked: root.clear() } ]
            rightActions: [
                LogosButton {
                    id: sendButton
                    text: qsTr("Send")
                    variant: LogosButton.Variant.Primary
                    onClicked: {
                        d.tried = true
                        if (d.valid)
                            confirm.open()
                    }
                }
            ]

            LogosText {
                text: qsTr("Send")
                font.pixelSize: Theme.typography.panelTitleText
                font.weight: Theme.typography.weightBold
            }
            LogosFormField {
                objectName: "send.to"
                label: qsTr("To")
                help: qsTr("The address you are paying.")
                error: d.toError
                LogosTextField { id: toField; placeholderText: "0x…" }
            }
            LogosFormField {
                objectName: "send.amount"
                label: qsTr("Amount")
                narrow: true
                help: qsTr("Balance: %1 %2").arg(root.wallet.balance.toFixed(2)).arg(root.wallet.symbol)
                error: d.amountError
                LogosTextField { id: amountField; placeholderText: "0.00" }
            }
            LogosFormField {
                label: qsTr("Network")
                narrow: true
                LogosTextField { text: root.wallet.network; readOnly: true }
            }
            LogosFormField {
                label: qsTr("Note")
                help: qsTr("Only you see it.")
                LogosTextField { id: noteField }
            }
        }
    }

    LogosDialog {
        id: confirm
        title: qsTr("Send %1 %2?").arg(amountField.text).arg(root.wallet.symbol)
        message: qsTr("To %1 on %2. A payment can't be taken back.").arg(toField.text).arg(root.wallet.network)
        preferredWidth: 420
        leftActions: [ LogosButton { text: qsTr("Cancel"); onClicked: confirm.reject() } ]
        rightActions: [
            LogosButton {
                text: qsTr("Send")
                variant: LogosButton.Variant.Primary
                onClicked: {
                    const to = toField.text, amount = amountField.text
                    root.wallet.send(to, d.amount, noteField.text)
                    confirm.accept()
                    root.clear()
                    root.sent(to, amount)
                }
            }
        ]
    }
}
