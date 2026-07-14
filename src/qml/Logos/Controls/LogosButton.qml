import QtQuick
import QtQuick.Controls

import Logos.Theme

Control {
    id: root

    property alias text: label.text
    property real radius: Theme.spacing.radiusXlarge
    property bool isPrimary: false
    property url iconSource: ""
    property string iconPosition: "left" // "left" | "right"
    property int iconSize: 20

    readonly property bool isActive: mouseArea.pressed || root.hovered
    readonly property color contentColor: root.enabled ? Theme.palette.text
                                                        : Theme.palette.textMuted

    signal clicked()

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias mouseAreaItem: mouseArea
    readonly property alias backgroundItem: bg
    readonly property alias labelItem: label
    readonly property alias iconItem: icon

    implicitWidth: 200
    implicitHeight: 50
    hoverEnabled: true

    background: Rectangle {
        id: bg
        color: {
            if (!root.enabled)
                return Theme.palette.backgroundMuted
            if (root.isPrimary)
                return root.isActive ? Theme.palette.primaryHover : Theme.palette.primary
            return root.isActive ? Theme.palette.backgroundMuted : Theme.palette.backgroundSecondary
        }
        radius: root.radius
        border.width: 1
        border.color: {
            if (!root.enabled)
                return Theme.palette.border
            if (root.isPrimary)
                return root.isActive ? Theme.palette.overlayOrange : Theme.palette.primary
            return root.isActive ? Theme.palette.overlayOrange : Theme.palette.border
        }

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    // Icon uses an explicit size + anchors (not a Layout): MultiEffect fails to
    // refresh its source when the size is set by a layout pass after init.
    contentItem: Item {
        LogosIcon {
            id: icon
            source: root.iconSource
            color: root.contentColor
            // Normalize dark/grey silhouettes so the tint shows at full strength.
            brightness: 1.0
            visible: root.iconSource != ""
            width: root.iconSize
            height: root.iconSize
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: root.iconPosition === "left" ? parent.left : undefined
            anchors.leftMargin: Theme.spacing.large
            anchors.right: root.iconPosition === "right" ? parent.right : undefined
            anchors.rightMargin: Theme.spacing.large
        }

        Text {
            id: label
            anchors.centerIn: parent
            color: root.contentColor
            font.pixelSize: Theme.typography.secondaryText
            font.weight: Theme.typography.weightMedium
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
