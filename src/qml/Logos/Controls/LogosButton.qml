import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
// LogosButton — a themed push button with an optional icon.
//
// A Control that pairs a centered text label with an optional LogosIcon on
// the left or right. Long labels are elided rather than overflowing the
// button. Colors, border and cursor react to hover/press and enabled state.
//
// Public API:
//     text     button label. Elided with "…" when it overflows.
//     icon     IconSpec grouping the icon's source/size/position/color/
//              brightness (see below). Empty source renders no icon.
//     variant  LogosButton.Variant.Primary or .Secondary (default). Drives
//              the background and border palette.
//     radius   background corner radius. Default = Theme.spacing.radiusXlarge.
//     clicked  signal emitted when an enabled button is clicked.
//
// icon (IconSpec) fields:
//     source     URL of the icon asset. Empty renders nothing.
//     size       icon footprint in px. Default 20.
//     position   LogosButton.IconPosition.Left (default) or .Right.
//     color      tint applied to the icon. Default = Theme.palette.text.
//                Falls back to textMuted when the button is disabled.
//     brightness MultiEffect brightness before tinting. Default 0.
//
// Read-only inspection aliases (for tests):
//     mouseAreaItem  the MouseArea handling clicks/hover
//     backgroundItem the background Rectangle
//     labelItem      the text label
//     iconItem       the active LogosIcon (left or right per icon.position)
//
// Example:
//     LogosButton {
//         text: "Refresh"
//         variant: LogosButton.Variant.Primary
//         icon.source: LogosIcons.refresh
//         icon.position: LogosButton.IconPosition.Left
//         onClicked: model.refresh()
//     }
Control {
    id: root

    enum Variant { Primary, Secondary }
    enum IconPosition { Left, Right }

    component IconSpec: QtObject {
        property url source: ""
        property int size: 20
        property int position: LogosButton.IconPosition.Left
        property real brightness: 0
        property color color: Theme.palette.text

        readonly property bool isVisible: source.toString().length > 0
        readonly property bool isLeft: position === LogosButton.IconPosition.Left
        readonly property bool isRight: position === LogosButton.IconPosition.Right
    }

    property alias text: label.text
    readonly property IconSpec icon: IconSpec {}
    property real radius: Theme.spacing.radiusXlarge
    property int variant: LogosButton.Variant.Secondary

    readonly property bool isActive: mouseArea.pressed || root.hovered

    signal clicked()

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias mouseAreaItem: mouseArea
    readonly property alias backgroundItem: bg
    readonly property alias labelItem: label
    readonly property alias iconLeftItem: iconLeft
    readonly property alias iconRightItem: iconRight
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
            if (root.variant == LogosButton.Variant.Primary)
                return root.isActive ? Theme.palette.primaryHover : Theme.palette.primary
            return root.isActive ? Theme.palette.backgroundMuted : Theme.palette.backgroundSecondary
        }
        radius: root.radius
        border.width: 1
        border.color: {
            if (!root.enabled)
                return Theme.palette.border
            if (root.variant == LogosButton.Variant.Primary)
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
            source: root.icon.isLeft ? root.icon.source : ""
            color: root.enabled ? root.icon.color : Theme.palette.textMuted
            visible: root.icon.isVisible
            opacity: root.icon.isLeft ? 1 : 0
            Layout.preferredWidth: root.icon.size
            Layout.preferredHeight: root.icon.size
            Layout.alignment: Qt.AlignVCenter
            brightness: root.icon.brightness
        }

        LogosText {
            id: label
            Layout.fillWidth: true
            color: root.enabled ? Theme.palette.text : Theme.palette.textMuted
            font.pixelSize: Theme.typography.secondaryText
            font.weight: Theme.typography.weightMedium
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter
            elide: Text.ElideRight
        }

        LogosIcon {
            id: iconRight
            source: root.icon.isRight ? root.icon.source : ""
            color: root.enabled ? root.icon.color : Theme.palette.textMuted
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
