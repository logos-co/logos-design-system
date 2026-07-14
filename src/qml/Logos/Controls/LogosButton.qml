import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme

Control {
    id: root

    enum Variant { Primary, Secondary }
    enum IconPosition { Left, Right }

    component IconSpec: QtObject {
        property url source: ""
        property int size: 20
        property string bgColor: ""
        property int position: LogosButton.IconPosition.Left
        property real brightness: 0
        property color color: Theme.palette.text

        readonly property bool isVisible: source != ""
        readonly property bool isLeft: position === LogosButton.IconPosition.Left
        readonly property bool isRight: position === LogosButton.IconPosition.Right
    }

    property alias text: label.text
    property IconSpec icon: IconSpec {}
    property real radius: Theme.spacing.radiusXlarge
    property int type: LogosButton.Variant.Secondary // LogosButton.Variant

    readonly property bool isActive: mouseArea.pressed || root.hovered

    signal clicked()

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias mouseAreaItem: mouseArea
    readonly property alias backgroundItem: bg
    readonly property alias labelItem: label
    readonly property Item iconItem: root.icon.isRight ? iconRight : iconLeft

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

    contentItem: RowLayout {
        spacing: Theme.spacing.small

        LogosIcon {
            id: iconLeft
            source: root.icon.source
            color: root.icon.color
            visible: root.icon.isVisible
            opacity: root.icon.isLeft ? 1 : 0
            Layout.preferredWidth: root.icon.size
            Layout.preferredHeight: root.icon.size
            Layout.alignment: Qt.AlignVCenter
            brightness: root.icon.brightness
        }

        Text {
            id: label
            Layout.fillWidth: true
            color: root.enabled ? Theme.palette.text : Theme.palette.textMuted
            font.pixelSize: Theme.typography.secondaryText
            font.weight: Theme.typography.weightMedium
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        LogosIcon {
            id: iconRight
            source: root.icon.source
            color: root.icon.color
            visible: root.icon.isVisible
            opacity: root.icon.isRight ? 1 : 0
            Layout.preferredWidth: root.icon.size
            Layout.preferredHeight: root.icon.size
            Layout.alignment: Qt.AlignVCenter
            brightness: root.icon.brightness
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
