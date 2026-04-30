import QtQuick
import QtQuick.Controls

import Logos.Theme

Menu {
    id: root

    property color borderColor: Theme.palette.border
    property color backgroundColor: Theme.palette.backgroundSecondary

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias backgroundItem: bg

    padding: Theme.spacing.tiny

    background: Rectangle {
        id: bg
        implicitWidth: 200
        color: root.backgroundColor
        border.color: root.borderColor
        radius: Theme.spacing.radiusSmall
    }
}
