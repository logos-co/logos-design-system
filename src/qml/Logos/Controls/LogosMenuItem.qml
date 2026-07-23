import QtQuick
import QtQuick.Controls

import Logos.Theme
import Logos.Controls

MenuItem {
    id: root

    property color highlightColor: Theme.palette.surface

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias labelItem: label
    readonly property alias backgroundItem: bg

    implicitHeight: 32

    contentItem: LogosText {
        id: label
        leftPadding: Theme.spacing.medium
        rightPadding: Theme.spacing.medium
        verticalAlignment: Text.AlignVCenter
        text: root.text
        color: root.enabled ? Theme.palette.text : Theme.palette.textMuted
    }

    background: Rectangle {
        id: bg
        radius: Theme.spacing.radiusSmall
        color: root.highlighted ? root.highlightColor : "transparent"
    }

    HoverHandler {
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
}
