import QtQuick
import QtQuick.Controls

import Logos.Theme
import Logos.Controls

GroupBox {
    id: root

    property color borderColor: Theme.palette.border
    property color labelColor: Theme.palette.textSecondary

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias backgroundItem: bg
    readonly property alias labelItem: titleLabel

    padding: Theme.spacing.medium
    spacing: Theme.spacing.small

    label: LogosText {
        id: titleLabel
        leftPadding: Theme.spacing.medium
        text: root.title
        color: root.labelColor
        font.weight: Theme.typography.weightBold
        font.pixelSize: Theme.typography.secondaryText
    }

    background: Rectangle {
        id: bg
        y: root.topPadding - root.padding
        height: root.height - y
        color: "transparent"
        border.color: root.borderColor
        border.width: 1
        radius: Theme.spacing.radiusSmall
    }
}
