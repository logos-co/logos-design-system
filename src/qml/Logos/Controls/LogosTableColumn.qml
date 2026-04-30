import QtQuick

// Public API:
//     title             header text shown to the user
//     role              model role/property to bind for the default cell renderer
//     sortable          if true, header click cycles sort order and emits
//                       LogosTable.sortRequested(role, order)
//
//     minWidth          floor width in px; columns never go narrower than this
//                       (default 80)
//     preferredWidth    target width when the table has enough room
//                       (default = minWidth)
//     maxWidth          upper bound; -1 = unbounded (default -1)
//     fillWidth         if true, this column absorbs leftover horizontal space
//                       when the table is wider than the sum of preferred widths
//
//     alignment         text alignment for the default cell + header (default
//                       Qt.AlignLeft | Qt.AlignVCenter)
//
//     cellDelegate      Component for rendering each body cell. Receives
//                       `rowItem` (the model row) and `columnDef` (this object)
//                       as context properties. Null = default text cell.
//     headerCellDelegate  Component for rendering the header cell. Same context
//                         properties. Null = default title + sort icon.
//
// Example:
//     LogosTableColumn {
//         title: qsTr("Status")
//         role: "status"
//         minWidth: 120
//         preferredWidth: 120
//         cellDelegate: Component { StatusBadge { modelData: rowItem } }
//     }
QtObject {
    id: column

    property string title: ""
    property string role: ""
    property bool sortable: false

    property int minWidth: 80
    property int preferredWidth: minWidth
    property int maxWidth: -1
    property bool fillWidth: false

    property int alignment: Qt.AlignLeft | Qt.AlignVCenter

    property Component cellDelegate: null
    property Component headerCellDelegate: null
}
