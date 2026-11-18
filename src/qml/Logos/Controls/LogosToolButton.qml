import QtQuick
import QtQuick.Controls

import Logos.Theme
import Logos.Controls

ToolButton {
    id: root

    property color hoverColor: Theme.palette.surface
    property color pressedColor: Theme.palette.pressed

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias labelItem: label
    readonly property alias backgroundItem: bg

    focusPolicy: Qt.StrongFocus
    activeFocusOnTab: true

    contentItem: LogosText {
        id: label
        text: root.text
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: root.enabled ? Theme.palette.text : Theme.palette.textMuted
    }

    background: Rectangle {
        id: bg
        implicitWidth: Theme.controls.toolButton.size
        implicitHeight: Theme.controls.toolButton.size
        radius: Theme.spacing.radiusSmall
        color: root.pressed
               ? root.pressedColor
               : (root.hovered || root.visualFocus ? root.hoverColor : "transparent")
        border.width: root.visualFocus ? Theme.size.borderWidth : 0
        border.color: Theme.palette.overlayOrange
    }

    HoverHandler {
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    }

    LongPressToolTips {
        control: root
    }
}
