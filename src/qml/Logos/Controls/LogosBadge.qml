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
    property int borderWidth: 1

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
            visible: d.hasIcon
            source: root.iconSource
            sourceSize.width: 12
            sourceSize.height: 12
            Layout.preferredWidth: d.hasIcon ? 12 : 0
            Layout.preferredHeight: d.hasIcon ? 12 : 0
            Layout.alignment: Qt.AlignVCenter
        }

        LogosText {
            id: label
            text: root.text
            font.weight: Theme.typography.weightMedium
            font.pixelSize: 11
            font.letterSpacing: 0.22
            font.capitalization: Font.AllUppercase
            color: root.color
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
