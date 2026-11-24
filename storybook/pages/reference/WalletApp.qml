import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Layouts

// The reference app: a wallet as a host such as Basecamp frames it, from a
// phone to a desktop. Each section is one pattern of docs/responsive.md: a
// dashboard, a table with its rows' detail, a form and settings. A section
// that goes a level deeper says so with canGoBack, backTitle and goBack(), and
// the app's one back row goes up through it.
Rectangle {
    id: root

    readonly property alias sectionsItem: sections
    readonly property alias overviewItem: overview
    readonly property alias activityItem: activity
    readonly property alias sendItem: send
    readonly property alias settingsItem: settings
    readonly property alias toastItem: toast

    color: Theme.palette.background

    QtObject {
        id: d
        readonly property var pages: [overview, activity, send, settings]
        readonly property Item open: pages[sections.currentIndex]
    }

    WalletData { id: wallet }

    LogosSections {
        id: sections

        anchors.fill: parent
        title: qsTr("Wallet")
        subtitle: qsTr("Your balance, your payments and how the wallet works.")
        sections: [
            { title: qsTr("Overview") },
            { title: qsTr("Activity") },
            { title: qsTr("Send") },
            { title: qsTr("Settings") }
        ]
        canGoBack: !!d.open.canGoBack
        backTitle: d.open.backTitle ?? ""
        onBackRequested: d.open.goBack()
        searchEnabled: currentIndex === 1 && !activity.canGoBack
        searchPlaceholder: qsTr("Search activity…")
        onCurrentIndexChanged: closeSearch()

        StackLayout {
            anchors.fill: parent
            currentIndex: sections.currentIndex

            OverviewPage {
                id: overview
                wallet: wallet
                onActivityRequested: sections.currentIndex = 1
                onPaymentOpened: id => {
                    sections.currentIndex = 1
                    activity.open(id)
                }
            }
            ActivityPage {
                id: activity
                wallet: wallet
                filter: sections.searchText
                onSendAgainRequested: address => {
                    send.prefill(address)
                    sections.currentIndex = 2
                }
            }
            SendPage {
                id: send
                wallet: wallet
                onSent: (to, amount) => toast.show(qsTr("Payment sent"),
                                                   qsTr("%1 %2 to %3").arg(amount).arg(wallet.symbol).arg(to))
            }
            SettingsPage {
                id: settings
                wallet: wallet
            }
        }
    }

    LogosToast {
        id: toast
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.spacing.large
        width: Math.min(implicitWidth, parent.width - 2 * Theme.pageMargin(parent.width))
        severity: LogosNotice.Success
        shown: false
    }
}
