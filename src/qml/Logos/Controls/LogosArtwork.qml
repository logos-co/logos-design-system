import QtQuick
import QtQuick.Effects

import Logos.Theme

// LogosArtwork — a full-bleed, full-colour application icon.
//
// Deliberately NOT LogosIcon. LogosIcon wraps a MultiEffect with
// `colorization: 1.0`, which flattens its source to a single-colour
// silhouette — correct for chrome glyphs (LogosIcons.refresh and friends),
// fatally wrong for a package's own artwork. This component preserves the
// source's colours.
//
// Contract (see plan.md §3.4): packages ship an exactly 256x256 PNG intended
// to fill its tile edge to edge. `PreserveAspectCrop` enforces "fills the
// tile" even if an off-spec non-square image slips through — it crops rather
// than letterboxing, so no input can produce bars or a broken-looking tile.
//
// Transparency is never detected. Callers paint a backplate underneath and
// let an opaque icon cover it; see LogosTile / AppTile.
//
// Public API:
//     source      URL of the icon (PNG). Empty renders nothing.
//     radius      corner radius; the icon is masked to it. Default 0.
//     brightness  MultiEffect brightness, for hover lift. Default 0.
//
// Read-only inspection aliases:
//     imageItem   the underlying Image
//     effectItem  the MultiEffect doing the rounded mask + brightness
//
// Sizing: set width/height (or let the parent layout do it). sourceSize is
// auto-2x the rendered size, which is what keeps a 256px source from
// aliasing when drawn at 40px.
Item {
    id: root

    property url  source: ""
    property real radius: 0
    property real brightness: 0

    readonly property alias imageItem: img
    readonly property alias effectItem: effect
    readonly property alias maskItem: maskShape

    implicitWidth: 40
    implicitHeight: 40

    Image {
        id: img
        anchors.fill: parent
        source: root.source
        // 2x for hidpi sharpness — matches LogosIcon's approach.
        sourceSize: Qt.size(Math.max(1, parent.width * 2),
                            Math.max(1, parent.height * 2))
        // Full-bleed: crop, never letterbox.
        fillMode: Image.PreserveAspectCrop
        visible: false
    }

    Rectangle {
        id: maskShape
        anchors.fill: parent
        radius: root.radius
        color: "white"
        visible: false
        antialiasing: true
        layer.enabled: root.radius > 0
        layer.smooth: true
        layer.samples: 4
    }

    MultiEffect {
        id: effect
        anchors.fill: img
        source: img
        brightness: root.brightness
        maskEnabled: root.radius > 0
        maskSource: root.radius > 0 ? maskShape : null
    }
}
