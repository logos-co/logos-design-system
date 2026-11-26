import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Icons

// LogosPageHeader — the head of a page a shell already frames, such as an app
// in a Basecamp tab: its title and subtitle, and a search on their right,
// searchWidth wide or what the title leaves. On a phone, measured on itself,
// and wherever the title leaves less than a usable field
// (Theme.controls.search.minimumWidth), as a long translation can, the search
// never takes a row of its own: it is a 🔍 at the end of the title's line,
// and a tap opens it across that line in place of the title.
// ✕ clears and folds it, as Esc does; it stays open while it holds text, and
// its query survives a change of width. Its search is LogosSections'.
//
// A page that pushes a level of its own over its content, such as a detail
// that fills a phone-wide page, says so with canGoBack: a ‹ comes before the
// title, and the two are the way back; a tap emits backRequested(). On a
// phone the title's line is a 44 px row either way, so the ‹ coming, or the
// 🔍 going, moves nothing up or down. Whether the search stays over the
// level is the page's to say. There is one way back: the level draws none of
// its own (LogosSidePanel: no title, backInHost), and Esc and the phone's
// Back key are the page's to handle.
//
// Public API:
//     title, subtitle       the page's; an empty one takes no room
//     shortTitle            the title in a phone-wide header, where a long one
//                           crowds the 🔍 (default: the title)
//     subtitleOnPhone       false: a phone-wide header leaves the subtitle off,
//                           for one that says the title again (default true)
//     searchEnabled         the page has a search
//     searchPlaceholder     its placeholder
//     searchShortcutHint    a keyboard shortcut shown in it, e.g. "Ctrl+K", where a keyboard is
//     searchWidth           its width beside the title (default Theme.controls.search.width)
//     searchText            read-only; the query, "" while searchEnabled is false
//     openSearch([query])   focus the search, opening it on a phone, its query
//                           selected; given a query, it searches for that
//     closeSearch()         clear the search and fold it
//     searchSubmitted(text) Enter in the search
//     canGoBack             the page has pushed a level: ‹ before the title, which goes back
//     backRequested()       the ‹ or the title was tapped
//
// Read-only inspection aliases: titleItem, subtitleItem, searchItem,
// backButtonItem (the ‹ and the title), backIconItem.
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
    property string shortTitle: ""
    property bool subtitleOnPhone: true
    property bool searchEnabled: false
    property string searchPlaceholder: qsTr("Search")
    property string searchShortcutHint: ""
    property int searchWidth: Theme.controls.search.width
    readonly property string searchText: searchEnabled ? search.text : ""
    property bool canGoBack: false

    signal searchSubmitted(string text)
    signal backRequested()

    readonly property alias titleItem: titleText
    readonly property alias subtitleItem: subtitleText
    readonly property alias searchItem: search
    readonly property alias backButtonItem: titleButton
    readonly property alias backIconItem: backIcon

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
        readonly property bool subtitleShown: root.subtitle !== "" && (root.subtitleOnPhone || !phone)
        // Open across the title's line.
        readonly property bool searching: root.searchEnabled && search.folds && search.expanded
        // The title's and subtitle's width, measured whether or not the
        // search is open in the title's place, which would otherwise unfold it.
        readonly property real textWidth: Math.max(titleText.text !== "" ? titleRow.implicitWidth : 0,
                                                   subtitleShown ? subtitleText.implicitWidth : 0)
        // What the title leaves the search, a pixel to spare: a title given
        // exactly its width can wrap.
        readonly property real searchRoom: grid.width - grid.columnSpacing - Math.ceil(textWidth) - 1
        readonly property bool folds: phone || searchRoom < Theme.controls.search.minimumWidth
    }

    GridLayout {
        id: grid
        anchors.left: parent.left
        anchors.right: parent.right
        columns: 2
        columnSpacing: d.phone ? Theme.spacing.tiny : Theme.spacing.xlarge
        rowSpacing: Theme.spacing.tiny

        // The title; with a level pushed, a ‹ before it, and the two go back.
        // On a phone a 44 px row either way: what comes and goes on it (the
        // ‹, a 🔍) moves nothing up or down. Wider, the line is the title's
        // height, and the ‹'s 44 px tap reaches past it.
        LogosAbstractButton {
            id: titleButton
            // Even, so its halves stay on whole pixels.
            readonly property real reach: root.canGoBack && !d.folds
                ? 2 * Math.ceil(Math.max(0, Theme.size.touchTarget - titleRow.implicitHeight) / 2) : 0
            visible: titleText.text !== "" && !d.searching
            // Without a level, only the title: no hover, focus or press.
            interactive: root.canGoBack
            Layout.row: 0
            Layout.column: 0
            Layout.fillWidth: true
            Layout.topMargin: -reach / 2
            Layout.bottomMargin: -reach / 2
            implicitHeight: (d.folds ? Math.max(Theme.size.touchTarget, titleRow.implicitHeight)
                                     : titleRow.implicitHeight) + reach
            Accessible.role: root.canGoBack ? Accessible.Button : Accessible.StaticText
            Accessible.name: root.canGoBack ? qsTr("Back") : titleText.text
            onClicked: root.backRequested()

            background: Rectangle {
                radius: Theme.spacing.radiusLarge
                color: titleButton.pressed ? Theme.palette.pressed : "transparent"
            }
            contentItem: RowLayout {
                id: titleRow
                spacing: Theme.spacing.tiny

                LogosIcon {
                    id: backIcon
                    visible: root.canGoBack
                    Layout.preferredWidth: Theme.size.iconMedium
                    Layout.preferredHeight: Theme.size.iconMedium
                    source: LogosIcons.back
                }
                LogosText {
                    id: titleText
                    Layout.fillWidth: true
                    text: d.phone && root.shortTitle !== "" ? root.shortTitle : root.title
                    wrapMode: Text.Wrap
                    font.pixelSize: Theme.typography.pageTitleText
                    font.weight: Theme.typography.weightBold
                }
            }
        }

        LogosText {
            id: subtitleText
            visible: d.subtitleShown
            Layout.row: 1
            Layout.column: 0
            Layout.columnSpan: d.folds ? 2 : 1
            Layout.fillWidth: true
            text: root.subtitle
            wrapMode: Text.Wrap
            font.pixelSize: Theme.typography.primaryText
            color: Theme.palette.textSecondary
        }

        // Beside the title and subtitle, centred on them; folded, at the end
        // of the title's line, and across it once open.
        LogosSearchToggle {
            id: search
            visible: root.searchEnabled
            folds: d.folds
            placeholderText: root.searchPlaceholder
            shortcutHint: root.searchShortcutHint
            Layout.row: 0
            Layout.column: d.searching ? 0 : 1
            Layout.columnSpan: d.searching ? 2 : 1
            Layout.rowSpan: folds ? 1 : 2
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.preferredWidth: folds ? -1 : root.searchWidth
            Layout.maximumWidth: folds ? Number.POSITIVE_INFINITY : d.searchRoom
            Layout.preferredHeight: folds ? -1 : Theme.controls.search.height
            onSubmitted: text => root.searchSubmitted(text)
        }
    }
}
