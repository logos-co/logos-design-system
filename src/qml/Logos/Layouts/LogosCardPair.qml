import QtQuick
import QtQuick.Layouts

import Logos.Theme

// LogosCardPair — a wide card and a card that goes with it. Side by side, two
// parts to one, while both keep a usable width (cardPair.minimumMainWidth and
// minimumSideWidth), as tall as each other; otherwise one above the other, the
// main card first.
//
// Public API:
//     main          the wide card
//     side          the card beside it; a card replaced or cleared is taken out
//     sideBySide    read-only; the two are side by side
//
// Example:
//     LogosCardPair {
//         Layout.fillWidth: true
//         main: LogosFrame { … the chart … }
//         side: LogosFrame { … the latest blocks … }
//     }
Item {
    id: root

    property Item main: null
    property Item side: null
    readonly property bool sideBySide: d.mainWidth >= Theme.layouts.cardPair.minimumMainWidth
                                       && d.sideWidth >= Theme.layouts.cardPair.minimumSideWidth

    implicitWidth: Theme.layouts.cardPair.minimumMainWidth + Theme.layouts.cardPair.minimumSideWidth + grid.columnSpacing
    implicitHeight: grid.implicitHeight

    onMainChanged: d.adopt()
    onSideChanged: d.adopt()

    QtObject {
        id: d

        readonly property real mainWidth: (root.width - grid.columnSpacing) * 2 / 3
        readonly property real sideWidth: (root.width - grid.columnSpacing) / 3

        // The cards it shows; one replaced or cleared is taken out.
        property var shown: []

        // Main first: the grid lays its children out in order.
        function adopt() {
            const items = [root.main, root.side]
            for (let i = 0; i < shown.length; ++i)
                if (shown[i])
                    shown[i].parent = null
            shown = items.filter(item => item !== null)
            for (let i = 0; i < items.length; ++i) {
                const item = items[i]
                if (!item)
                    continue
                item.parent = grid
                item.Layout.fillWidth = true
                item.Layout.fillHeight = true
                item.Layout.preferredWidth = Qt.binding(() => !root.sideBySide ? root.width
                                                              : item === root.main ? d.mainWidth : d.sideWidth)
            }
        }
    }

    GridLayout {
        id: grid
        anchors.left: parent.left
        anchors.right: parent.right
        columns: root.sideBySide ? 2 : 1
        columnSpacing: Theme.spacing.large
        rowSpacing: Theme.spacing.large
    }
}
