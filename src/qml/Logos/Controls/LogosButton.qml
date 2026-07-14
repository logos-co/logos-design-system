import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme

Control {
    id: root

    enum Variant { Primary, Secondary }
    enum IconPosition { Left, Right }

    property alias text: label.text
    property real radius: Theme.spacing.radiusXlarge
    property url iconSource: ""
    property int iconPosition: LogosButton.IconPosition.Left // LogosButton.IconPosition
    property int iconSize: 20
    property int type: LogosButton.Variant.Secondary // LogosButton.Variant

    readonly property bool isActive: mouseArea.pressed || root.hovered
    readonly property color contentColor: root.enabled ? Theme.palette.text
                                                        : Theme.palette.textMuted

    signal clicked()

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias mouseAreaItem: mouseArea
    readonly property alias backgroundItem: bg
    readonly property alias labelItem: label
    readonly property Item iconItem: root.iconPosition === LogosButton.IconPosition.Right
                                     ? iconRight : iconLeft

    implicitWidth: 200
    implicitHeight: 50
    leftPadding: Theme.spacing.large
    rightPadding: Theme.spacing.large
    hoverEnabled: true

    background: Rectangle {
        id: bg
        color: {
            if (!root.enabled)
                return Theme.palette.backgroundMuted
            if (root.type == LogosButton.Variant.Primary)
                return root.isActive ? Theme.palette.primaryHover : Theme.palette.primary
            return root.isActive ? Theme.palette.backgroundMuted : Theme.palette.backgroundSecondary
        }
        radius: root.radius
        border.width: 1
        border.color: {
            if (!root.enabled)
                return Theme.palette.border
            if (root.type == LogosButton.Variant.Primary)
                return root.isActive ? Theme.palette.overlayOrange : Theme.palette.primary
            return root.isActive ? Theme.palette.overlayOrange : Theme.palette.border
        }

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    // Outer margins come from the control's padding. Leading/trailing icon is a
    // separate slot on each side; only the one matching iconPosition shows.
    contentItem: RowLayout {
        spacing: Theme.spacing.small

        LogosIcon {
            id: iconLeft
            source: root.iconSource
            color: root.contentColor
            visible: root.iconSource != "" && root.iconPosition === LogosButton.IconPosition.Left
            Layout.preferredWidth: root.iconSize
            Layout.preferredHeight: root.iconSize
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            id: label
            Layout.fillWidth: true
            color: root.contentColor
            font.pixelSize: Theme.typography.secondaryText
            font.weight: Theme.typography.weightMedium
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        LogosIcon {
            id: iconRight
            source: root.iconSource
            color: root.contentColor
            visible: root.iconSource != "" && root.iconPosition === LogosButton.IconPosition.Right
            Layout.preferredWidth: root.iconSize
            Layout.preferredHeight: root.iconSize
            Layout.alignment: Qt.AlignVCenter
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
