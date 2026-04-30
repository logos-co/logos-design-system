import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

Rectangle {
    id: page
    property string figmaUrl: ""

    // Consumer-owned sort state, fed back into the table for icon display.
    property string currentSortRole: ""
    property int currentSortOrder: Qt.AscendingOrder

    // Toggleable loading flag for the loading-state variant.
    property bool isLoading: true

    color: Theme.palette.background

  
    implicitHeight: contentColumn.implicitHeight + 2 * Theme.spacing.xxlarge

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
            spacing: Theme.spacing.tiny

            LogosText {
                text: "LogosTable"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: model, columns (LogosTableColumn[]), selectionMode, sortRole/sortOrder, "
                      + "rowDelegate/headerDelegate, loading, empty/emptyText. "
                      + "Signals: rowClicked, selectionChanged, sortRequested, headerClicked."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        // ─── Variant 1: default cells, no selection ───
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Default cells, sortable columns"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }

            LogosTable {
                id: defaultTable
                Layout.fillWidth: true
                Layout.preferredHeight: 320

                model: packages
                sortRole: page.currentSortRole
                sortOrder: page.currentSortOrder

                onSortRequested: function(role, order) {
                    // Consumer owns the sort. We just record it here so the
                    // header icons reflect the current state. A real consumer
                    // would also apply the sort to its model (proxy model,
                    // backend call, etc.).
                    page.currentSortRole = role
                    page.currentSortOrder = order
                }
                onRowClicked: function(idx, row) {
                    console.log("rowClicked", idx, row.name)
                }

                columns: [
                    LogosTableColumn { title: qsTr("Package");     role: "name";        minWidth: 120; preferredWidth: 200; sortable: true },
                    LogosTableColumn { title: qsTr("Type");        role: "type";        minWidth: 80;  preferredWidth: 100; sortable: true },
                    LogosTableColumn { title: qsTr("Description"); role: "description"; minWidth: 160; fillWidth: true },
                    LogosTableColumn { title: qsTr("Status");      role: "status";      minWidth: 110; preferredWidth: 130; sortable: true }
                ]
            }
        }

        // ─── Variant 2: multi-select with select-all ───
        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 320
            spacing: Theme.spacing.medium

            LogosText {
                text: "Multi-select (with select-all in header)"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }

            LogosTable {
                Layout.fillWidth: true
                Layout.preferredHeight: 280

                model: packages
                selectionMode: LogosTable.Multi

                onSelectionChanged: console.log("selectionChanged", selectedIndices)

                columns: [
                    LogosTableColumn { title: qsTr("Package");     role: "name";        minWidth: 120; preferredWidth: 200; sortable: true },
                    LogosTableColumn { title: qsTr("Description"); role: "description"; minWidth: 160; fillWidth: true },
                    LogosTableColumn { title: qsTr("Status");      role: "status";      minWidth: 110; preferredWidth: 130 }
                ]
            }
        }

        // ─── Variant 3: loading state ───
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.medium

                LogosText {
                    text: "Loading state"
                    font.pixelSize: Theme.typography.primaryText
                    font.weight: Theme.typography.weightBold
                    color: Theme.palette.text
                    Layout.fillWidth: true
                }

                LogosButton {
                    text: page.isLoading ? qsTr("Stop") : qsTr("Load")
                    onClicked: page.isLoading = !page.isLoading
                }
            }

            LogosTable {
                Layout.fillWidth: true
                Layout.preferredHeight: 280

                loading: page.isLoading
                model: packages
                columns: [
                    LogosTableColumn { title: qsTr("Package");     role: "name";        minWidth: 120; preferredWidth: 200 },
                    LogosTableColumn { title: qsTr("Description"); role: "description"; minWidth: 160; fillWidth: true },
                    LogosTableColumn { title: qsTr("Status");      role: "status";      minWidth: 110; preferredWidth: 130 }
                ]
            }
        }

        // ─── Variant 4: empty state ───
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Empty state"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }

            LogosTable {
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                model: ListModel {}
                emptyText: qsTr("No packages installed")
                columns: [
                    LogosTableColumn { title: qsTr("Package");     role: "name";        minWidth: 120; preferredWidth: 200; sortable: true },
                    LogosTableColumn { title: qsTr("Description"); role: "description"; minWidth: 160; fillWidth: true },
                    LogosTableColumn { title: qsTr("Status");      role: "status";      minWidth: 110; preferredWidth: 130 }
                ]
            }
        }
    }
}
