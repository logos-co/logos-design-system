import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

Rectangle {
    property string figmaUrl: ""

    color: Theme.palette.background

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xxlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny

            LogosText {
                text: "LogosPaginator"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: totalCount, pageSize, currentPage, siblingCount, boundaryCount, showFirstLast, showPrevNext, pageInfoText, pageSizeOptions, pageRequested(int), pageSizeRequested(int)"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            LogosText {
                text: "The component is dumb about data — it just emits pageRequested(page); the consumer updates currentPage after their fetch resolves."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        // Variants
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Variants"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.palette.borderHairline
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.tiny
                LogosText {
                    text: "Small (30 items / 10 per page → 3 pages, no ellipsis)"
                    font.pixelSize: Theme.typography.secondaryText
                    color: Theme.palette.textTertiary
                }
                LogosPaginator {
                    Layout.fillWidth: true
                    totalCount: 30
                    pageSize: 10
                    currentPage: smallPager.value
                    onPageRequested: function(page) { smallPager.value = page }
                    QtObject { id: smallPager; property int value: 1 }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.tiny
                LogosText {
                    text: "Medium (150 items / 10 per page → 15 pages, current=8 — both ellipses)"
                    font.pixelSize: Theme.typography.secondaryText
                    color: Theme.palette.textTertiary
                }
                LogosPaginator {
                    Layout.fillWidth: true
                    totalCount: 150
                    pageSize: 10
                    currentPage: medPager.value
                    pageInfoText: qsTr("Showing %1–%2 of %3")
                                       .arg((medPager.value - 1) * 10 + 1)
                                       .arg(Math.min(medPager.value * 10, 150))
                                       .arg(150)
                    onPageRequested: function(page) { medPager.value = page }
                    QtObject { id: medPager; property int value: 8 }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.tiny
                LogosText {
                    text: "Large (1000 items / 10 per page → 100 pages, near start — single trailing ellipsis)"
                    font.pixelSize: Theme.typography.secondaryText
                    color: Theme.palette.textTertiary
                }
                LogosPaginator {
                    Layout.fillWidth: true
                    totalCount: 1000
                    pageSize: 10
                    currentPage: largePager.value
                    onPageRequested: function(page) { largePager.value = page }
                    QtObject { id: largePager; property int value: 2 }
                }
            }
        }

        // Try it
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Try it"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.palette.borderHairline
            }

            LogosPaginator {
                id: tryPager
                Layout.fillWidth: true
                totalCount: totalCountSpin.value
                pageSize: pageSizeState.value
                currentPage: currentPageSpin.value
                siblingCount: siblingSpin.value
                boundaryCount: boundarySpin.value
                showFirstLast: firstLastSwitch.checked
                showPrevNext: prevNextSwitch.checked
                pageInfoText: infoTextInput.text
                pageSizeOptions: showSizeSwitch.checked ? [10, 20, 50, 100] : []
                onPageRequested: function(page) {
                    requestCount.value++
                    lastRequested.text = "last requested: " + page
                    currentPageSpin.value = page
                }
                onPageSizeRequested: function(size) {
                    pageSizeState.value = size
                    lastSizeRequested.text = "last size requested: " + size
                }
                QtObject { id: pageSizeState; property int value: 20 }
            }

            ColumnLayout {
                spacing: Theme.spacing.small

                RowLayout {
                    spacing: Theme.spacing.small
                    LogosText {
                        text: "totalCount:"; Layout.preferredWidth: 140
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                    SpinBox { id: totalCountSpin; from: 0; to: 5000; value: 600; stepSize: 10 }
                    LogosText {
                        text: "→ pageCount: " + tryPager.pageCount
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                }
                RowLayout {
                    spacing: Theme.spacing.small
                    LogosText {
                        text: "currentPage:"; Layout.preferredWidth: 140
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                    SpinBox { id: currentPageSpin; from: 1; to: tryPager.pageCount; value: 5 }
                }
                RowLayout {
                    spacing: Theme.spacing.small
                    LogosText {
                        text: "siblingCount:"; Layout.preferredWidth: 140
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                    SpinBox { id: siblingSpin; from: 0; to: 5; value: 1 }
                }
                RowLayout {
                    spacing: Theme.spacing.small
                    LogosText {
                        text: "boundaryCount:"; Layout.preferredWidth: 140
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                    SpinBox { id: boundarySpin; from: 0; to: 3; value: 1 }
                }
                RowLayout {
                    spacing: Theme.spacing.small
                    Switch { id: firstLastSwitch; checked: true }
                    LogosText {
                        text: "show first / last"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                    Item { width: Theme.spacing.large }
                    Switch { id: prevNextSwitch; checked: true }
                    LogosText {
                        text: "show prev / next"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                    Item { width: Theme.spacing.large }
                    Switch { id: showSizeSwitch; checked: true }
                    LogosText {
                        text: "show page-size selector"
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                }
                RowLayout {
                    spacing: Theme.spacing.small
                    LogosText {
                        text: "pageInfoText:"; Layout.preferredWidth: 140
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                    LogosTextField {
                        id: infoTextInput
                        text: "Showing 41–50 of 300"
                        implicitWidth: 280
                    }
                }
                RowLayout {
                    spacing: Theme.spacing.small
                    LogosText {
                        text: "request count:"; Layout.preferredWidth: 140
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                    LogosText {
                        id: requestCount
                        property int value: 0
                        text: value
                        font.pixelSize: Theme.typography.secondaryText
                        font.weight: Theme.typography.weightBold
                        color: Theme.palette.text
                    }
                }
                LogosText {
                    id: lastRequested
                    text: "(no request yet)"
                    font.pixelSize: Theme.typography.secondaryText
                    color: Theme.palette.textTertiary
                }
                LogosText {
                    id: lastSizeRequested
                    text: "(no size change yet)"
                    font.pixelSize: Theme.typography.secondaryText
                    color: Theme.palette.textTertiary
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
