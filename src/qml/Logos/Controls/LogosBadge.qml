import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

Control {
    id: root

    property string text: ""
    property url iconSource: ""
    property color color: Theme.palette.accentOrange
    property color backgroundColor: Theme.colors.getColor(color, 0.18)
    property color borderColor: color
    property real radius: Theme.spacing.radiusSmall
    property int borderWidth: Theme.size.borderWidth

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias iconItem: iconImage
    readonly property alias labelItem: label
    readonly property alias backgroundItem: bg

    QtObject {
        id: d
        readonly property bool hasIcon: root.iconSource.toString().length > 0
    }

    horizontalPadding: Theme.spacing.small
    verticalPadding: Theme.spacing.tiny

    background: Rectangle {
        id: bg
        color: root.backgroundColor
        border.color: root.borderColor
        border.width: root.borderWidth
        radius: root.radius
    }

    contentItem: RowLayout {
        spacing: Theme.spacing.tiny

        Image {
            id: iconImage
            Layout.preferredWidth: d.hasIcon ? Theme.controls.badge.iconSize : 0
            Layout.preferredHeight: d.hasIcon ? Theme.controls.badge.iconSize : 0
            Layout.alignment: Qt.AlignVCenter
            visible: d.hasIcon
            source: root.iconSource
            sourceSize.width: Theme.controls.badge.iconSize
            sourceSize.height: Theme.controls.badge.iconSize
        }

        LogosText {
            id: label
            Layout.alignment: Qt.AlignVCenter
            text: root.text
            font.weight: Theme.typography.weightMedium
            font.pixelSize: Theme.controls.badge.fontSize
            font.letterSpacing: Theme.controls.badge.letterSpacing
            font.capitalization: Font.AllUppercase
            color: root.color
        }
    }
}
