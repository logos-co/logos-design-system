import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtTest

import Logos.Theme
import Logos.Icons
import Logos.Controls
import Logos.Layouts
import "qrc:/PhoneChecks.js" as PhoneChecks

// The pieces of a page at a phone's width, in a phone-wide view: nothing
// reaches past the sides, and every tappable part is a fingertip each way.
// The storybook's Preview window marks the same problems.
TestCase {
    id: root
    name: "PhoneFit"
    width: 390
    height: 844
    // Input and effective visibility need a visible TestCase.
    visible: true
    when: windowShown

    function initTestCase() {
        Theme.viewWidth = root.width
    }

    function cleanupTestCase() {
        Theme.viewWidth = 0
    }

    Component {
        id: pageBar
        LogosPageBar {
            title: "Packages"
            canGoBack: true
            searchEnabled: true
            actions: [ LogosIconButton { iconSource: LogosIcons.refresh } ]
            menu: LogosMenu { LogosMenuItem { text: "Reload" } }
        }
    }

    Component {
        id: listDetail
        LogosListDetail {
            height: 600
            list: LogosListView {
                model: ["Inbox", "Sent", "Drafts"]
                delegate: LogosListRow {
                    required property string modelData
                    width: ListView.view.width
                    title: modelData
                    showChevron: true
                }
            }
            detail: Item {}
        }
    }

    Component {
        id: sectionsList
        LogosSections {
            height: 600
            title: "Wallet"
            sections: [{ title: "Assets" }, { title: "Activity" }, { title: "Settings" }]
            menu: LogosMenu { LogosMenuItem { text: "Lock" } }
            Component.onCompleted: showList()
            Item {}
        }
    }

    Component {
        id: cardGrid
        LogosCardGrid {
            LogosStatCard { label: "Peers"; value: "12" }
            LogosStatCard { label: "Height"; value: "1,204,311" }
            LogosStatCard { label: "Epoch"; value: "812" }
            LogosStatCard { label: "Rewards"; value: "4.21 LGO" }
        }
    }

    Component {
        id: cardPair
        LogosCardPair {
            main: LogosFrame { implicitHeight: 200 }
            side: LogosFrame { implicitHeight: 200 }
        }
    }

    Component {
        id: form
        LogosFormLayout {
            leftActions: [ LogosButton { text: "Cancel" } ]
            rightActions: [ LogosButton { text: "Save" } ]
            LogosFormField { label: "Name"; LogosTextField {} }
            LogosFormField { label: "Network"; LogosComboBox { model: ["Mainnet", "Testnet"] } }
            LogosFormField { label: "City"; narrow: true; LogosTextField {} }
            LogosFormField { label: "Postcode"; narrow: true; help: "Five digits"; LogosTextField {} }
            LogosFormField { label: "Notifications"; LogosSwitch {} }
        }
    }

    Component {
        id: wizard
        LogosWizard {
            height: 700
            title: "Set up your node"
            subtitle: "Advanced setup: configure and secure your node."
            steps: ["Setup", "Network", "Keys", "Fund"]
            cancellable: true
            currentIndex: 1
            canGoNext: false
            nextHint: "Pick a network to continue"
            secondaryText: "Retry"
            Item {}
            Item {}
            Item {}
        }
    }

    Component {
        id: stateView
        LogosStateView {
            height: 500
            kind: LogosStateView.Error
            title: "Couldn't load packages"
            message: "Check your connection and try again."
            leftActions: [ LogosButton { text: "Details" } ]
            rightActions: [ LogosButton { text: "Try again" } ]
        }
    }

    ListModel {
        id: packages
        ListElement { name: "wallet"; version: "1.2.0"; status: "Installed" }
        ListElement { name: "chat"; version: "0.9.1"; status: "Upgrade" }
    }

    Component {
        id: tableCards
        LogosTable {
            height: 400
            phoneCards: true
            rowsOpen: true
            selectionMode: LogosTable.Multi
            model: packages
            rowMenu: LogosMenu { LogosMenuItem { text: "Uninstall" } }
            columns: [
                LogosTableColumn { title: "Name"; role: "name" },
                LogosTableColumn { title: "Version"; role: "version" },
                LogosTableColumn { title: "Status"; role: "status"; card: "badge" }
            ]
        }
    }

    Component {
        id: tableRows
        LogosTable {
            height: 400
            selectionMode: LogosTable.Multi
            model: packages
            rowMenu: LogosMenu { LogosMenuItem { text: "Uninstall" } }
            columns: [
                LogosTableColumn { title: "Name"; role: "name"; minWidth: 120; sortable: true },
                LogosTableColumn { title: "Version"; role: "version"; minWidth: 100; priority: 1 },
                LogosTableColumn { title: "Status"; role: "status"; minWidth: 100; fillWidth: true }
            ]
        }
    }

    Component {
        id: paginator
        LogosPaginator {
            totalCount: 150
            pageSize: 10
            currentPage: 8
            pageInfoText: "Showing 71–80 of 150"
            pageSizeOptions: [10, 20, 50]
        }
    }

    Component {
        id: controls
        ColumnLayout {
            spacing: Theme.spacing.medium
            LogosButton { text: "Install" }
            LogosButton { text: "Compact"; compact: true }
            LogosIconButton { iconSource: LogosIcons.copy }
            LogosCheckbox { text: "Remember me" }
            LogosSwitch { text: "Notifications" }
            LogosRadioButton { text: "Mainnet" }
            LogosTextField { Layout.fillWidth: true }
            LogosComboBox { model: ["Mainnet", "Testnet"] }
            LogosSpinBox {}
            LogosSearchBar { Layout.fillWidth: true }
            LogosTabBar {
                Layout.fillWidth: true
                LogosTabButton { text: "Assets" }
                LogosTabButton { text: "Activity" }
            }
            LogosLink { text: "Learn more" }
            LogosCopyableText { text: "0x1234…abcd" }
            LogosInfoButton { text: "Why?" }
            LogosListRow { Layout.fillWidth: true; title: "Notifications"; accessory: LogosSwitch {} }
        }
    }

    // ─── The checks themselves ───

    Component {
        id: misfit
        Item {
            height: 200
            property alias wide: wideButton
            property alias small: smallArea
            LogosButton { id: wideButton; x: 300; width: 200; text: "Too wide" }
            MouseArea { id: smallArea; y: 60; width: 20; height: 20 }
            MouseArea { y: 90; width: 20; height: 20; acceptedButtons: Qt.NoButton }
            MouseArea { y: 120; width: 20; height: 20; enabled: false }
            Item {
                y: 150
                width: 100
                height: 40
                clip: true
                Rectangle { width: 600; height: 10 }
            }
            Rectangle { y: 160; width: 10; height: 10; TapHandler {} }
        }
    }

    function test_the_checks_find_what_doesnt_fit() {
        const scene = createTemporaryObject(misfit, root, { width: root.width })
        waitForRendering(scene)
        const found = PhoneChecks.find(scene, Theme.size.touchTarget)
        compare(found.overflow, [scene.wide])
        compare(found.small.length, 2)
        compare(found.small[0], scene.small)
        verify(PhoneChecks.describe(scene.wide, scene).indexOf("\"Too wide\" 200×") >= 0)
    }

    function problems(item, within) {
        const found = PhoneChecks.find(item, Theme.size.touchTarget)
        const describe = items => items.map(i => PhoneChecks.describe(i, within || item)).join("; ")
        return { overflow: describe(found.overflow), small: describe(found.small) }
    }

    function test_fits_data() {
        return [
            { tag: "LogosPageBar", component: pageBar },
            { tag: "LogosListDetail", component: listDetail },
            { tag: "LogosSections list", component: sectionsList },
            { tag: "LogosCardGrid", component: cardGrid },
            { tag: "LogosCardPair", component: cardPair },
            { tag: "LogosFormLayout", component: form },
            { tag: "LogosWizard", component: wizard },
            { tag: "LogosStateView", component: stateView },
            { tag: "LogosTable cards", component: tableCards },
            { tag: "LogosTable rows", component: tableRows },
            { tag: "LogosPaginator", component: paginator },
            { tag: "controls", component: controls },
        ]
    }

    function test_fits(data) {
        const scene = createTemporaryObject(data.component, root, { width: root.width })
        verify(scene)
        waitForRendering(scene)
        const found = problems(scene)
        compare(found.overflow, "", "past the sides")
        compare(found.small, "", "smaller than a fingertip")
    }

    // Popups live in the window's overlay, not in the page.

    Item { id: host; width: root.width; height: root.height }

    Component {
        id: dialog
        LogosDialog {
            title: "Remove repository?"
            message: "You can add it again later."
            leftActions: [ LogosButton { text: "Cancel" } ]
            rightActions: [ LogosButton { text: "Remove" } ]
        }
    }

    Component {
        id: menu
        LogosMenu {
            LogosMenuItem { text: "Reload" }
            LogosMenuItem { text: "Settings" }
        }
    }

    function test_popups_fit_data() {
        return [
            { tag: "LogosDialog sheet", component: dialog },
            { tag: "LogosMenu sheet", component: menu },
        ]
    }

    function test_popups_fit(data) {
        const popup = createTemporaryObject(data.component, host)
        popup.open()
        tryCompare(popup, "opened", true)
        verify(popup.sheet)
        waitForRendering(popup.background)
        const found = problems(popup.background.parent)
        compare(found.overflow, "", "past the sides")
        compare(found.small, "", "smaller than a fingertip")
        popup.close()
    }
}
