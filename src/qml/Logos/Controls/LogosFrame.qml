import QtQuick
import QtQuick.Controls

import Logos.Theme

Frame {
    id: root

    property color borderColor: Theme.palette.border
    property color backgroundColor: Theme.palette.surface

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias backgroundItem: bg

    padding: Theme.spacing.medium

    background: Rectangle {
        id: bg
        color: root.backgroundColor
        border.color: root.borderColor
        border.width: 1
        radius: Theme.spacing.radiusSmall
    }
}
