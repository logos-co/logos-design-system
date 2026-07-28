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
ToolTip {
    id: root

    // Values aligned with Popup.TransformOrigin — see NOTE above.
    enum Placement {
        Top    = 1,
        Left   = 3,
        Right  = 5,
        Bottom = 7
    }

    property int placement: 1 // LogosToolTip.Top
    property color tipColor: Theme.palette.backgroundSecondary
    property color textColor: Theme.colors.getColor(Theme.palette.text, 0.6)

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias backgroundItem: bubble
    readonly property alias labelItem: label
    readonly property alias tailItem: tail

    QtObject {
        id: d

        readonly property int tailSize: Math.round(root.implicitHeight * 0.4)
        readonly property int tailGap: 4
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

    // Declaring plain `x:`/`y:` bindings here does NOT work reliably
    // Binding elements write through reliably.
    Binding {
        target: root
        property: "x"
        value: d.targetX
    }
    Binding {
        target: root
        property: "y"
        value: d.targetY
    }

    delay: 200
    timeout: 5000
    margins: -1
    horizontalPadding: 6
    verticalPadding: 2
    implicitHeight: 20

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
        color: root.textColor
        font.family: Theme.typography.publicSans
        font.weight: Theme.typography.weightBold
        font.pixelSize: Theme.typography.secondaryText
    }
}
