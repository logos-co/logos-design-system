import QtQuick
import QtQuick.Controls

import Logos.Theme

Slider {
    id: root

    property color trackColor: Theme.palette.backgroundSecondary
    property color fillColor: Theme.palette.primary
    property color handleColor: Theme.palette.primary

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias trackItem: track
    readonly property alias fillItem: fill
    readonly property alias handleItem: handle

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitHandleWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitHandleHeight + topPadding + bottomPadding,
                             Theme.touch ? Theme.size.touchTarget : 0)

    focusPolicy: Qt.StrongFocus
    activeFocusOnTab: true

    background: Rectangle {
        id: track
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: Theme.controls.slider.width
        implicitHeight: Theme.controls.slider.trackHeight
        width: root.availableWidth
        height: Theme.controls.slider.trackHeight
        radius: Theme.spacing.radiusTiny
        color: root.trackColor

        Rectangle {
            id: fill
            width: root.visualPosition * parent.width
            height: parent.height
            color: root.fillColor
            radius: Theme.spacing.radiusTiny
        }
    }

    handle: Rectangle {
        id: handle
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: Theme.controls.slider.handleSize
        implicitHeight: Theme.controls.slider.handleSize
        radius: width / 2
        color: root.pressed ? Theme.palette.primaryPressed : root.handleColor
        border.color: root.visualFocus ? Theme.palette.overlayOrange : Theme.palette.border
        border.width: root.visualFocus ? Theme.size.focusWidth : Theme.size.borderWidth
    }
}
