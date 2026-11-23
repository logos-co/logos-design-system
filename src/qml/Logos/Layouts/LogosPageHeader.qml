import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

// LogosPageHeader — the head of a page a shell already frames, such as an app
// in a Basecamp tab: its title and subtitle, and a search on their right,
// searchWidth wide or what the title leaves. On a phone, measured on itself,
// the search never takes a row of its own: it is a 🔍 at the end of the
// title's line, and a tap opens it across that line in place of the title.
// ✕ clears and folds it, as Esc does; it stays open while it holds text, and
// its query survives a change of width. Its search is LogosSections'.
//
// Public API:
//     title, subtitle       the page's; an empty one takes no room
//     searchEnabled         the page has a search
//     searchPlaceholder     its placeholder
//     searchShortcutHint    a keyboard shortcut shown in it beside the title, e.g. "Ctrl+K"
//     searchWidth           its width beside the title (default Theme.controls.search.width)
//     searchText            read-only; the query, "" while searchEnabled is false
//     openSearch([query])   focus the search, opening it on a phone, its query
//                           selected; given a query, it searches for that
//     closeSearch()         clear the search and fold it
//     searchSubmitted(text) Enter in the search
//
// Read-only inspection aliases: titleItem, subtitleItem, searchItem.
//
// Example:
//     LogosPageHeader {
//         Layout.fillWidth: true
//         title: qsTr("Packages")
//         subtitle: qsTr("Install, update and remove what you run.")
//         searchEnabled: true
//         searchPlaceholder: qsTr("Search packages")
//         onSearchTextChanged: catalog.filter = searchText
//     }
Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property bool searchEnabled: false
    property string searchPlaceholder: qsTr("Search")
    property string searchShortcutHint: ""
    property int searchWidth: Theme.controls.search.width
    readonly property string searchText: searchEnabled ? search.text : ""

    signal searchSubmitted(string text)

    readonly property alias titleItem: titleText
    readonly property alias subtitleItem: subtitleText
    readonly property alias searchItem: search

    function openSearch(query) {
        if (!searchEnabled)
            return
        if (query !== undefined)
            search.text = query
        search.open()
        search.searchBarItem.textInput.selectAll()
    }

    function closeSearch() {
        search.close()
    }

    implicitWidth: grid.implicitWidth
    implicitHeight: grid.implicitHeight

    QtObject {
        id: d
        readonly property bool phone: Theme.windowClass(root.width) === "phone"
        // Open across the title's line, on a phone.
        readonly property bool searching: root.searchEnabled && search.folds && search.expanded
        readonly property real textWidth: Math.max(titleText.visible ? titleText.implicitWidth : 0,
                                                   subtitleText.visible ? subtitleText.implicitWidth : 0)
    }

    GridLayout {
        id: grid
        anchors.left: parent.left
        anchors.right: parent.right
        columns: 2
        columnSpacing: d.phone ? Theme.spacing.tiny : Theme.spacing.xlarge
        rowSpacing: Theme.spacing.tiny

        LogosText {
            id: titleText
            visible: text !== "" && !d.searching
            Layout.row: 0
            Layout.column: 0
            Layout.fillWidth: true
            text: root.title
            wrapMode: Text.Wrap
            font.pixelSize: Theme.typography.pageTitleText
            font.weight: Theme.typography.weightBold
        }

        LogosText {
            id: subtitleText
            visible: text !== ""
            Layout.row: 1
            Layout.column: 0
            Layout.columnSpan: d.phone ? 2 : 1
            Layout.fillWidth: true
            text: root.subtitle
            wrapMode: Text.Wrap
            font.pixelSize: Theme.typography.primaryText
            color: Theme.palette.textSecondary
        }

        // Beside the title and subtitle, centred on them; on a phone at the
        // end of the title's line, and across it once open.
        LogosSearchToggle {
            id: search
            visible: root.searchEnabled
            folds: d.phone
            placeholderText: root.searchPlaceholder
            shortcutHint: folds ? "" : root.searchShortcutHint
            Layout.row: 0
            Layout.column: d.searching ? 0 : 1
            Layout.columnSpan: d.searching ? 2 : 1
            Layout.rowSpan: d.phone ? 1 : 2
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.preferredWidth: folds ? -1 : root.searchWidth
            // A pixel to spare: a title given exactly its width can wrap.
            Layout.maximumWidth: folds ? Number.POSITIVE_INFINITY
                                       : Math.max(0, grid.width - grid.columnSpacing - Math.ceil(d.textWidth) - 1)
            Layout.preferredHeight: folds ? -1 : Theme.controls.search.height
            onSubmitted: text => root.searchSubmitted(text)
        }
    }
}
