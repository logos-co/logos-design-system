import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Icons
import Logos.Controls

// LogosOverflowRow — a row of items, such as a toolbar's buttons, while they
// fit the width it is given; otherwise a ⋯ at its end that opens `menu`,
// where the app puts the same actions. It measures what fits, never the width
// class, and has no look of its own: the app gives both forms, the row's
// items and the menu's, each in its own words. The row sits at the end, where
// ⋯ goes; hidden items take no room.
//
// Public API:
//     content (default)   the row's items, in order, each at its
//                         Layout.preferredWidth or its own width
//     menu                the LogosMenu that ⋯ opens; without one, nothing
//                         shows once the row doesn't fit
//     spacing             between the items (default Theme.spacing.medium)
//     folded              read-only; ⋯ shows in place of the row, which is
//                         then out of sight and reach
//
// Read-only inspection aliases: rowItem, moreButtonItem.
//
// Example:
//     LogosOverflowRow {
//         Layout.fillWidth: true
//         LogosButton { text: qsTr("Reload"); onClicked: catalog.reload() }
//         LogosButton { text: qsTr("Manage Repositories"); onClicked: catalog.manage() }
//         menu: LogosMenu {
//             LogosMenuItem { text: qsTr("Reload"); onTriggered: catalog.reload() }
//             LogosMenuItem { text: qsTr("Manage Repositories…"); onTriggered: catalog.manage() }
//         }
//     }
Item {
    id: root

    property LogosMenu menu: null
    property real spacing: Theme.spacing.medium
    readonly property bool folded: row.implicitWidth > width
    default property alias content: row.data

    readonly property alias rowItem: row
    readonly property alias moreButtonItem: moreButton

    implicitWidth: row.implicitWidth
    implicitHeight: folded ? moreButton.implicitHeight : row.implicitHeight

    // Folded, the row is out of sight and reach rather than hidden: a hidden
    // layout no longer notices its items hidden or shown, so it would stay
    // folded with room to spare.
    RowLayout {
        id: row
        opacity: root.folded ? 0 : 1
        enabled: !root.folded
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: root.spacing
    }

    LogosIconButton {
        id: moreButton
        visible: root.folded && root.menu !== null
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        flat: true
        size: Theme.size.touchTarget
        iconSource: LogosIcons.more
        Accessible.name: qsTr("More")
        onClicked: root.menu.popupUnder(moreButton)
    }
}
