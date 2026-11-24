import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Layouts

// The payments: a table whose columns drop out as it narrows, cards on a
// phone, and a payment's detail beside it, or as the page on a phone. The
// detail has every field, so nothing a dropped column held is lost. A tap
// opens a payment; ⋯ has its actions. On a phone the app's back row closes
// the detail: one way back.
Item {
    id: root

    required property WalletData wallet
    property string filter: ""

    readonly property bool canGoBack: panel.showingPanel
    readonly property string backTitle: qsTr("Activity")

    readonly property alias panelItem: panel
    readonly property alias tableItem: table

    signal sendAgainRequested(string address)

    function open(paymentId) {
        d.openId = paymentId
        panel.panelOpen = true
    }

    function goBack() {
        panel.panelOpen = false
    }

    QtObject {
        id: d
        property int openId: -1
        readonly property var openPayment: openId >= 0 ? root.wallet.payment(openId) : null

        function refilter() {
            const query = root.filter.trim().toLowerCase()
            shown.clear()
            for (let i = 0; i < root.wallet.payments.count; ++i) {
                const p = root.wallet.payments.get(i)
                if (root.wallet.hideSmallPayments && Math.abs(Number(p.amount.replace(/,/g, ""))) < root.wallet.smallPayment)
                    continue
                if (query === "" || p.counterparty.toLowerCase().includes(query)
                        || p.note.toLowerCase().includes(query))
                    shown.append({ paymentId: p.paymentId, kind: p.kind, counterparty: p.counterparty,
                                   address: p.address, amount: p.amount, date: p.date,
                                   status: p.status, note: p.note })
            }
        }
    }

    // What the search leaves.
    ListModel { id: shown }

    onFilterChanged: d.refilter()
    Component.onCompleted: d.refilter()
    Connections {
        target: root.wallet.payments
        function onCountChanged() { d.refilter() }
    }
    Connections {
        target: root.wallet
        function onHideSmallPaymentsChanged() { d.refilter() }
    }

    component StatusBadge: LogosBadge {
        required property string status
        text: status
        color: status === "Confirmed" ? Theme.palette.success
             : status === "Failed" ? Theme.palette.error
             : Theme.palette.textSecondary
    }

    LogosSidePanel {
        id: panel

        anchors.fill: parent
        backInHost: true
        title: d.openPayment ? d.openPayment.counterparty : ""
        onPanelOpenChanged: if (!panelOpen) d.openId = -1
        panelActions: [
            LogosButton {
                text: qsTr("Send again")
                variant: LogosButton.Variant.Primary
                onClicked: root.sendAgainRequested(d.openPayment.address)
            }
        ]

        content: Item {
            LogosStateView {
                anchors.fill: parent
                visible: shown.count === 0
                title: qsTr("No payments match")
                message: qsTr("Try another name or note.")
            }

            LogosTable {
                id: table
                anchors.fill: parent
                anchors.margins: Theme.spacing.large
                visible: shown.count > 0
                model: shown
                phoneCards: true
                rowsOpen: true
                onRowClicked: (index, row) => root.open(row.paymentId)
                rowMenu: LogosMenu {
                    LogosMenuItem { text: qsTr("Open details"); onTriggered: root.open(table.menuRow.paymentId) }
                    LogosMenuItem { text: qsTr("Send again"); onTriggered: root.sendAgainRequested(table.menuRow.address) }
                }
                columns: [
                    LogosTableColumn { title: qsTr("To or from"); role: "counterparty"; minWidth: 120; preferredWidth: 180; fillWidth: true },
                    LogosTableColumn { title: qsTr("Date"); role: "date"; minWidth: 80 },
                    LogosTableColumn { title: qsTr("Note"); role: "note"; minWidth: 140; priority: 1; card: "hidden" },
                    LogosTableColumn {
                        title: qsTr("Status"); role: "status"; minWidth: 110; priority: 2; card: "badge"
                        cellDelegate: Item {
                            implicitWidth: badge.implicitWidth
                            implicitHeight: badge.implicitHeight
                            StatusBadge { id: badge; anchors.verticalCenter: parent.verticalCenter; status: rowItem ? rowItem.status : "" }
                        }
                    },
                    LogosTableColumn {
                        title: qsTr("Amount"); role: "amount"; minWidth: 100
                        alignment: Qt.AlignRight | Qt.AlignVCenter
                    }
                ]
            }
        }

        panel: ColumnLayout {
            spacing: Theme.spacing.medium

            StatusBadge {
                Layout.leftMargin: Theme.spacing.large
                Layout.topMargin: Theme.spacing.medium
                status: d.openPayment ? d.openPayment.status : ""
            }

            Repeater {
                model: [
                    [qsTr("Amount"), "amount"], [qsTr("Date"), "date"],
                    [qsTr("Address"), "address"], [qsTr("Note"), "note"]
                ]
                delegate: ColumnLayout {
                    required property var modelData
                    readonly property string text: d.openPayment ? d.openPayment[modelData[1]] : ""
                    Layout.fillWidth: true
                    Layout.leftMargin: Theme.spacing.large
                    Layout.rightMargin: Theme.spacing.large
                    visible: text !== ""
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: modelData[0]
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                    LogosText {
                        Layout.fillWidth: true
                        text: parent.text
                        textFormat: Text.PlainText
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
