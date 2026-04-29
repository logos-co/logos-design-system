import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Icons

// Public API:
//     totalCount        total number of items across all pages (>= 0)
//     pageSize          items shown per page (>= 1, default 20)
//     currentPage       1-based selected page (clamped internally)
//     siblingCount      pages shown on each side of currentPage (default 1)
//     boundaryCount     pages pinned at start/end (default 1)
//     showFirstLast     whether « / » buttons render (default true)
//     showPrevNext      whether ‹ / › buttons render (default true)
//     pageInfoText      optional label shown left of the controls (empty hides)
//     pageSizeOptions   list<int> of available page sizes (empty hides selector)
//     pageSizeLabel     suffix appended to the size in the chip (default "/ page")
//     iconColor         tint applied to the four nav arrow icons
//
//     pageCount         (read-only) derived as max(1, ceil(totalCount / pageSize))
//
// Read-only inspection aliases:
//     infoLabel, firstButton, prevButton, nextButton, lastButton,
//     pagesItem (the Row of cells/ellipses), pageCells (the Repeater),
//     pageSizeSelector (the LogosComboBox), _d (private state)
//
// Signals:
//     pageRequested(int page)         user clicked a page entry / arrow
//     pageSizeRequested(int size)     user picked a different page size
//
// Example:
//     LogosPaginator {
//         totalCount: backend.totalCount
//         pageSize: backend.pageSize
//         currentPage: backend.currentPage
//         pageInfoText: qsTr("Showing %1–%2 of %3")
//                            .arg((currentPage - 1) * pageSize + 1)
//                            .arg(Math.min(currentPage * pageSize, totalCount))
//                            .arg(totalCount)
//         pageSizeOptions: [10, 20, 50, 100]
//         onPageRequested:     function(page) { backend.fetchPage(page) }
//         onPageSizeRequested: function(size) { backend.setPageSize(size) }
//     }
Control {
    id: root

    property int totalCount: 0
    property int pageSize: 20
    property int currentPage: 1
    property int siblingCount: 1
    property int boundaryCount: 1
    property bool showFirstLast: true
    property bool showPrevNext: true
    property string pageInfoText: ""
    property var pageSizeOptions: []        // empty array hides the selector
    property string pageSizeLabel: "/ page"
    property color iconColor: Theme.palette.textSecondary

    readonly property int pageCount: Math.max(
        1, Math.ceil(totalCount / Math.max(1, pageSize)))

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias infoLabel: infoLabelText
    readonly property alias firstButton: firstBtn
    readonly property alias prevButton: prevBtn
    readonly property alias nextButton: nextBtn
    readonly property alias lastButton: lastBtn
    readonly property alias pagesItem: pagesRow
    readonly property alias pageCells: cellRepeater
    readonly property alias pageSizeSelector: sizeSelector
    readonly property alias _d: d 

    signal pageRequested(int page)
    signal pageSizeRequested(int size)

    QtObject {
        id: d

        // Computes the array of page entries to render. Numbers are page
        // indices; the string "…" is a non-clickable ellipsis between
        // ranges. Single-page gaps render the page itself instead of an
        // ellipsis-of-one (industry-standard truncation; MUI/Ant Design).
        function computedPages() {
            const n = Math.max(1, root.pageCount)
            const c = Math.max(1, Math.min(root.currentPage, n))
            const s = Math.max(0, root.siblingCount)
            const b = Math.max(0, root.boundaryCount)

            if (n <= 2 * b + 2 * s + 3) {
                const out = []
                for (let i = 1; i <= n; i++) out.push(i)
                return out
            }

            const leftWindow  = Math.max(c - s, b + 1)
            const rightWindow = Math.min(c + s, n - b)
            const out = []

            for (let i = 1; i <= b; i++) out.push(i)

            if (leftWindow >= b + 3)            out.push("…")
            else if (leftWindow === b + 2)      out.push(b + 1)

            for (let i = leftWindow; i <= rightWindow; i++) out.push(i)

            if (rightWindow <= n - b - 2)       out.push("…")
            else if (rightWindow === n - b - 1) out.push(n - b)

            for (let i = n - b + 1; i <= n; i++) out.push(i)
            return out
        }

        function request(page) {
            const p = Math.max(1, Math.min(page, root.pageCount))
            root.pageRequested(p)
        }

        // Display strings for the page-size selector ("20 / page", "50 / page", …).
        function sizeOptionLabels() {
            const opts = root.pageSizeOptions
            if (!opts || opts.length === 0)
                return []
            const suffix = root.pageSizeLabel.length > 0
                           ? " " + root.pageSizeLabel
                           : ""
            return opts.map(function(n) { return n + suffix })
        }

        function requestSize(index) {
            const opts = root.pageSizeOptions
            if (!opts || index < 0 || index >= opts.length)
                return
            root.pageSizeRequested(opts[index])
        }
    }

    implicitHeight: 36

    background: Item {}

    contentItem: RowLayout {
        spacing: Theme.spacing.small

        LogosText {
            id: infoLabelText
            visible: root.pageInfoText.length > 0
            text: root.pageInfoText
            font.pixelSize: Theme.typography.secondaryText
            color: Theme.palette.textMuted
            Layout.alignment: Qt.AlignVCenter
        }

        Item { Layout.fillWidth: true }   // spacer pushes controls to the right

        LogosIconButton {
            id: firstBtn
            iconSource: LogosIcons.arrowLeftDouble
            iconColor: root.iconColor
            size: 36
            visible: root.showFirstLast
            enabled: root.currentPage > 1
            background: Item {}
            onClicked: d.request(1)
        }
        LogosIconButton {
            id: prevBtn
            iconSource: LogosIcons.arrowLeft
            iconColor: root.iconColor
            size: 36
            visible: root.showPrevNext
            enabled: root.currentPage > 1
            background: Item {}
            onClicked: d.request(root.currentPage - 1)
        }

        Row {
            id: pagesRow
            spacing: Theme.spacing.small

            Repeater {
                id: cellRepeater
                model: d.computedPages()

                delegate: Item {
                    width: 36
                    height: 36

                    readonly property bool isEllipsis: typeof modelData === "string"
                    readonly property bool isActive: !isEllipsis && modelData === root.currentPage

                    // Cell background — only rendered for number entries.
                    Rectangle {
                        anchors.fill: parent
                        visible: !parent.isEllipsis
                        radius: Theme.spacing.radiusLarge

                        color: parent.isActive
                               ? Theme.palette.surfaceContrast
                               : Theme.palette.surfaceRecessed
                        border.width: parent.isActive ? 0 : 1
                        border.color: Theme.palette.borderStrong

                        MouseArea {
                            id: cellMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            enabled: !parent.parent.isActive
                            onClicked: d.request(modelData)
                        }
                    }

                    LogosText {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: Theme.typography.primaryText
                        font.weight: Theme.typography.weightMedium
                        color: parent.isActive
                               ? Theme.palette.backgroundBlack
                               : Theme.palette.textMuted
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        LogosIconButton {
            id: nextBtn
            iconSource: LogosIcons.arrowRight
            iconColor: root.iconColor
            size: 36
            visible: root.showPrevNext
            enabled: root.currentPage < root.pageCount
            background: Item {}
            onClicked: d.request(root.currentPage + 1)
        }
        LogosIconButton {
            id: lastBtn
            iconSource: LogosIcons.arrowRightDouble
            iconColor: root.iconColor
            size: 36
            visible: root.showFirstLast
            enabled: root.currentPage < root.pageCount
            background: Item {}
            onClicked: d.request(root.pageCount)
        }

        Item {
            Layout.fillWidth: true
        }

        LogosComboBox {
            id: sizeSelector
            visible: root.pageSizeOptions && root.pageSizeOptions.length > 0
            implicitHeight: 36
            Layout.preferredWidth: 130
            Layout.alignment: Qt.AlignVCenter

            textColor: Theme.palette.textMuted
            indicatorColor: root.iconColor

            background: Rectangle {
                color: Theme.palette.surfaceRecessed
                radius: Theme.spacing.radiusLarge
                border.color: Theme.palette.borderStrong
                border.width: 1
            }

            model: d.sizeOptionLabels()
            currentIndex: root.pageSizeOptions
                          ? root.pageSizeOptions.indexOf(root.pageSize)
                          : -1
            onActivated: function(index) { d.requestSize(index) }
        }
    }

}
