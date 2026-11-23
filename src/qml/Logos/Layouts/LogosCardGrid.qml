import QtQuick
import QtQuick.Layouts

import Logos.Theme

// LogosCardGrid — cards or tiles in as many equal columns as fit at
// minimumCellWidth, in a content area at most maximumWidth wide and centred.
// The columns come from the width the grid actually gets, not from the window
// class. The cards in a row are as tall as each other. While balanced, a card
// is never left alone on the last row if fewer columns (two or more) avoid it:
// four cards are four, two by two, or one, never three and one.
//
// Public API:
//     minimumCellWidth    a card's narrowest (default cardGrid.statCardWidth);
//                         for a catalogue of tiles, Theme.tileWidth(width)
//     maximumColumns      at most this many columns; 0 (default) for no limit
//     balanced            no lone card on the last row (default true); false for
//                         a catalogue, where a partly filled last row is normal
//     maximumWidth        the content's widest (default cardGrid.maximumWidth)
//     spacing             between the cards, across and down (default Theme.spacing.large)
//     columns             read-only; the columns in use
//     content (default)   the cards; a Repeater's are counted too
//
// Example:
//     LogosCardGrid {
//         Layout.fillWidth: true
//         LogosStatCard { label: qsTr("Peers"); value: "12" }
//         LogosStatCard { label: qsTr("Height"); value: "1,204,311" }
//     }
Item {
    id: root

    property real minimumCellWidth: Theme.layouts.cardGrid.statCardWidth
    property int maximumColumns: 0
    property bool balanced: true
    property real maximumWidth: Theme.layouts.cardGrid.maximumWidth
    property real spacing: Theme.spacing.large
    readonly property int columns: d.columns
    default property alias content: grid.data

    implicitWidth: Math.min(maximumWidth, Math.max(1, d.cards.length) * (minimumCellWidth + grid.columnSpacing) - grid.columnSpacing)
    implicitHeight: grid.implicitHeight

    QtObject {
        id: d

        readonly property var cards: {
            const items = []
            for (let i = 0; i < grid.children.length; ++i) {
                const child = grid.children[i]
                if (child.visible && !(child instanceof Repeater))
                    items.push(child)
            }
            return items
        }

        readonly property real contentWidth: Math.min(root.width, root.maximumWidth)

        readonly property int columns: {
            const count = cards.length
            let c = Math.max(1, Math.floor((contentWidth + grid.columnSpacing) / (root.minimumCellWidth + grid.columnSpacing)))
            if (root.maximumColumns > 0)
                c = Math.min(c, root.maximumColumns)
            c = Math.min(c, Math.max(1, count))
            while (root.balanced && c > 2 && count > c && count % c === 1)
                --c
            return c
        }

        readonly property real cellWidth: (contentWidth - (columns - 1) * grid.columnSpacing) / columns

        onCardsChanged: {
            for (let i = 0; i < cards.length; ++i) {
                cards[i].Layout.fillWidth = true
                cards[i].Layout.fillHeight = true
                cards[i].Layout.preferredWidth = Qt.binding(() => d.cellWidth)
            }
        }
    }

    GridLayout {
        id: grid
        x: (root.width - width) / 2
        width: d.contentWidth
        columns: d.columns
        columnSpacing: root.spacing
        rowSpacing: root.spacing
    }
}
