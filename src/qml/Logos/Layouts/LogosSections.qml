import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Icons

// LogosSections — a page with several sections, such as an app's settings: a
// title and subtitle, a list of the sections, and the current section in a
// card beside it. From tablet width up, measured on itself, the list is
// beside the section (200 wide, 168 on a tablet). On a phone the list is the
// page, a card of rows; a tap opens the section under a "‹ Title" row that
// goes back to the list, as Esc and the phone's Back key do. There is no
// drawer: on a phone, navigation that hides behind ☰ is easy to miss.
//
// A section that goes a level deeper (a row's detail, a page of its own)
// says so with canGoBack: the same row then names where back goes,
// backTitle, and emits backRequested() rather than leave the section. Beside
// the list the row shows at the top of the section's card while it does.
// There is one way back: the section's own pages draw no back of their own.
//
// A section can have a search. Beside the list it is a field on the title's
// right, searchWidth wide or what the title leaves. On a phone it never takes
// a row of its own: it is a 🔍 at the end of the back row, and a tap opens it
// across the row in place of the row's title. ✕ clears and folds it, and Esc
// or the phone's Back key folds it before they go back. It stays open while
// it holds text, and its query survives a change of width.
//
// Public API:
//     title, subtitle     over the page; on a phone the title names the back row
//     listTitle           a label over the list beside the section; empty hides it
//     sections            [{ title, iconSource }], one entry per section
//     currentIndex        the section shown; setting it opens it on a phone too
//     searchEnabled       the open section has a search
//     searchPlaceholder   its placeholder
//     searchShortcutHint  a keyboard shortcut shown in it beside the list, e.g. "Ctrl+K"
//     searchWidth         its width beside the list (default Theme.controls.search.width)
//     searchText          read-only; the query, "" while searchEnabled is false
//     openSearch([query]) focus the search, opening it on a phone, its query
//                         selected; given a query, it searches for that
//     closeSearch()       clear the search and fold it
//     searchSubmitted(text)  Enter in the search
//     twoPane             read-only; the list beside the section
//     showingSection      read-only; the section fills the page (phone width)
//     showList()          back to the list (phone width)
//     canGoBack           the open section is a level deeper; back goes up one
//     backTitle           where back goes from there, named by the back row
//     backRequested()     back from a level of the section's own: go up one
//     content (default)   the sections' pages; show the one at currentIndex
//
// Read-only inspection aliases: titleItem, subtitleItem, listItem,
// phoneListItem, backRowItem (on a phone), sectionBackRowItem (in the card,
// beside the list), sectionItem, searchItem.
//
// Example:
//     LogosSections {
//         id: settings
//         title: qsTr("Settings")
//         subtitle: qsTr("Manage your apps and how they look.")
//         listTitle: qsTr("Sections")
//         sections: [{ title: qsTr("Apps") }, { title: qsTr("Appearance") }]
//         searchEnabled: settings.currentIndex === 0
//         searchPlaceholder: qsTr("Search apps")
//         onCurrentIndexChanged: closeSearch()
//         StackLayout {
//             anchors.fill: parent
//             currentIndex: settings.currentIndex
//             AppsPage { filter: settings.searchText }
//             AppearancePage {}
//         }
//     }
Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property string listTitle: ""
    property var sections: []
    property int currentIndex: 0
    property bool canGoBack: false
    property string backTitle: ""
    property bool searchEnabled: false
    property string searchPlaceholder: qsTr("Search")
    property string searchShortcutHint: ""
    property int searchWidth: Theme.controls.search.width
    readonly property string searchText: searchEnabled ? search.text : ""
    readonly property bool twoPane: Theme.windowClass(width) !== "phone"
    readonly property bool showingSection: !twoPane && d.sectionOpen
    default property alias content: page.data

    signal backRequested()
    signal searchSubmitted(string text)

    readonly property alias titleItem: titleText
    readonly property alias subtitleItem: subtitleText
    readonly property alias listItem: list
    readonly property alias phoneListItem: phoneList
    readonly property alias backRowItem: backRow
    readonly property alias sectionBackRowItem: cardBackRow
    readonly property alias sectionItem: sectionCard
    readonly property alias searchItem: search

    function showList() {
        d.sectionOpen = false
    }

    function openSearch(query) {
        if (!d.searchShown)
            return
        if (query !== undefined)
            search.text = query
        search.open()
        search.searchBarItem.textInput.selectAll()
    }

    function closeSearch() {
        search.close()
    }

    onCurrentIndexChanged: d.sectionOpen = true

    Keys.onEscapePressed: event => d.back(event)
    Keys.onBackPressed: event => d.back(event)

    QtObject {
        id: d

        property bool sectionOpen: false
        // Here, not on the items: an item's visible also reads its parent's.
        readonly property bool titleShown: !root.showingSection && (root.title !== "" || root.subtitle !== "")
        // Beside the list, or in the back row of an open section.
        readonly property bool searchShown: root.searchEnabled && (root.twoPane || root.showingSection)
        // Open across the back row, on a phone.
        readonly property bool searching: searchShown && search.folds && search.expanded
        readonly property real listWidth: Theme.windowClass(root.width) === "tablet"
                                          ? Theme.layouts.sections.tabletListWidth
                                          : Theme.layouts.sections.listWidth
        // A level of the section's own, while the section is open.
        readonly property bool levelOpen: root.canGoBack && (root.twoPane || root.showingSection)
        readonly property string backLabel: levelOpen ? root.backTitle : root.title

        function goBack() {
            if (levelOpen)
                root.backRequested()
            else
                root.showList()
        }

        function back(event) {
            // An open search folds first, as its ✕ does.
            if (searching) {
                event.accepted = true
                search.close()
                root.forceActiveFocus()
                return
            }
            event.accepted = root.showingSection || levelOpen
            if (event.accepted) {
                goBack()
                root.forceActiveFocus()
            }
        }
    }

    // "‹ Where back goes": the whole row is the back target and names it.
    component BackRow: AbstractButton {
        id: backButton

        property string label: ""

        implicitHeight: Theme.size.touchTarget
        Accessible.name: qsTr("Back to %1").arg(label)

        background: Rectangle {
            radius: Theme.spacing.radiusLarge
            color: backButton.pressed ? Theme.palette.pressed : "transparent"
        }
        contentItem: RowLayout {
            spacing: Theme.spacing.tiny
            LogosIcon {
                Layout.leftMargin: Theme.spacing.small
                Layout.preferredWidth: Theme.size.iconMedium
                Layout.preferredHeight: Theme.size.iconMedium
                source: LogosIcons.back
            }
            LogosText {
                Layout.fillWidth: true
                text: backButton.label
                elide: Text.ElideRight
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightMedium
            }
        }
    }

    Component {
        id: listTitleComponent
        LogosText {
            width: list.width
            topPadding: Theme.spacing.tiny
            bottomPadding: Theme.spacing.tiny
            text: root.listTitle
            font.pixelSize: Theme.typography.subtitleText
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.pageMargin(root.width)
        anchors.rightMargin: Theme.pageMargin(root.width)
        anchors.topMargin: (root.twoPane ? Theme.pageMargin(root.width) : Theme.spacing.medium)
                           + Theme.topInset(root)
        anchors.bottomMargin: (root.twoPane ? Theme.pageMargin(root.width) : Theme.spacing.large)
                              + Theme.bottomInset(root)
        spacing: root.twoPane ? Theme.spacing.xlarge : Theme.spacing.medium

        // The page's first row: the title and subtitle, with the search on
        // their right beside the list; on a phone, with a section open, the
        // back row with the search folded at its end.
        RowLayout {
            id: header
            Layout.fillWidth: true
            visible: root.showingSection || d.titleShown || d.searchShown
            spacing: root.twoPane ? Theme.spacing.xlarge : Theme.spacing.tiny

            BackRow {
                id: backRow
                visible: root.showingSection && !d.searching
                Layout.fillWidth: true
                Layout.leftMargin: -Theme.spacing.small
                label: d.backLabel
                onClicked: d.goBack()
            }

            ColumnLayout {
                id: titleBlock
                visible: d.titleShown
                Layout.fillWidth: true
                spacing: Theme.spacing.tiny

                LogosText {
                    id: titleText
                    visible: text !== ""
                    Layout.fillWidth: true
                    text: root.title
                    wrapMode: Text.Wrap
                    font.pixelSize: Theme.typography.pageTitleText
                    font.weight: Theme.typography.weightBold
                }
                LogosText {
                    id: subtitleText
                    visible: text !== ""
                    Layout.fillWidth: true
                    text: root.subtitle
                    wrapMode: Text.Wrap
                    font.pixelSize: Theme.typography.primaryText
                    color: Theme.palette.textSecondary
                }
            }

            // Keeps the search at the right without a title.
            Item { visible: root.twoPane && !d.titleShown; Layout.fillWidth: true }

            // Beside the list a search field, searchWidth wide or what the
            // title leaves; on a phone a 🔍 that opens across the row.
            LogosSearchToggle {
                id: search
                visible: d.searchShown
                folds: !root.twoPane
                placeholderText: root.searchPlaceholder
                shortcutHint: folds ? "" : root.searchShortcutHint
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.preferredWidth: folds ? -1 : root.searchWidth
                Layout.maximumWidth: folds ? Number.POSITIVE_INFINITY
                                           : Math.max(0, header.width - header.spacing
                                                         - (d.titleShown ? titleBlock.implicitWidth : 0))
                Layout.preferredHeight: folds ? -1 : Theme.controls.search.height
                onSubmitted: text => root.searchSubmitted(text)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.spacing.medium

            // ─── Beside the section: a label over pill rows ───
            LogosListView {
                id: list
                visible: root.twoPane
                Layout.preferredWidth: d.listWidth
                Layout.minimumWidth: d.listWidth
                Layout.maximumWidth: d.listWidth
                Layout.fillHeight: true
                spacing: Theme.spacing.tiny
                model: root.sections
                currentIndex: root.currentIndex

                // None without a title: a Text held at height 0 loops.
                header: root.listTitle !== "" ? listTitleComponent : null

                delegate: LogosItemDelegate {
                    id: pill
                    required property var modelData
                    required property int index
                    width: ListView.view.width
                    text: modelData.title
                    highlighted: index === root.currentIndex
                    radius: Theme.spacing.radiusLarge
                    highlightColor: Theme.palette.backgroundButton
                    hoverColor: "transparent"
                    textColor: pill.highlighted || pill.hovered ? Theme.palette.text
                                                                : Theme.palette.textTertiary
                    onClicked: root.currentIndex = index
                }
            }

            // ─── A phone's page: a card of rows that open a section ───
            LogosScrollView {
                id: phoneList
                visible: !root.twoPane && !d.sectionOpen
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: availableWidth
                clip: true

                Rectangle {
                    implicitWidth: phoneList.availableWidth
                    implicitHeight: rows.implicitHeight
                    radius: Theme.spacing.radiusXlarge
                    color: Theme.palette.surfaceRaised
                    clip: true

                    ColumnLayout {
                        id: rows
                        width: parent.width
                        spacing: 0

                        Repeater {
                            model: root.sections
                            delegate: LogosListRow {
                                required property var modelData
                                required property int index
                                objectName: "sectionRow" + index
                                Layout.fillWidth: true
                                title: modelData.title
                                iconSource: modelData.iconSource ?? ""
                                showChevron: true
                                showSeparator: index < root.sections.length - 1
                                onClicked: {
                                    root.currentIndex = index
                                    d.sectionOpen = true
                                }
                            }
                        }
                    }
                }
            }

            // ─── The section, in a card ───
            Rectangle {
                id: sectionCard
                visible: root.twoPane || d.sectionOpen
                Layout.fillWidth: true
                Layout.fillHeight: true
                // A wide section never pushes the card past the page's edge.
                Layout.minimumWidth: 0
                Layout.maximumWidth: Math.max(0, root.width - 2 * Theme.pageMargin(root.width)
                                              - (root.twoPane ? d.listWidth + Theme.spacing.medium : 0))
                color: Theme.palette.surfaceRaised
                radius: Theme.spacing.radiusXlarge
                clip: true

                // Beside the list, the way back from the section's own level.
                BackRow {
                    id: cardBackRow
                    visible: root.twoPane && root.canGoBack
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Theme.spacing.small
                    label: root.backTitle
                    onClicked: d.goBack()
                }

                Item {
                    id: page
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.top: cardBackRow.visible ? cardBackRow.bottom : parent.top
                }
            }
        }
    }
}
