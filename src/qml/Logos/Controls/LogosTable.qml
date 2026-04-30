import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Icons


// Public API summary:
//     model, columns, loading, empty, emptyText
//     selectionMode, selectedIndices, allSelected
//     sortRole, sortOrder
//     rowHeight, headerHeight
//     rowDelegate, headerDelegate, emptyDelegate, loadingDelegate
//     view (read-only alias to inner ListView)
//
// Signals: rowClicked, rowDoubleClicked, selectionChanged, headerClicked,
//          sortRequested
//
// Sizing: each LogosTableColumn declares minWidth and (optional) preferredWidth /
// maxWidth / fillWidth. Wider than total preferred -> columns at preferredWidth,
// fillWidth columns absorb leftover. Between min and preferred -> columns shrink
// proportionally. Narrower than total min -> columns pinned to minWidth and a
// horizontal scrollbar appears; the header scrolls with the body.
//
// Sorting is consumer-driven. Clicking a sortable header cycles sortOrder and
// emits sortRequested(role, order)
//
// Selection (when selectionMode !== None): a checkbox column is auto-prepended
// at index 0. In Multi mode the header gets a select-all checkbox.
//
// Example:
//     LogosTable {
//         model: packages
//         selectionMode: LogosTable.Multi
//         onSortRequested: (role, order) => backend.applySort(role, order)
//         columns: [
//             LogosTableColumn { title: qsTr("Name");   role: "name";   minWidth: 150; preferredWidth: 220; sortable: true },
//             LogosTableColumn { title: qsTr("Status"); role: "status"; minWidth: 120; cellDelegate: badgeComponent }
//         ]
//     }
Rectangle {
    id: root

    enum SelectionMode { None, Single, Multi }

    // ─── Properties: model + columns ───
    property var model: null
    property list<QtObject> columns: []

    // ─── Properties: state ───
    property bool loading: false
    property bool empty: d._isModelEmpty()
    property string emptyText: qsTr("No items")

    // ─── Properties: selection ───
    property int selectionMode: LogosTable.None
    property var selectedIndices: []
    readonly property bool allSelected: selectedIndices.length > 0
                                        && d._modelCount > 0
                                        && selectedIndices.length === d._modelCount

    // ─── Properties: sort state (consumer-driven) ───
    property string sortRole: ""
    property int sortOrder: Qt.AscendingOrder

    // ─── Properties: dimensions ───
    property int rowHeight: 64
    property int headerHeight: 36

    // ─── Properties: overrides ───
    property Component rowDelegate: null
    property Component headerDelegate: null
    property Component emptyDelegate: null
    property Component loadingDelegate: null

    // ─── Read-only inspection alias ───
    readonly property alias view: list

    // ─── Signals ───
    signal rowClicked(int index, var row)
    signal rowDoubleClicked(int index, var row)
    signal selectionChanged()
    signal headerClicked(string role)
    signal sortRequested(string role, int order)

    property QtObject d: QtObject {
        id: d

        readonly property var effectiveColumns: {
            return root.selectionMode !== LogosTable.None
                ? [_selectionColumn].concat(root.columns)
                : root.columns
        }

        readonly property int totalMinWidth: {
            var s = 0
            for (var i = 0; i < effectiveColumns.length; i++) s += effectiveColumns[i].minWidth
            return s
        }

        readonly property int _modelCount: {
            if (!root.model) return 0
            if (root.model.count !== undefined) return root.model.count
            if (root.model.length !== undefined) return root.model.length
            return 0
        }

        property LogosTableColumn _selectionColumn: LogosTableColumn {
            minWidth: 40
            preferredWidth: 40
            maxWidth: 40
            cellDelegate: _selectionCell
            headerCellDelegate: _selectionHeader
        }

        function _isModelEmpty() {
            return _modelCount === 0
        }

        function _toggleRow(idx) {
            var copy = selectedIndices.slice()
            var pos = copy.indexOf(idx)
            if (root.selectionMode === LogosTable.Single) {
                copy = pos >= 0 ? [] : [idx]
            } else {
                if (pos >= 0) copy.splice(pos, 1)
                else copy.push(idx)
            }
            root.selectedIndices = copy
            root.selectionChanged()
        }

        function _toggleAll() {
            if (root.allSelected) {
                root.selectedIndices = []
            } else {
                var all = []
                for (var i = 0; i < d._modelCount; i++) all.push(i)
                root.selectedIndices = all
            }
            root.selectionChanged()
        }

        function _onHeaderClick(col) {
            root.headerClicked(col.role)
            if (col.sortable && col.role !== "") {
                var nextOrder = (root.sortRole === col.role
                                 && root.sortOrder === Qt.AscendingOrder)
                                ? Qt.DescendingOrder : Qt.AscendingOrder
                root.sortRequested(col.role, nextOrder)
            }
        }

        function _isSelected(idx) {
            return selectedIndices.indexOf(idx) >= 0
        }

        function _maxWidthOrInf(col) {
            return col.maxWidth >= 0 ? col.maxWidth : Number.POSITIVE_INFINITY
        }
    }

    color: "transparent"
    clip: true

    Flickable {
        id: hScroll
        anchors.fill: parent
        contentWidth: Math.max(width, d.totalMinWidth)
        contentHeight: height
        flickableDirection: Flickable.HorizontalFlick
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AsNeeded }

        Column {
            width: hScroll.contentWidth

            Rectangle {
                id: header
                width: parent.width
                height: root.headerHeight
                visible: root.headerDelegate === null
                color: Theme.palette.backgroundButton
                radius: Theme.spacing.radiusLarge
                clip: true

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Repeater {
                        model: d.effectiveColumns

                        Loader {
                            Layout.minimumWidth: modelData.minWidth
                            Layout.preferredWidth: modelData.preferredWidth
                            Layout.maximumWidth: d._maxWidthOrInf(modelData)
                            Layout.fillWidth: modelData.fillWidth
                            Layout.fillHeight: true

                            property var columnDef: modelData
                            property int columnIndex: index

                            sourceComponent: columnDef.headerCellDelegate || _defaultHeaderCell
                        }
                    }
                }
            }

            Loader {
                width: parent.width
                visible: root.headerDelegate !== null
                sourceComponent: root.headerDelegate
            }

            ListView {
                id: list
                width: parent.width
                height: hScroll.height - (header.visible ? header.height : 0)
                model: root.model
                clip: true
                interactive: !root.loading
                boundsBehavior: Flickable.StopAtBounds

                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                delegate: Loader {
                    width: ListView.view.width
                    height: root.rowHeight

                    property var rowItem: model
                    property int rowIndex: index

                    sourceComponent: root.rowDelegate || _defaultRowDelegate
                }
            }
        }
    }

    // ─── Empty state overlay ───
    Loader {
        anchors.centerIn: parent
        active: root.empty && !root.loading
        sourceComponent: root.emptyDelegate || _defaultEmptyDelegate
    }

    // ─── Loading state overlay ───
    Loader {
        anchors.centerIn: parent
        active: root.loading
        sourceComponent: root.loadingDelegate || _defaultLoadingDelegate
    }

    // ─── Default sub-components ───
    Component {
        id: _defaultHeaderCell

        Item {
            readonly property bool _isSorted: columnDef.role !== ""
                                              && columnDef.role === root.sortRole
            readonly property bool _isAscending: _isSorted
                                                 && root.sortOrder === Qt.AscendingOrder

            Rectangle {
                anchors.fill: parent
                color: Theme.colors.getColor(Theme.palette.backgroundInset, 0.6)
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.medium
                anchors.rightMargin: Theme.spacing.medium
                spacing: Theme.spacing.tiny

                Item {
                    Layout.fillWidth: (columnDef.alignment & Qt.AlignRight)
                                      || (columnDef.alignment & Qt.AlignHCenter)
                }

                LogosText {
                    text: columnDef.title
                    color: Theme.palette.textSecondary
                    font.pixelSize: Theme.typography.secondaryText
                    font.weight: Theme.typography.weightMedium
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                Image {
                    visible: columnDef.sortable
                    source: LogosIcons.upDown
                    sourceSize.width: 20
                    sourceSize.height: 20
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    opacity: parent.parent._isSorted ? 1.0 : 0.5
                    rotation: parent.parent._isAscending ? 180 : 0
                    Behavior on rotation { NumberAnimation { duration: 120 } }
                }

                Item {
                    Layout.fillWidth: !(columnDef.alignment & Qt.AlignRight)
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: columnDef.sortable ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: d._onHeaderClick(columnDef)
            }
        }
    }

    Component {
        id: _defaultRowDelegate

        Item {
            id: _rowRoot
            readonly property var capturedRowItem: rowItem
            readonly property int capturedRowIndex: rowIndex

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Repeater {
                    model: d.effectiveColumns

                    Loader {
                        Layout.minimumWidth: modelData.minWidth
                        Layout.preferredWidth: modelData.preferredWidth
                        Layout.maximumWidth: d._maxWidthOrInf(modelData)
                        Layout.fillWidth: modelData.fillWidth
                        Layout.fillHeight: true

                        property var columnDef: modelData
                        property int columnIndex: index
                        property var rowItem: _rowRoot.capturedRowItem
                        property int rowIndex: _rowRoot.capturedRowIndex

                        sourceComponent: columnDef.cellDelegate || _defaultBodyCell
                    }
                }
            }

            MouseArea {
                id: rowMouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton
                onClicked: root.rowClicked(_rowRoot.capturedRowIndex, _rowRoot.capturedRowItem)
                onDoubleClicked: root.rowDoubleClicked(_rowRoot.capturedRowIndex, _rowRoot.capturedRowItem)
                z: -1
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: Theme.palette.borderTertiaryMuted
            }
        }
    }

    Component {
        id: _defaultBodyCell

        Item {
            LogosText {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.medium
                anchors.rightMargin: Theme.spacing.medium
                text: rowItem && columnDef.role !== "" ? (rowItem[columnDef.role] || "") : ""
                color: Theme.palette.text
                font.pixelSize: Theme.typography.primaryText
                horizontalAlignment: (columnDef.alignment & Qt.AlignHCenter) ? Text.AlignHCenter
                                   : (columnDef.alignment & Qt.AlignRight)   ? Text.AlignRight
                                   : Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }
    }

    Component {
        id: _selectionCell

        Item {
            LogosCheckbox {
                anchors.centerIn: parent
                checked: d._isSelected(rowIndex)
                onClicked: d._toggleRow(rowIndex)
            }
        }
    }

    Component {
        id: _selectionHeader

        Item {
            Rectangle {
                anchors.fill: parent
                color: Theme.colors.getColor(Theme.palette.backgroundInset, 0.6)
            }

            LogosCheckbox {
                anchors.centerIn: parent
                visible: root.selectionMode === LogosTable.Multi
                checked: root.allSelected
                onClicked: d._toggleAll()
            }
        }
    }

    Component {
        id: _defaultEmptyDelegate

        LogosText {
            text: root.emptyText
            color: Theme.palette.textSecondary
            font.pixelSize: Theme.typography.primaryText
        }
    }

    Component {
        id: _defaultLoadingDelegate

        LogosSpinner {
            running: root.loading
        }
    }
}
