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
ToolTip {
    id: root

    enum Placement { Top, Bottom, Left, Right }

    property int placement: LogosToolTip.Top
    property color tipColor: Theme.palette.backgroundSecondary
    property color textColor: Theme.colors.getColor(Theme.palette.text, 0.6)

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias backgroundItem: bubble
    readonly property alias labelItem: label
    readonly property alias tailItem: tail

    QtObject {
        id: d
        readonly property int tailSize: Math.round(root.height * 0.4)
        readonly property int tailGap: 4
        readonly property int tailOffset: tailSize / 2 + tailGap
        readonly property int tailRadius: Math.max(1, Math.round(tailSize / 8))
    }

    delay: 200
    timeout: 5000
    horizontalPadding: 6
    verticalPadding: 2
    implicitHeight: 20

    x: {
        if (!parent) return 0
        switch (placement) {
        case LogosToolTip.Top:
        case LogosToolTip.Bottom: return (parent.width - width) / 2
        case LogosToolTip.Left:   return -width - d.tailOffset
        case LogosToolTip.Right:  return parent.width + d.tailOffset
        }
        return 0
    }
    y: {
        if (!parent) return 0
        switch (placement) {
        case LogosToolTip.Top:    return -height - d.tailOffset
        case LogosToolTip.Bottom: return parent.height + d.tailOffset
        case LogosToolTip.Left:
        case LogosToolTip.Right:  return (parent.height - height) / 2
        }
        return 0
    }

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
                case LogosToolTip.Top:
                case LogosToolTip.Bottom: return (parent.width - width) / 2
                case LogosToolTip.Left:   return parent.width - width / 2
                case LogosToolTip.Right:  return -width / 2
                }
                return 0
            }
            y: {
                switch (root.placement) {
                case LogosToolTip.Top:    return parent.height - height / 2
                case LogosToolTip.Bottom: return -height / 2
                case LogosToolTip.Left:
                case LogosToolTip.Right:  return (parent.height - height) / 2
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
