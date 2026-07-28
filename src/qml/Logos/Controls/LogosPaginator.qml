import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

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
// Keyboard (nav cluster: first/prev/pages/next/last):
//     Tab moves between stops; ←/→ move focus among enabled nav controls;
//     Space/Enter activate (IconButton / page cell). Page-size combo is a
//     separate Tab stop. Focus stays in the cluster when «/‹ disable or page
//     cells rebuild after a page change (does not jump back to the window top).
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
    property color iconColor: Theme.palette.text

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

        // Keyboard focus retention across page changes (disabled «/‹, rebuilt cells).
        property bool retainNavFocus: false
        property bool expectFocusRestore: false
        property int lastNavIndex: 0

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
            // Activating «/‹/page may disable the focused control or rebuild
            // page cells — keep keyboard focus inside the nav cluster.
            if (navClusterHasFocus())
                expectFocusRestore = true
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

        // Enabled first/prev/page cells/next/last — arrow keys move among these.
        function focusableNavItems() {
            const items = []
            if (firstBtn.visible && firstBtn.enabled)
                items.push(firstBtn)
            if (prevBtn.visible && prevBtn.enabled)
                items.push(prevBtn)
            for (let i = 0; i < cellRepeater.count; ++i) {
                const cell = cellRepeater.itemAt(i)
                if (cell && !cell.isEllipsis && cell.enabled)
                    items.push(cell)
            }
            if (nextBtn.visible && nextBtn.enabled)
                items.push(nextBtn)
            if (lastBtn.visible && lastBtn.enabled)
                items.push(lastBtn)
            return items
        }

        function navClusterHasFocus() {
            const items = focusableNavItems()
            for (let i = 0; i < items.length; ++i) {
                if (items[i].activeFocus)
                    return true
            }
            // Focus may still be on a nav button that just became disabled
            // (before Qt clears it), or briefly on a dying page-cell delegate.
            if (firstBtn.activeFocus || prevBtn.activeFocus
                    || nextBtn.activeFocus || lastBtn.activeFocus)
                return true
            return false
        }

        function restoreNavFocus() {
            const items = focusableNavItems()
            if (items.length === 0)
                return
            // Prefer the current page cell so landing on page 1 keeps a clear target.
            for (let i = 0; i < cellRepeater.count; ++i) {
                const cell = cellRepeater.itemAt(i)
                if (cell && cell.isCurrent && !cell.isEllipsis) {
                    cell.forceActiveFocus(Qt.TabFocusReason)
                    return
                }
            }
            const idx = Math.max(0, Math.min(lastNavIndex, items.length - 1))
            items[idx].forceActiveFocus(Qt.TabFocusReason)
        }

        function isUnderPaginator(item) {
            let p = item
            while (p) {
                if (p === root)
                    return true
                p = p.parent
            }
            return false
        }

        function scheduleFocusRestore() {
            Qt.callLater(function() {
                if (!expectFocusRestore && !retainNavFocus)
                    return
                if (navClusterHasFocus()) {
                    expectFocusRestore = false
                    return
                }
                if (sizeSelector.activeFocus) {
                    expectFocusRestore = false
                    retainNavFocus = false
                    return
                }
                // Page change we initiated (Space on «/‹/cell): always put focus
                // back. Do not treat "focus cleared to the window" as Tab-away.
                if (expectFocusRestore) {
                    expectFocusRestore = false
                    restoreNavFocus()
                    return
                }
                // Soft retain: only restore if focus evaporated; if it moved to
                // another control outside this paginator, drop retention.
                const win = root.Window.window
                const afi = win ? win.activeFocusItem : null
                if (afi && !isUnderPaginator(afi)) {
                    retainNavFocus = false
                    return
                }
                restoreNavFocus()
            })
        }

        function trackNavFocus(item, focused) {
            if (focused) {
                retainNavFocus = true
                const items = focusableNavItems()
                for (let i = 0; i < items.length; ++i) {
                    if (items[i] === item) {
                        lastNavIndex = i
                        break
                    }
                }
                return
            }
            // Lost focus from a nav item — restore only when the cluster emptied
            // because a control disabled / delegate rebuilt (no outside focus).
            Qt.callLater(function() {
                if (navClusterHasFocus())
                    return
                if (sizeSelector.activeFocus) {
                    retainNavFocus = false
                    expectFocusRestore = false
                    return
                }
                const win = root.Window.window
                const afi = win ? win.activeFocusItem : null
                if (afi && !isUnderPaginator(afi)) {
                    retainNavFocus = false
                    expectFocusRestore = false
                    return
                }
                if (expectFocusRestore || retainNavFocus)
                    scheduleFocusRestore()
            })
        }

        function moveFocus(delta) {
            const items = focusableNavItems()
            if (items.length === 0)
                return false
            let idx = -1
            for (let i = 0; i < items.length; ++i) {
                if (items[i].activeFocus) {
                    idx = i
                    break
                }
            }
            if (idx < 0)
                return false
            const next = idx + delta
            if (next < 0 || next >= items.length)
                return false
            // TabFocusReason so Control.visualFocus stays true across ←/→.
            // Bare forceActiveFocus() uses OtherFocusReason and clears the ring.
            items[next].forceActiveFocus(Qt.TabFocusReason)
            lastNavIndex = next
            retainNavFocus = true
            return true
        }

        // Shared ←/→ handler for IconButton / page-cell Keys.onLeft/RightPressed.
        // Always accept so storybook Flickable does not steal ← at the first
        // item and scroll focus away.
        function handleNavKey(event) {
            if (event.key === Qt.Key_Left) {
                moveFocus(-1)
                event.accepted = true
            } else if (event.key === Qt.Key_Right) {
                moveFocus(1)
                event.accepted = true
            }
        }

        // visualFocus (not activeFocus): keyboard-only ring, consistent with
        // other controls. moveFocus / restore use TabFocusReason so ←/→ keeps
        // visualFocus true.
        function navFocusBorderWidth(button) {
            return button.visualFocus ? 2 : 0
        }
    }

    onCurrentPageChanged: d.scheduleFocusRestore()

    implicitHeight: 36
    focusPolicy: Qt.NoFocus
    activeFocusOnTab: false

    background: Item {}

    contentItem: RowLayout {
        spacing: Theme.spacing.small

        LogosText {
            id: infoLabelText
            Layout.alignment: Qt.AlignVCenter
            Layout.minimumWidth: 0
            visible: root.pageInfoText.length > 0
            text: root.pageInfoText
            font.pixelSize: Theme.typography.secondaryText
            color: Theme.palette.textMuted
            elide: Text.ElideRight
        }

        Item { Layout.fillWidth: true }

        LogosIconButton {
            id: firstBtn
            Layout.fillWidth: true
            Layout.minimumWidth: 24
            Layout.maximumWidth: 36
            iconSource: LogosIcons.arrowLeftDouble
            iconColor: root.iconColor
            size: 36
            flat: true
            focusPolicy: Qt.StrongFocus
            activeFocusOnTab: true
            visible: root.showFirstLast
            enabled: root.currentPage > 1
            background: Rectangle {
                color: "transparent"
                radius: Theme.spacing.radiusLarge
                border.width: d.navFocusBorderWidth(firstBtn)
                border.color: Theme.palette.overlayOrange
            }
            onClicked: d.request(1)
            Keys.onLeftPressed: function(event) { d.handleNavKey(event) }
            Keys.onRightPressed: function(event) { d.handleNavKey(event) }
            onActiveFocusChanged: d.trackNavFocus(firstBtn, activeFocus)
        }
        LogosIconButton {
            id: prevBtn
            Layout.fillWidth: true
            Layout.minimumWidth: 24
            Layout.maximumWidth: 36
            iconSource: LogosIcons.arrowLeft
            iconColor: root.iconColor
            size: 36
            flat: true
            focusPolicy: Qt.StrongFocus
            activeFocusOnTab: true
            visible: root.showPrevNext
            enabled: root.currentPage > 1
            background: Rectangle {
                color: "transparent"
                radius: Theme.spacing.radiusLarge
                border.width: d.navFocusBorderWidth(prevBtn)
                border.color: Theme.palette.overlayOrange
            }
            onClicked: d.request(root.currentPage - 1)
            Keys.onLeftPressed: function(event) { d.handleNavKey(event) }
            Keys.onRightPressed: function(event) { d.handleNavKey(event) }
            onActiveFocusChanged: d.trackNavFocus(prevBtn, activeFocus)
        }

        Row {
            id: pagesRow
            spacing: Theme.spacing.small

            Repeater {
                id: cellRepeater
                model: d.computedPages()

                delegate: AbstractButton {
                    id: pageCell
                    width: 36
                    height: 36

                    readonly property bool isEllipsis: typeof modelData === "string"
                    readonly property bool isCurrent: !isEllipsis && modelData === root.currentPage

                    // Current page is focusable so ←/→ can land on it; ellipsis is not.
                    focusPolicy: isEllipsis ? Qt.NoFocus : Qt.StrongFocus
                    activeFocusOnTab: !isEllipsis
                    enabled: !isEllipsis
                    checkable: false

                    onClicked: {
                        if (!isEllipsis && !isCurrent)
                            d.request(modelData)
                    }

                    Keys.onLeftPressed: function(event) { d.handleNavKey(event) }
                    Keys.onRightPressed: function(event) { d.handleNavKey(event) }
                    onActiveFocusChanged: d.trackNavFocus(pageCell, activeFocus)

                    background: Rectangle {
                        visible: !pageCell.isEllipsis
                        radius: Theme.spacing.radiusLarge
                        color: pageCell.isCurrent
                               ? Theme.palette.surfaceContrast
                               : (pageCell.pressed
                                  ? Theme.palette.pressed
                                  : Theme.palette.surfaceRecessed)
                        border.width: pageCell.visualFocus ? 2 : (pageCell.isCurrent ? 0 : 1)
                        border.color: pageCell.visualFocus
                                      ? Theme.palette.overlayOrange
                                      : Theme.palette.borderStrong
                    }

                    contentItem: LogosText {
                        text: modelData
                        font.pixelSize: Theme.typography.primaryText
                        font.weight: Theme.typography.weightMedium
                        color: pageCell.isCurrent
                               ? Theme.palette.backgroundBlack
                               : Theme.palette.textMuted
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    HoverHandler {
                        enabled: !pageCell.isEllipsis && !pageCell.isCurrent
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }

        LogosIconButton {
            id: nextBtn
            Layout.fillWidth: true
            Layout.minimumWidth: 24
            Layout.maximumWidth: 36
            iconSource: LogosIcons.arrowRight
            iconColor: root.iconColor
            size: 36
            flat: true
            focusPolicy: Qt.StrongFocus
            activeFocusOnTab: true
            visible: root.showPrevNext
            enabled: root.currentPage < root.pageCount
            background: Rectangle {
                color: "transparent"
                radius: Theme.spacing.radiusLarge
                border.width: d.navFocusBorderWidth(nextBtn)
                border.color: Theme.palette.overlayOrange
            }
            onClicked: d.request(root.currentPage + 1)
            Keys.onLeftPressed: function(event) { d.handleNavKey(event) }
            Keys.onRightPressed: function(event) { d.handleNavKey(event) }
            onActiveFocusChanged: d.trackNavFocus(nextBtn, activeFocus)
        }
        LogosIconButton {
            id: lastBtn
            Layout.fillWidth: true
            Layout.minimumWidth: 24
            Layout.maximumWidth: 36
            iconSource: LogosIcons.arrowRightDouble
            iconColor: root.iconColor
            size: 36
            flat: true
            focusPolicy: Qt.StrongFocus
            activeFocusOnTab: true
            visible: root.showFirstLast
            enabled: root.currentPage < root.pageCount
            background: Rectangle {
                color: "transparent"
                radius: Theme.spacing.radiusLarge
                border.width: d.navFocusBorderWidth(lastBtn)
                border.color: Theme.palette.overlayOrange
            }
            onClicked: d.request(root.pageCount)
            Keys.onLeftPressed: function(event) { d.handleNavKey(event) }
            Keys.onRightPressed: function(event) { d.handleNavKey(event) }
            onActiveFocusChanged: d.trackNavFocus(lastBtn, activeFocus)
        }

        Item {
            Layout.fillWidth: true
        }

        LogosComboBox {
            id: sizeSelector
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.minimumWidth: 80
            Layout.preferredWidth: 130
            Layout.maximumWidth: 130
            visible: root.pageSizeOptions && root.pageSizeOptions.length > 0
            implicitHeight: 36

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
            onActiveFocusChanged: {
                if (activeFocus) {
                    d.retainNavFocus = false
                    d.expectFocusRestore = false
                }
            }
        }
    }

}
