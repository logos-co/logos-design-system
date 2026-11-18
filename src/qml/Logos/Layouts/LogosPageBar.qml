import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Icons
import Logos.Controls

// LogosPageBar — the first row of a page that a shell already frames, such as
// an app in a Basecamp tab: the page's title (or a picker in its place), its
// search, its actions and an overflow ⋯ menu. At phone width, measured on the
// bar itself, it is a touch-target-tall bar whose search folds into an icon;
// wider, the search is a field. On a detail, `canGoBack` puts ‹ before the
// title.
//
// Public API:
//     title              the page's title
//     leading            an item shown in place of the title, e.g. a picker
//     canGoBack          show ‹, which emits backRequested()
//     searchEnabled      show the search; read the query from searchText
//     searchPlaceholder
//     actions            items at the right end, before ⋯ (icon buttons)
//     menu               a LogosMenu that ⋯ opens; null hides ⋯
//     phone              read-only; true while the bar is phone-wide
//
// Signals: backRequested(), searchSubmitted(string text)
//
// Read-only inspection aliases: titleItem, backButtonItem, searchItem,
// moreButtonItem.
//
// Example:
//     LogosPageBar {
//         Layout.fillWidth: true
//         title: qsTr("Packages")
//         searchEnabled: true
//         menu: LogosMenu { LogosMenuItem { text: qsTr("Reload"); onTriggered: reload() } }
//     }
Control {
    id: root

    property string title: ""
    property Item leading: null
    property bool canGoBack: false
    property bool searchEnabled: false
    property string searchPlaceholder: qsTr("Search")
    readonly property string searchText: searchEnabled ? search.text : ""
    property list<Item> actions
    property LogosMenu menu: null
    readonly property bool phone: Theme.windowClass(width) === "phone"

    readonly property alias titleItem: titleText
    readonly property alias backButtonItem: backButton
    readonly property alias searchItem: search
    readonly property alias moreButtonItem: moreButton

    signal backRequested()
    signal searchSubmitted(string text)

    QtObject {
        id: d
        // The folded search is open: it takes the bar, back excepted.
        readonly property bool searching: search.folds && search.expanded
    }

    onLeadingChanged: if (leading) leading.parent = leadingSlot

    implicitHeight: phone ? Theme.layouts.pageBar.phoneHeight : Theme.layouts.pageBar.height
    leftPadding: phone ? Theme.spacing.tiny : Theme.pageMargin(width)
    rightPadding: phone ? Theme.spacing.tiny : Theme.pageMargin(width)

    background: Rectangle {
        color: Theme.palette.background

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: Theme.size.borderWidth
            color: Theme.palette.borderSubtle
        }
    }

    contentItem: RowLayout {
        spacing: Theme.spacing.tiny

        LogosIconButton {
            id: backButton
            visible: root.canGoBack
            flat: true
            size: Theme.size.touchTarget
            iconSource: LogosIcons.arrowLeft
            Accessible.name: qsTr("Back")
            onClicked: root.backRequested()
        }

        RowLayout {
            id: leadingSlot
            visible: root.leading !== null && !d.searching
            Layout.fillWidth: true
        }

        LogosText {
            id: titleText
            visible: root.leading === null && !d.searching
            Layout.fillWidth: true
            text: root.title
            elide: Text.ElideRight
            font.pixelSize: root.phone ? Theme.typography.subtitleText : Theme.typography.panelTitleText
            font.weight: Theme.typography.weightBold
        }

        LogosSearchToggle {
            id: search
            visible: root.searchEnabled
            folds: root.phone
            placeholderText: root.searchPlaceholder
            onSubmitted: function(text) { root.searchSubmitted(text) }
        }

        Row {
            visible: !d.searching
            spacing: Theme.spacing.tiny
            children: root.actions
        }

        LogosIconButton {
            id: moreButton
            visible: root.menu !== null && !d.searching
            flat: true
            size: Theme.size.touchTarget
            iconSource: LogosIcons.more
            Accessible.name: qsTr("More")
            onClicked: root.menu.popupUnder(moreButton)
        }
    }
}
