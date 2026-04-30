import QtQuick
import QtQuick.Controls

import Logos.Theme
import Logos.Controls

ItemDelegate {
    id: root

    property color hoverColor: Theme.palette.hover
    property color pressedColor: Theme.palette.pressed
    property color highlightColor: Theme.colors.getColor(Theme.palette.primary, 0.18)

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias backgroundItem: bg
    readonly property alias labelItem: label

    implicitHeight: 36

    contentItem: LogosText {
        id: label
        text: root.text
        leftPadding: Theme.spacing.medium
        rightPadding: Theme.spacing.medium
        verticalAlignment: Text.AlignVCenter
        color: root.enabled ? Theme.palette.text : Theme.palette.textMuted
        elide: Text.ElideRight
    }

    background: Rectangle {
        id: bg
        color: root.pressed
               ? root.pressedColor
               : (root.highlighted
                    ? root.highlightColor
                    : (root.hovered ? root.hoverColor : "transparent"))
    }
}
