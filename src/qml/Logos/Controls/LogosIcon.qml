import QtQuick
import QtQuick.Effects

import Logos.Theme

// LogosIcon — a colorized icon image.
//
// Wraps an Image + MultiEffect so the SVG/PNG silhouette is recolored at
// render time without modifying the asset. Extracts the pattern previously
// inlined in LogosIconButton / LogosComboBox / LogosSearchBar / LogosTabButton.
//
// Public API:
//     source   URL of the icon asset (PNG/SVG). Empty renders nothing.
//     color    tint applied via MultiEffect colorization. Default = Theme.palette.text.
//
// Read-only inspection aliases:
//     imageItem    the underlying Image (hidden; source of the effect)
//     effectItem   the MultiEffect doing the colorization
//
// Sizing: control the icon's footprint by setting width/height (or letting
// the parent layout). The default implicit size is 20×20 to match the
// existing inline call sites. sourceSize is auto-2× the rendered size for
// hidpi sharpness — no configuration needed.
//
// Example:
//     LogosIcon {
//         source: LogosIcons.refresh
//         color: Theme.palette.accentOrange
//         width: 24; height: 24
//     }
Item {
    id: root

    property url   source: ""
    property color color: Theme.palette.text

    readonly property alias imageItem: img
    readonly property alias effectItem: effect

    implicitWidth: 20
    implicitHeight: 20

    Image {
        id: img
        anchors.fill: parent
        source: root.source
        sourceSize: Qt.size(Math.max(1, parent.width * 2),
                            Math.max(1, parent.height * 2))
        fillMode: Image.PreserveAspectFit
        visible: false
    }

    MultiEffect {
        id: effect
        anchors.fill: img
        source: img
        colorization: 1.0
        colorizationColor: root.color
    }
}
