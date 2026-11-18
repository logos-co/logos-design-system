pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

// LogosSections — an app with several sections (Assets, Activity, Send…).
// From tablet width up, measured on itself, the sections are a list beside the
// current one. On a phone the app opens on the current section and the list is
// one step back: the section's page bar shows ‹ from `showingSection` and calls
// showList(), as Esc and the phone's Back key do. There is no drawer: on a
// phone, navigation that hides behind ☰ is easy to miss.
//
// Public API:
//     title               the app's name, above the list; empty hides that bar
//     sections            [{ title, iconSource }], one entry per section
//     currentIndex        the section shown; setting it shows it on a phone too
//     menu                a LogosMenu for ⋯ beside the title (app-wide actions)
//     twoPane             read-only; the list beside the section
//     showingSection      read-only; the section fills the page (phone width)
//     showList()          back to the list (phone width)
//     content (default)   the sections' pages; show the one at currentIndex
//
// Read-only inspection aliases: titleBarItem, listItem, listDetailItem.
//
// Example:
//     LogosSections {
//         id: wallet
//         title: qsTr("Wallet")
//         sections: [{ title: qsTr("Assets") }, { title: qsTr("Activity") }]
//         StackLayout {
//             anchors.fill: parent
//             currentIndex: wallet.currentIndex
//             AssetsPage {}    // each page starts with a LogosPageBar:
//             ActivityPage {}  //   canGoBack: wallet.showingSection; onBackRequested: wallet.showList()
//         }
//     }
Item {
    id: root

    property string title: ""
    property var sections: []
    property int currentIndex: 0
    property LogosMenu menu: null
    readonly property bool twoPane: listDetail.twoPane
    readonly property bool showingSection: listDetail.showingDetail
    default property alias content: page.data

    readonly property alias titleBarItem: titleBar
    readonly property alias listItem: list
    readonly property alias listDetailItem: listDetail

    function showList() {
        listDetail.detailOpen = false
    }

    onCurrentIndexChanged: listDetail.detailOpen = true

    LogosListDetail {
        id: listDetail
        anchors.fill: parent
        detailOpen: true
        listWidth: Theme.layouts.sections.listWidth

        list: ColumnLayout {
            spacing: 0

            LogosPageBar {
                id: titleBar
                visible: root.title !== ""
                Layout.fillWidth: true
                // Beside a section, as tall as the section's own bar.
                Layout.preferredHeight: root.twoPane && Theme.windowClass(listDetail.detailPaneItem.width) !== "phone"
                                        ? Theme.layouts.pageBar.height : implicitHeight
                title: root.title
                menu: root.menu
            }

            LogosListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0
                model: root.sections
                delegate: LogosListRow {
                    required property var modelData
                    required property int index
                    width: ListView.view.width
                    title: modelData.title
                    iconSource: modelData.iconSource ?? ""
                    selected: root.twoPane && index === root.currentIndex
                    showChevron: !root.twoPane
                    showSeparator: !root.twoPane
                    onClicked: {
                        root.currentIndex = index
                        listDetail.detailOpen = true
                    }
                }
            }
        }

        detail: Item {
            id: page
        }
    }
}
