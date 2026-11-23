import QtQuick
import QtQml
import QtQuick.Layouts

import Logos.Theme

// LogosItemLayout — one line of an item, such as a list row, a header or a
// field and its button, that may become two. It arranges only: no
// background, padding, fonts or behaviour of its own. It measures itself and
// what it holds, never the width class, so it keeps one line wherever that
// fits:
//   leading   at the start, at their own sizes
//   content   (the default property) what the line is about; it takes the
//             room left, so its text elides or wraps there: the layout sets
//             each of its items' Layout.fillWidth, so cap one with
//             Layout.maximumWidth
//   meta      beside the content while the content keeps minimumContentWidth;
//             otherwise on lines under it, from where the content starts to
//             the end, under trailing too, so the last ends where trailing
//             does. There one with Layout.fillWidth takes the room left on its
//             line, up to its Layout.maximumWidth, and those that don't fit
//             start another line. On a line, they are centred on each other
//             unless one sets its own vertical Layout.alignment
//   trailing  at the end, at their own sizes, on the first line
// Once meta is under the content, leading and trailing align to the top.
// Hidden items take no room.
//
// Public API:
//     leading, meta, trailing     list<Item>
//     content (default)           the content
//     minimumContentWidth         what the content keeps before meta moves under it
//                                 (default Theme.layouts.itemLayout.minimumContentWidth)
//     spacing                     between the parts (default Theme.spacing.medium)
//     wrapped                     read-only; meta is under the content
//
// Example:
//     LogosItemLayout {
//         width: parent.width
//         leading: LogosTile { label: publisher.name; interactive: false }
//         ColumnLayout {
//             LogosText { Layout.fillWidth: true; text: publisher.name; elide: Text.ElideRight }
//             LogosText { Layout.fillWidth: true; text: publisher.url; elide: Text.ElideRight }
//         }
//         meta: [
//             LogosText { Layout.fillWidth: true; text: publisher.fingerprint; wrapMode: Text.Wrap },
//             LogosCopyButton { value: publisher.did }
//         ]
//         trailing: LogosIconButton { iconSource: LogosIcons.trash }
//     }
Item {
    id: root

    property list<Item> leading
    property list<Item> meta
    property list<Item> trailing
    property real minimumContentWidth: Theme.layouts.itemLayout.minimumContentWidth
    property real spacing: Theme.spacing.medium
    readonly property bool wrapped: d.wrapped
    default property alias content: contentColumn.data

    // An item's width in a layout: its Layout.preferredWidth, or its own.
    function preferredWidthOf(item) {
        return item.Layout.preferredWidth >= 0 ? item.Layout.preferredWidth : item.implicitWidth
    }

    implicitWidth: d.leadingWidth + contentColumn.implicitWidth + d.metaWidth + d.trailingWidth
                   + root.spacing * (d.leadingShown + d.metaShown + d.trailingShown)
    implicitHeight: grid.implicitHeight

    QtObject {
        id: d

        // Their width side by side, of the shown ones, each at the width a
        // layout gives it. Each stays in the place it was given, so whether
        // it shows is its own.
        function widthOf(items) {
            let width = 0
            let count = 0
            for (let i = 0; i < items.length; ++i) {
                if (items[i].visible) {
                    width += root.preferredWidthOf(items[i])
                    ++count
                }
            }
            return count > 0 ? width + (count - 1) * root.spacing : 0
        }

        readonly property real leadingWidth: widthOf(root.leading)
        readonly property real metaWidth: widthOf(root.meta)
        readonly property real trailingWidth: widthOf(root.trailing)
        readonly property int leadingShown: leadingWidth > 0 ? 1 : 0
        readonly property int metaShown: metaWidth > 0 ? 1 : 0
        readonly property int trailingShown: trailingWidth > 0 ? 1 : 0

        // What the content and meta share between leading and trailing.
        readonly property real middleWidth: root.width - leadingWidth - trailingWidth
                                            - root.spacing * (leadingShown + trailingShown)
        readonly property bool wrapped: metaShown === 1
                                        && middleWidth < root.minimumContentWidth + root.spacing + metaWidth
    }

    // Places meta: on one line at their own widths; or, under the content, in
    // lines where one with Layout.fillWidth takes the room left on its line.
    // On a line they are centred on each other, as text and a touch-sized
    // button need, unless one sets its own vertical Layout.alignment. Laid out at once, so no frame shows the old places;
    // a text given a width can grow taller, which lays them out once more.
    component MetaLine: Item {
        id: metaLine

        // What it places; also its children.
        property list<Item> items
        property bool under: false
        property real spacing: 0
        property real lineSpacing: 0
        property real naturalWidth: 0
        property real laidOutHeight: 0
        property var widthOf: item => item.implicitWidth
        property bool layingOut: false
        property bool again: false

        // What the places depend on: a binding, which goes with this object,
        // not connections that could call into it after it is gone. From
        // items, not children: read while it is being made, children places
        // the items, which changes what it measures in the middle of a layout.
        readonly property string measures: {
            const parts = []
            for (let i = 0; i < items.length; ++i) {
                const item = items[i]
                parts.push(item.visible, widthOf(item), item.Layout.alignment)
            }
            return parts.join(",")
        }

        // An item's height can follow the width this gives it, as a wrapping
        // text's or a folding row's does, so it lays the line out again from
        // a connection, not from measures: a binding laying out what it
        // depends on is a binding loop. The connections go with this object.
        Instantiator {
            model: metaLine.items
            delegate: Connections {
                required property Item modelData
                target: modelData
                function onImplicitHeightChanged() { metaLine.schedule() }
            }
        }

        implicitWidth: naturalWidth
        implicitHeight: laidOutHeight

        function schedule() {
            if (layingOut) {
                again = true
                return
            }
            layingOut = true
            let passes = 0
            do {
                again = false
                layOut()
            } while (again && ++passes < 3)
            layingOut = false
        }

        // Where an item sits on a line as tall as `height`.
        function offsetIn(item, height) {
            const alignment = item.Layout.alignment
            if (alignment & Qt.AlignTop)
                return 0
            if (alignment & Qt.AlignBottom)
                return height - item.height
            return (height - item.height) / 2
        }

        // A line's room left, shared out among those that fill, each up to
        // its Layout.maximumWidth; what one can't take, the others share.
        function shares(items, extra, basis) {
            const widths = items.map(basis)
            let open = items.map((item, i) => i).filter(i => items[i].Layout.fillWidth)
            while (extra > 0.5 && open.length > 0) {
                const share = extra / open.length
                const still = []
                for (const i of open) {
                    const most = items[i].Layout.maximumWidth
                    const room = most >= 0 && isFinite(most) ? most - widths[i] : Infinity
                    if (room <= share) {
                        widths[i] += Math.max(0, room)
                        extra -= Math.max(0, room)
                    } else {
                        still.push(i)
                    }
                }
                if (still.length === open.length) {
                    for (const i of open)
                        widths[i] += share
                    extra = 0
                }
                open = still
            }
            return widths
        }

        function layOut() {
            const shown = []
            for (let i = 0; i < metaLine.items.length; ++i)
                if (metaLine.items[i].visible)
                    shown.push(metaLine.items[i])

            if (!under) {
                let height = 0
                for (const item of shown)
                    height = Math.max(height, item.implicitHeight)
                let x = 0
                for (const item of shown) {
                    item.width = widthOf(item)
                    item.x = x
                    item.y = offsetIn(item, height)
                    x += item.width + spacing
                }
                laidOutHeight = height
                return
            }

            const basis = item => item.Layout.fillWidth ? item.Layout.minimumWidth : widthOf(item)
            const lines = []
            let line = [], used = 0
            for (const item of shown) {
                const room = (line.length > 0 ? spacing : 0) + basis(item)
                if (line.length > 0 && used + room > width) {
                    lines.push({ items: line, used: used })
                    line = []
                    used = 0
                }
                used += (line.length > 0 ? spacing : 0) + basis(item)
                line.push(item)
            }
            if (line.length > 0)
                lines.push({ items: line, used: used })

            let y = 0
            for (const each of lines) {
                const widths = shares(each.items, Math.max(0, width - each.used), basis)
                let x = 0, height = 0
                for (let i = 0; i < each.items.length; ++i) {
                    const item = each.items[i]
                    item.width = item.Layout.fillWidth ? widths[i] : Math.min(widthOf(item), width)
                    item.x = x
                    x += item.width + spacing
                    height = Math.max(height, item.height)
                }
                for (const item of each.items)
                    item.y = y + offsetIn(item, height)
                y += height + lineSpacing
            }
            laidOutHeight = Math.max(0, y - lineSpacing)
        }

        onUnderChanged: schedule()
        onWidthChanged: schedule()
        onMeasuresChanged: schedule()
    }

    GridLayout {
        id: grid
        anchors.fill: parent
        columnSpacing: 0
        rowSpacing: 0

        // A layout in a layout fills by default; these keep their own size.
        RowLayout {
            Layout.row: 0
            Layout.column: 0
            Layout.fillWidth: false
            Layout.fillHeight: false
            Layout.alignment: d.wrapped ? Qt.AlignTop : Qt.AlignVCenter
            spacing: root.spacing
            children: root.leading
        }

        ColumnLayout {
            id: contentColumn
            Layout.row: 0
            Layout.column: 1
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.minimumWidth: 0
            Layout.leftMargin: d.leadingShown ? root.spacing : 0
            Layout.alignment: d.wrapped ? Qt.AlignTop : Qt.AlignVCenter
            spacing: 0
            // The content takes the room left, so its text can elide or wrap.
            onChildrenChanged: {
                for (let i = 0; i < children.length; ++i)
                    children[i].Layout.fillWidth = true
            }
        }

        // Beside the content, or under it from where the content starts to
        // the end. It keeps its place in the grid, so meta never changes parent.
        MetaLine {
            Layout.row: d.wrapped ? 1 : 0
            Layout.column: d.wrapped ? 1 : 2
            Layout.columnSpan: d.wrapped ? 3 : 1
            Layout.fillWidth: d.wrapped
            Layout.preferredWidth: d.wrapped ? -1 : d.metaWidth
            Layout.leftMargin: d.wrapped ? (d.leadingShown ? root.spacing : 0)
                                         : (d.metaShown ? root.spacing : 0)
            Layout.topMargin: d.wrapped ? Theme.layouts.itemLayout.lineSpacing : 0
            Layout.alignment: d.wrapped ? Qt.AlignTop : Qt.AlignVCenter
            under: d.wrapped
            spacing: root.spacing
            lineSpacing: Theme.layouts.itemLayout.lineSpacing
            naturalWidth: d.metaWidth
            widthOf: root.preferredWidthOf
            items: root.meta
            children: root.meta
        }

        RowLayout {
            Layout.row: 0
            Layout.column: 3
            Layout.fillWidth: false
            Layout.fillHeight: false
            Layout.leftMargin: d.trailingShown ? root.spacing : 0
            Layout.alignment: d.wrapped ? Qt.AlignTop : Qt.AlignVCenter
            spacing: root.spacing
            children: root.trailing
        }
    }
}
