import QtQuick

import Logos.Theme

// LogosSidebarLayout — a page's content with a sidebar on its left, such as a
// catalog's categories, while the content keeps minimumContentWidth beside
// it; otherwise the content alone. It measures itself, never the width class,
// and has no look of its own. While the sidebar is hidden, the app offers what
// it holds another way, read from sideShown: a sidebar of filters becomes
// pickers over the content, as filters are not navigation to hide behind ☰.
//
// Public API:
//     side                  the sidebar; one replaced or cleared is taken out
//     content (default)     the content; it fills what the sidebar leaves
//     sideWidth             the sidebar's width (default Theme.layouts.sidebarLayout.sideWidth)
//     minimumContentWidth   what the content keeps before the sidebar goes
//                           (default Theme.layouts.sidebarLayout.minimumContentWidth)
//     spacing               between them (default Theme.spacing.medium)
//     sideShown             read-only; the sidebar is beside the content
//
// Read-only inspection aliases: sideAreaItem, contentAreaItem.
//
// Example:
//     LogosSidebarLayout {
//         id: body
//         side: CategoryList { model: catalog.categories }
//         Catalog {
//             anchors.fill: parent
//             filterPickersShown: !body.sideShown
//         }
//     }
Item {
    id: root

    property Item side: null
    property int sideWidth: Theme.layouts.sidebarLayout.sideWidth
    property int minimumContentWidth: Theme.layouts.sidebarLayout.minimumContentWidth
    property real spacing: Theme.spacing.medium
    readonly property bool sideShown: side !== null && width >= sideWidth + spacing + minimumContentWidth
    default property alias content: contentArea.data

    readonly property alias sideAreaItem: sideArea
    readonly property alias contentAreaItem: contentArea

    implicitWidth: sideWidth + spacing + minimumContentWidth

    onSideChanged: {
        if (d.shownSide && d.shownSide !== side)
            d.shownSide.parent = null
        if (side) {
            side.parent = sideArea
            side.anchors.fill = sideArea
        }
        d.shownSide = side
    }

    QtObject {
        id: d
        property Item shownSide: null
    }

    Item {
        id: sideArea
        visible: root.sideShown
        width: root.sideWidth
        height: root.height
    }

    Item {
        id: contentArea
        x: root.sideShown ? root.sideWidth + root.spacing : 0
        width: root.width - x
        height: root.height
    }
}
