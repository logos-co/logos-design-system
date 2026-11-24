import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Layouts

// The dashboard: stat cards in as many columns as fit, never three and one,
// and the latest payments, each a tap away from its detail.
Item {
    id: root

    required property WalletData wallet

    signal activityRequested()
    signal paymentOpened(int id)

    // A card on the section's card: recessed, so it stands apart from it.
    component Stat: LogosStatCard {
        backgroundColor: Theme.palette.surfaceRecessed
    }

    QtObject {
        id: d
        readonly property int recentCount: 3
        readonly property int pending: {
            let n = 0
            for (let i = 0; i < root.wallet.payments.count; ++i)
                if (root.wallet.payments.get(i).status === "Pending")
                    ++n
            return n
        }

        function amount(value) {
            return Number(value).toLocaleString(Qt.locale(), "f", 2) + " " + root.wallet.symbol
        }
    }

    LogosScrollView {
        id: scroll
        anchors.fill: parent
        anchors.margins: Theme.pageMargin(root.width)
        contentWidth: availableWidth

        ColumnLayout {
            width: scroll.availableWidth
            spacing: Theme.spacing.xlarge

            LogosText {
                Layout.fillWidth: true
                text: qsTr("Overview")
                font.pixelSize: Theme.typography.panelTitleText
                font.weight: Theme.typography.weightBold
                wrapMode: Text.Wrap
            }

            LogosCardGrid {
                id: cards
                Layout.fillWidth: true
                Stat { objectName: "stat.balance"; label: qsTr("Balance"); value: d.amount(root.wallet.balance) }
                Stat { label: qsTr("Network"); value: root.wallet.network }
                Stat { label: qsTr("Payments"); value: String(root.wallet.payments.count) }
                Stat {
                    label: qsTr("Pending")
                    value: String(d.pending)
                    caption: d.pending > 0 ? qsTr("Waiting for the network") : qsTr("All settled")
                }
            }

            LogosText {
                Layout.fillWidth: true
                text: qsTr("Recent activity")
                font.pixelSize: Theme.typography.subtitleText
                font.weight: Theme.typography.weightBold
                wrapMode: Text.Wrap
            }

            ColumnLayout {
                id: recent
                Layout.fillWidth: true
                spacing: 0

                Repeater {
                    model: root.wallet.payments
                    delegate: LogosListRow {
                        required property int index
                        required property int paymentId
                        required property string counterparty
                        required property string date
                        required property string status
                        required property string amount
                        objectName: "recent" + index
                        Layout.fillWidth: true
                        visible: index < d.recentCount
                        title: counterparty
                        subtitle: date + " · " + status
                        value: amount
                        showChevron: true
                        onClicked: root.paymentOpened(paymentId)
                    }
                }
            }

            LogosButton {
                text: qsTr("All activity")
                onClicked: root.activityRequested()
            }
        }
    }
}
