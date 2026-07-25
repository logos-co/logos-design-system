import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
// LogosButton — a themed push button with optional icons.
//
// A Control that pairs a centered text label with an optional LogosIcon on
// either side of it. The implicit size follows the content, so a button left
// at its natural size fits its own label; a label constrained by an explicit
// width is elided rather than overflowing the button. Colors, border and
// cursor react to hover/press and enabled state.
//
// Public API:
//     text         button label. Drives the implicit width. Elided with "…"
//                  when the button is narrower than the label.
//     font         label typography. Defaults to the 12px medium step; set
//                  font.pixelSize for a button that carries another step.
//     leadingIcon  IconSpec for the icon before the label (see below).
//     trailingIcon IconSpec for the icon after the label. Both may be set.
//     variant      LogosButton.Variant.Primary or .Secondary (default). Drives
//                  the background and border palette.
//     radius       background corner radius. Default = Theme.spacing.radiusXlarge.
//     clicked      signal emitted when an enabled button is clicked.
//
// IconSpec fields:
//     source     URL of the icon asset. Empty renders nothing.
//     size       icon footprint in px. Default 20.
//     color      tint applied to the icon. Default = Theme.palette.text.
//                Falls back to textMuted when the button is disabled.
//     brightness MultiEffect brightness before tinting. Default 0.
//
// Read-only inspection aliases (for tests):
//     mouseAreaItem     the MouseArea handling clicks/hover
//     backgroundItem    the background Rectangle
//     labelItem         the text label
//     leadingIconItem   the LogosIcon before the label
//     trailingIconItem  the LogosIcon after the label
//
// Example:
//     LogosButton {
//         text: "Refresh"
//         variant: LogosButton.Variant.Primary
//         leadingIcon.source: LogosIcons.refresh
//         onClicked: model.refresh()
//     }
Control {
    id: root

    enum Variant { Primary, Secondary }

    component IconSpec: QtObject {
        property url source: ""
        property int size: 20
        property real brightness: 0
        property color color: Theme.palette.text

        readonly property bool isVisible: source.toString().length > 0
    }

    property alias text: label.text
    readonly property IconSpec leadingIcon: IconSpec {}
    readonly property IconSpec trailingIcon: IconSpec {}
    property real radius: Theme.spacing.radiusXlarge
    property int variant: LogosButton.Variant.Secondary

    readonly property bool isActive: mouseArea.pressed || root.hovered

    signal clicked()

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias mouseAreaItem: mouseArea
    readonly property alias backgroundItem: bg
    readonly property alias labelItem: label
    readonly property alias leadingIconItem: iconLeft
    readonly property alias trailingIconItem: iconRight

    // Floors keep short labels ("OK") on a balanced pill, and hold the height
    // steady whether or not the button carries a default-sized (20px) icon;
    // beyond them the content decides.
    implicitWidth: Math.max(100, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(44, implicitContentHeight + topPadding + bottomPadding)
    leftPadding: Theme.spacing.large
    rightPadding: Theme.spacing.large
    topPadding: Theme.spacing.medium
    bottomPadding: Theme.spacing.medium
    hoverEnabled: true
    font.family: Theme.typography.publicSans
    font.pixelSize: Theme.typography.secondaryText
    font.weight: Theme.typography.weightMedium

    background: Rectangle {
        id: bg
        color: {
            if (!root.enabled)
                return Theme.palette.backgroundMuted
            if (root.variant === LogosButton.Variant.Primary)
                return root.isActive ? Theme.palette.primaryHover : Theme.palette.primary
            return root.isActive ? Theme.palette.backgroundMuted : Theme.palette.backgroundSecondary
        }
        radius: root.radius
        border.width: 1
        border.color: {
            if (!root.enabled)
                return Theme.palette.border
            if (root.variant === LogosButton.Variant.Primary)
                return root.isActive ? Theme.palette.overlayOrange : Theme.palette.primary
            return root.isActive ? Theme.palette.overlayOrange : Theme.palette.border
        }
    }

    contentItem: RowLayout {
        spacing: Theme.spacing.small

        LogosIcon {
            id: iconLeft
            source: root.leadingIcon.source
            color: root.enabled ? root.leadingIcon.color : Theme.palette.textMuted
            visible: root.leadingIcon.isVisible
            Layout.preferredWidth: root.leadingIcon.size
            Layout.preferredHeight: root.leadingIcon.size
            Layout.alignment: Qt.AlignVCenter
            brightness: root.leadingIcon.brightness
        }

        LogosText {
            id: label
            Layout.fillWidth: true
            color: root.enabled ? Theme.palette.text : Theme.palette.textMuted
            font: root.font
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter
            elide: Text.ElideRight
        }

        LogosIcon {
            id: iconRight
            source: root.trailingIcon.source
            color: root.enabled ? root.trailingIcon.color : Theme.palette.textMuted
            visible: root.trailingIcon.isVisible
            Layout.preferredWidth: root.trailingIcon.size
            Layout.preferredHeight: root.trailingIcon.size
            Layout.alignment: Qt.AlignVCenter
            brightness: root.trailingIcon.brightness
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
