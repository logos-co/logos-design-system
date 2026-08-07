import QtQuick
import QtQuick.Controls

import Logos.Theme

// LogosTile — a square, clickable tile showing artwork or a monogram.
//
// Generic on purpose: it renders any square subject that has a picture and a
// name, falling back to two letters when the picture is missing. Basecamp
// uses it for application tiles, but nothing in it knows about applications
// or packages — see `fallbackColor` for the one place that could have leaked.
//
// Extends LogosAbstractButton, so its mouse and keyboard behaviour is
// identical to LogosButton's by construction rather than by copy.
//
// Public API:
//     label          drives the monogram fallback and Accessible.name
//     source         URL of the artwork (PNG). Empty → monogram
//     fallbackColor  plate colour when there is no artwork. Defaults to the
//                    theme grey. Callers wanting a per-item colour compute it
//                    and pass it in
//     tileSize       edge length in px
//     radius         corner radius; artwork is masked to it
//     highlighted    force hovered chrome (selected/current tile)
//     dimOpacity     externally-driven dim (e.g. not-yet-loaded plugins)
//
// Inherited: pressed, isActive, clicked(), mouseAreaItem
// Read-only: hasArtwork, monogram
//
// State model — pressed wins over hovered, matching LogosButton:
//
//     idle     surface                 #343434  borderSubtle   1.00
//     hovered  surfaceInteractiveHover #434343  border         1.00  +0.08
//     pressed  surfaceRaised           #232323  borderStrong   0.96  -0.06
//
// Monotonic and evenly spaced against the page (#171717) so each state
// is perceptible on a dark screen. Note `surfaceRaised` is DARKER than
// `surface` in this palette, which is why it reads as the pressed step.
//
// The plate is only visible where the artwork is transparent, and on the
// monogram tile — so the ring, brightness and scale carry the feedback for
// opaque artwork.
//
// Example:
//     LogosTile {
//         label: model.displayName
//         source: model.iconUrl
//         fallbackColor: model.isInstalled ? Theme.palette.surface
//                                          : AppColors.colorForApp(model.name)
//         tileSize: 80
//         onClicked: launch(model.name)
//     }
LogosAbstractButton {
    id: root

    property string label: ""
    property url source: ""
    property color fallbackColor: Theme.palette.surface
    // Forces the hovered chrome without a pointer — for a selected/current
    // tile (basecamp's sidebar marks the active app this way). Pressed still
    // wins over it.
    property bool highlighted: false
    property int tileSize: 40
    property real radius: Theme.spacing.radiusMedium
    property real dimOpacity: 1.0

    readonly property bool hasArtwork: source.toString().length > 0
    // What the tile is actually showing. Bound to the children's `visible`,
    // and assertable in tests — Item.visible is effective visibility (the AND
    // of the ancestor chain) and reports false offscreen even when correct.
    readonly property bool showsArtwork: hasArtwork
    readonly property bool showsMonogram: !hasArtwork
    readonly property string monogram:
        (label || "?").substring(0, 2).toUpperCase()

    // Read-only inspection aliases (tests / tooling only).
    readonly property alias plateItem: plate
    readonly property alias artworkItem: artwork
    readonly property alias monogramItem: monogramText

    QtObject {
        id: d

        readonly property bool isPressed: root.enabled && root.pressed
        readonly property bool isHovered:
            root.enabled && (root.hovered || root.highlighted) && !d.isPressed

        readonly property color plateColor: {
            if (!root.hasArtwork)
                return root.fallbackColor
            if (d.isPressed) return Theme.palette.surfaceRaised
            if (d.isHovered) return Theme.palette.surfaceInteractiveHover
            return Theme.palette.surface
        }

        readonly property color ringColor: {
            if (d.isPressed) return Theme.palette.borderStrong
            if (d.isHovered) return Theme.palette.border
            return Theme.palette.borderSubtle
        }

        readonly property real artworkBrightness:
            d.isPressed ? -0.06 : (d.isHovered ? 0.08 : 0)

    }

    implicitWidth: tileSize
    implicitHeight: tileSize
    padding: 0
    opacity: dimOpacity * (enabled ? 1.0 : 0.4)
    Behavior on opacity { NumberAnimation { duration: 150 } }

    scale: d.isPressed ? 0.96 : 1.0
    Behavior on scale { enabled: root.interactive; NumberAnimation { duration: 90 } }

    Accessible.name: root.label

    background: Rectangle {
        id: plate
        radius: root.radius
        color: d.plateColor
        border.width: 1
        border.color: d.ringColor
        Behavior on color { enabled: root.interactive; ColorAnimation { duration: 120 } }
        Behavior on border.color { enabled: root.interactive; ColorAnimation { duration: 120 } }
    }

    contentItem: Item {
        LogosArtwork {
            id: artwork
            anchors.fill: parent
            anchors.margins: plate.border.width
            source: root.source
            radius: Math.max(0, root.radius - plate.border.width)
            brightness: d.artworkBrightness
            Behavior on brightness { enabled: root.interactive; NumberAnimation { duration: 120 } }
            visible: root.showsArtwork
        }

        LogosText {
            id: monogramText
            anchors.centerIn: parent
            text: root.monogram
            font.pixelSize: Math.round(root.tileSize * 0.375)
            font.weight: Theme.typography.weightBold
            color: Theme.palette.text
            visible: root.showsMonogram
        }
    }
}
