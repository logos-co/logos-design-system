import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Icons
import Logos.Controls

Rectangle {
    id: page
    property string figmaUrl: ""

    // Consumer-owned sort state, fed back into the table for icon display.
    property string currentSortRole: ""
    property int currentSortOrder: Qt.AscendingOrder

    color: Theme.palette.background

  
    implicitHeight: contentColumn.implicitHeight + 2 * Theme.spacing.xxlarge

    // frameWidth wide, or as wide as there is room for.
    component Frame: ColumnLayout {
        id: frame
        property int frameWidth: 390
        property int frameHeight: 360
        property string note: ""
        default property alias content: holder.data
        width: parent ? Math.min(frame.frameWidth, parent.width) : frame.frameWidth
        spacing: Theme.spacing.tiny
        LogosText {
            text: Math.round(box.width) + " px, " + frame.note
            font.pixelSize: Theme.typography.secondaryText
            color: Theme.palette.textSecondary
        }
        Rectangle {
            id: box
            Layout.fillWidth: true
            Layout.preferredHeight: frame.frameHeight
            color: Theme.palette.backgroundSecondary
            border.color: Theme.palette.borderSubtle
            Item {
                id: holder
                anchors.fill: parent
                anchors.margins: Theme.spacing.large
            }
        }
    }

    // Minimum widths 120 + 80 + 160 + 110 = 470.
    component NarrowTable: LogosTable {
        anchors.fill: parent
        columns: [
            LogosTableColumn { title: qsTr("Package");     role: "name";        minWidth: 120; preferredWidth: 160 },
            LogosTableColumn { title: qsTr("Type");        role: "type";        minWidth: 80;  preferredWidth: 100; priority: 2 },
            LogosTableColumn { title: qsTr("Description"); role: "description"; minWidth: 160; fillWidth: true; priority: 1 },
            LogosTableColumn { title: qsTr("Status");      role: "status";      minWidth: 110; preferredWidth: 130 }
        ]
    }

    component Heading: LogosText {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        font.pixelSize: Theme.typography.primaryText
        font.weight: Theme.typography.weightBold
        color: Theme.palette.text
    }

    component Note: LogosText {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        font.pixelSize: Theme.typography.secondaryText
        color: Theme.palette.textSecondary
    }

    component StatusBadge: LogosBadge {
        required property string status
        text: status
        color: status === "Installed" ? Theme.palette.success
             : status === "Upgrade" ? Theme.palette.info
             : status === "Failed" ? Theme.palette.error
             : Theme.palette.textSecondary
    }

    // A table with a detail: beside it on a desktop, a sheet over its right
    // side on a tablet, and on a phone cards and a full-page detail with ‹.
    // The detail has every field, so the columns the table drops for room
    // are still there. A tap opens a row, ⋯ has its actions.
    component PackagesWithDetail: Item {
        id: pattern
        anchors.fill: parent

        property string openName: ""
        readonly property string widthClass: Theme.windowClass(width)
        readonly property var openRow: {
            for (let i = 0; i < packages.count; ++i)
                if (packages.get(i).name === openName)
                    return packages.get(i)
            return null
        }

        RowLayout {
            anchors.fill: parent
            visible: !(pattern.widthClass === "phone" && pattern.openRow)
            spacing: Theme.spacing.medium

            LogosTable {
                id: table
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: packages
                phoneCards: true
                rowsOpen: true
                onRowClicked: (index, row) => pattern.openName = row.name
                rowMenu: LogosMenu {
                    LogosMenuItem { text: qsTr("Open details"); onTriggered: pattern.openName = table.menuRow.name }
                    LogosMenuItem { text: qsTr("Uninstall") }
                }
                columns: [
                    LogosTableColumn { title: qsTr("Package");     role: "name";        minWidth: 120; preferredWidth: 160; fillWidth: true },
                    LogosTableColumn { title: qsTr("Type");        role: "type";        minWidth: 80;  priority: 2 },
                    LogosTableColumn { title: qsTr("Description"); role: "description"; minWidth: 200; priority: 1; card: "hidden" },
                    LogosTableColumn {
                        title: qsTr("Status"); role: "status"; minWidth: 120; card: "badge"
                        // Sized by its badge, so a card can show it too.
                        cellDelegate: Item {
                            implicitWidth: badge.implicitWidth
                            implicitHeight: badge.implicitHeight
                            StatusBadge { id: badge; anchors.verticalCenter: parent.verticalCenter; status: rowItem.status }
                        }
                    }
                ]
            }

            PackageDetail {
                owner: pattern
                visible: pattern.widthClass === "desktop" && pattern.openRow !== null
                Layout.preferredWidth: 280
                Layout.fillHeight: true
            }
        }

        PackageDetail {
            owner: pattern
            visible: pattern.widthClass === "tablet" && pattern.openRow !== null
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: Math.min(320, parent.width * 0.75)
        }

        PackageDetail {
            owner: pattern
            visible: pattern.widthClass === "phone" && pattern.openRow !== null
            anchors.fill: parent
        }
    }

    // The detail of PackagesWithDetail's open package.
    component PackageDetail: Rectangle {
        id: detail
        required property Item owner
        color: Theme.palette.backgroundSecondary
        border.color: Theme.palette.borderSubtle
        radius: Theme.spacing.radiusLarge

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacing.large
            spacing: Theme.spacing.small

            RowLayout {
                Layout.fillWidth: true
                LogosIconButton {
                    visible: detail.owner.widthClass === "phone"
                    size: Theme.size.touchTarget
                    flat: true
                    iconSource: LogosIcons.arrowLeft
                    Accessible.name: qsTr("Back")
                    onClicked: detail.owner.openName = ""
                }
                LogosText {
                    Layout.fillWidth: true
                    text: detail.owner.openRow ? detail.owner.openRow.name : ""
                    font.pixelSize: Theme.typography.panelTitleText
                    font.weight: Theme.typography.weightBold
                    elide: Text.ElideRight
                }
                LogosIconButton {
                    visible: detail.owner.widthClass !== "phone"
                    size: Theme.size.touchTarget
                    flat: true
                    iconSource: LogosIcons.close
                    Accessible.name: qsTr("Close")
                    onClicked: detail.owner.openName = ""
                }
            }

            StatusBadge { status: detail.owner.openRow ? detail.owner.openRow.status : "" }

            Repeater {
                model: [[qsTr("Type"), "type"], [qsTr("Description"), "description"]]
                ColumnLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.topMargin: Theme.spacing.small
                    spacing: Theme.spacing.tiny
                    LogosText {
                        text: modelData[0]
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                    LogosText {
                        Layout.fillWidth: true
                        text: detail.owner.openRow ? detail.owner.openRow[modelData[1]] : ""
                        wrapMode: Text.Wrap
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    // Sample data — a list of fake "packages" for the table to render.
    ListModel {
        id: packages
        ListElement { name: "chat-ui";       type: "ui_qml"; description: "Decentralised messaging UI";        status: "Installed" }
        ListElement { name: "wallet-ui";     type: "ui_qml"; description: "Multi-chain wallet front-end";      status: "Upgrade" }
        ListElement { name: "node-ui";       type: "ui_qml"; description: "Node management dashboard";         status: "Not Installed" }
        ListElement { name: "storage";       type: "core";   description: "Local + remote storage backend";    status: "Installed" }
        ListElement { name: "package-mgr";   type: "core";   description: "Install and remove packages";       status: "Installed" }
        ListElement { name: "search";        type: "core";   description: "Indexes and queries local content"; status: "Failed" }
        ListElement { name: "telemetry";     type: "core";   description: "Anonymous metrics collection";      status: "Not Installed" }
        ListElement { name: "scheduler";     type: "core";   description: "Background task scheduler";         status: "Installed" }
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xxlarge

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.small

            LogosText {
                text: "LogosTable"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Note {
                text: "1. Every column has a minWidth; too narrow for them all, the table scrolls sideways.\n"
                      + "2. Columns that can go have a priority; the highest number goes first.\n"
                      + "3. On a phone, phoneCards shows a card per row: the first column as the title, the "
                      + "rest under it; a column's card: \"badge\" or \"hidden\" places it.\n"
                      + "4. One tap opens a row (rowsOpen shows ›); nothing needs hover or a double-click.\n"
                      + "5. A row's actions are behind a visible ⋯ (rowMenu).\n"
                      + "6. What the table hides, the row's detail shows."
            }
        }

        // ─── 1. A table ───
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            Heading { text: "A table" }
            Note { text: "Click a header to sort. The sort is the app's: the table only shows it." }

            Flow {
                Layout.fillWidth: true
                spacing: Theme.spacing.large
                LogosCheckbox { id: selectRows; text: "Select rows" }
                LogosCheckbox { id: loadingBox; text: "Loading" }
                LogosCheckbox { id: emptyBox; text: "Empty" }
            }

            LogosTable {
                Layout.fillWidth: true
                Layout.preferredHeight: 320

                model: emptyBox.checked ? null : packages
                emptyText: qsTr("No packages installed")
                loading: loadingBox.checked
                selectionMode: selectRows.checked ? LogosTable.Multi : LogosTable.None
                sortRole: page.currentSortRole
                sortOrder: page.currentSortOrder
                onSortRequested: function(role, order) {
                    page.currentSortRole = role
                    page.currentSortOrder = order
                }

                columns: [
                    LogosTableColumn { title: qsTr("Package");     role: "name";        minWidth: 120; preferredWidth: 200; sortable: true },
                    LogosTableColumn { title: qsTr("Type");        role: "type";        minWidth: 80;  preferredWidth: 100; sortable: true },
                    LogosTableColumn { title: qsTr("Description"); role: "description"; minWidth: 160; fillWidth: true },
                    LogosTableColumn { title: qsTr("Status");      role: "status";      minWidth: 110; preferredWidth: 130; sortable: true }
                ]
            }
        }

        // ─── 2. Narrower ───
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            Heading { text: "Narrower" }
            Note { text: "Type has priority 2 and Description priority 1: Type goes first, then Description. On a phone, cards." }

            Flow {
                Layout.fillWidth: true
                spacing: Theme.spacing.large

                Frame { frameWidth: 500; note: "Type dropped"; NarrowTable { model: packages; selectionMode: selectRows.checked ? LogosTable.Multi : LogosTable.None } }
                Frame { frameWidth: 390; note: "Type and Description dropped"; NarrowTable { model: packages; selectionMode: selectRows.checked ? LogosTable.Multi : LogosTable.None } }
                Frame { frameWidth: 390; note: "a phone: cards"; NarrowTable { model: packages; phoneCards: true; selectionMode: selectRows.checked ? LogosTable.Multi : LogosTable.None } }
            }
        }

        // ─── 3. With ⋯ and a detail ───
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            Heading { text: "With ⋯ and a detail" }
            Note {
                text: "A tap opens a package; ⋯ has its actions. The detail is beside the table on a desktop, "
                      + "over its right side on a tablet, and the whole page on a phone. It has every field, so "
                      + "nothing the table drops is lost. On the cards, Status is a badge and Description is left off."
            }

            Flow {
                Layout.fillWidth: true
                spacing: Theme.spacing.large

                Frame { frameWidth: 1000; frameHeight: 420; note: "a desktop"; PackagesWithDetail { openName: "wallet-ui" } }
                Frame { frameWidth: 700; frameHeight: 420; note: "a tablet"; PackagesWithDetail { openName: "wallet-ui" } }
                Frame { frameWidth: 390; frameHeight: 520; note: "a phone: tap a card"; PackagesWithDetail {} }
            }
        }
    }
}
