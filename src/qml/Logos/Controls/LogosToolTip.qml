import QtQuick
import QtQuick.Controls

import Logos.Theme

// Direct-instantiation tooltip with a directional arrow. Set `placement` to
// pick which side of the parent the tip appears on; the arrow is a square
// rotated 45° and centered on the matching bubble edge, so half of it sits
// hidden behind the bubble and the other half pokes out as a triangle
// pointing back at the parent.
//
//     LogosText {
//         text: "Hover me"
//         HoverHandler { id: hover }
//
//         LogosToolTip {
//             text: "Hint"
//             placement: LogosToolTip.Top
//             visible: hover.hovered
//         }
//     }
//
// At touch density, where there is no hover, a long-press on the parent opens
// the tip and a tap closes it. On a Logos control that long-press is then not
// also a click. Set `openOnLongPress: false` for a tip the control opens
// itself. Don't let a tip be the only place something is said.
//
// The text is plain, as LogosText's is; set `textFormat: Text.StyledText` for
// markup of your own.
//
ToolTip {
    id: root

    // Placement values are aligned with Popup.TransformOrigin because
    // LogosToolTip.Top/Left/Right/Bottom is ambiguous with that inherited
    // C++ enum. Internals compare against raw values (never the symbolic
    // names) so a wrong resolution cannot silently break placement.
    enum Placement {
        Top    = 1,
        Left   = 3,
        Right  = 5,
        Bottom = 7
    }

    // Default is Placement.Top (=1). Do not write LogosToolTip.Top here —
    // see enum NOTE above.
    property int placement: 1
    property color tipColor: Theme.palette.backgroundSecondary
    property color textColor: Theme.colors.getColor(Theme.palette.text, 0.6)
    property int textFormat: Text.PlainText
    // Consumer-supplied position in the tooltip's parent coordinate space.
    // Leave `undefined` for auto placement driven by `placement`; set a
    // number to pin. Either axis can be manual independently.
    property var manualX: undefined
    property var manualY: undefined
    property bool openOnLongPress: true

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias backgroundItem: bubble
    readonly property alias labelItem: label
    readonly property alias tailItem: tail

    QtObject {
        id: d

        readonly property int tailSize: Math.round(root.implicitHeight * 0.4)
        readonly property int tailGap: Theme.spacing.tiny
        readonly property int tailOffset: tailSize / 2 + tailGap
        readonly property int tailRadius: Math.max(1, Math.round(tailSize / 8))

        readonly property real targetX: {
            // Depend on visible: a popup's implicit parent (QObject parent)
            // can be assigned without a parentChanged signal, so re-evaluate
            // whenever the tip is shown.
            void root.visible
            if (!root.parent)
                return 0
            switch (root.placement) {
            case 1: // Top
            case 7: return (root.parent.width - root.implicitWidth) / 2 // Bottom
            case 3: return -root.implicitWidth - tailOffset             // Left
            case 5: return root.parent.width + tailOffset               // Right
            }
            return 0
        }
        readonly property real targetY: {
            void root.visible
            if (!root.parent)
                return 0
            switch (root.placement) {
            case 1: return -root.implicitHeight - tailOffset // Top
            case 7: return root.parent.height + tailOffset   // Bottom
            case 3: // Left
            case 5: return (root.parent.height - root.implicitHeight) / 2 // Right
            }
            return 0
        }
    }

    // Popup's own layout code writes `x`/`y` when the popup opens, which
    // silently overrides any consumer-set declarative binding. An always-
    // active Binding element defeats that write (Qt restores bound
    // properties after external C++ writes). Value picks the consumer's
    // manual value when set, or the placement-derived value otherwise.
    Binding {
        target: root
        property: "x"
        value: root.manualX !== undefined ? root.manualX : d.targetX
    }
    Binding {
        target: root
        property: "y"
        value: root.manualY !== undefined ? root.manualY : d.targetY
    }

    // Made only while it is wanted, on an item of its own under the parent's
    // content: a pointer handler makes its item take presses, even disabled
    // and after it is gone, so on the parent itself it would stop the clicks
    // meant for what is under it.
    Component {
        id: longPressComponent
        Item {
            required property ToolTip tip
            anchors.fill: parent
            z: -1
            TapHandler {
                onLongPressed: parent.tip.open()
                onTapped: if (parent.tip.visible) parent.tip.close()
            }
        }
    }

    QtObject {
        id: longPress
        readonly property bool wanted: root.openOnLongPress && Theme.touch && !!root.parent && root.text.length > 0
        property QtObject handler: null
        onWantedChanged: sync()

        function sync() {
            if (handler && (!wanted || handler.parent !== root.parent)) {
                handler.destroy()
                handler = null
            }
            if (wanted && !handler)
                handler = longPressComponent.createObject(root.parent, { tip: root })
        }
    }
    onParentChanged: longPress.sync()
    Component.onCompleted: longPress.sync()
    Component.onDestruction: if (longPress.handler) longPress.handler.destroy()

    delay: 200
    timeout: 5000
    margins: -1
    horizontalPadding: Theme.controls.toolTip.paddingX
    verticalPadding: Theme.controls.toolTip.paddingY
    implicitHeight: Theme.controls.toolTip.height

    background: Item {
        Rectangle {
            id: bubble
            anchors.fill: parent
            color: root.tipColor
            radius: Theme.spacing.radiusSmall
        }

        Rectangle {
            id: tail
            width: d.tailSize
            height: d.tailSize
            radius: d.tailRadius
            rotation: 45
            color: root.tipColor

            x: {
                switch (root.placement) {
                case 1: // Top
                case 7: return (parent.width - width) / 2 // Bottom
                case 3: return parent.width - width / 2   // Left
                case 5: return -width / 2                 // Right
                }
                return 0
            }
            y: {
                switch (root.placement) {
                case 1: return parent.height - height / 2 // Top
                case 7: return -height / 2                // Bottom
                case 3: // Left
                case 5: return (parent.height - height) / 2 // Right
                }
                return 0
            }
        }
    }

    contentItem: Text {
        id: label
        text: root.text
        textFormat: root.textFormat
        color: root.textColor
        font.family: Theme.typography.publicSans
        font.weight: Theme.typography.weightBold
        font.pixelSize: Theme.typography.secondaryText
    }
}
