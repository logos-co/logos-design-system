import QtQuick

// The wallet's sample data; an app reads the same from its backend.
QtObject {
    id: root

    readonly property string symbol: "TST"
    property real balance: 1284.5
    property string network: "Testnet"
    readonly property var networks: ["Mainnet", "Testnet", "Devnet"]
    property bool notifications: true
    property bool hideSmallPayments: false
    readonly property real smallPayment: 5

    readonly property ListModel payments: ListModel {
        ListElement { paymentId: 6; kind: "Received"; counterparty: "Alice";        address: "0x5a6f6faf062894b08572678d59b0bccf206e5253"; amount: "+250.00"; date: "24 Nov"; status: "Confirmed"; note: "Dinner" }
        ListElement { paymentId: 5; kind: "Sent";     counterparty: "Coffee Corner"; address: "0x01180a0ec272e88a13898e20eefa5e0e3e21c8cd"; amount: "-4.50";   date: "23 Nov"; status: "Pending";   note: "" }
        ListElement { paymentId: 4; kind: "Sent";     counterparty: "Bob";          address: "0x4f7e8cc115951a7a017a7f4557fd9a9ce57d0309"; amount: "-60.00";  date: "21 Nov"; status: "Confirmed"; note: "Concert tickets" }
        ListElement { paymentId: 3; kind: "Received"; counterparty: "Payroll";      address: "0x432b83bf91fd7ad65999434bd0297f93e3265145"; amount: "+1,100.00"; date: "15 Nov"; status: "Confirmed"; note: "November" }
        ListElement { paymentId: 2; kind: "Sent";     counterparty: "Carol";        address: "0x32c8e07e5fd75fc40510cbc476edad7720042ddc"; amount: "-12.00";  date: "12 Nov"; status: "Failed";    note: "Taxi" }
        ListElement { paymentId: 1; kind: "Received"; counterparty: "Dave";         address: "0x71bd000558dd6bf4042ef9cb94565d9e98d8e0f5"; amount: "+11.00";  date: "9 Nov";  status: "Confirmed"; note: "" }
    }

    function payment(paymentId) {
        for (let i = 0; i < payments.count; ++i)
            if (payments.get(i).paymentId === paymentId)
                return payments.get(i)
        return null
    }

    function send(to, amount, note) {
        let next = 0
        for (let i = 0; i < payments.count; ++i)
            next = Math.max(next, payments.get(i).paymentId)
        payments.insert(0, {
            paymentId: next + 1, kind: "Sent", counterparty: to.slice(0, 6) + "…" + to.slice(-4), address: to,
            amount: "-" + amount.toFixed(2), date: qsTr("Today"), status: "Pending", note: note
        })
        balance -= amount
    }
}
