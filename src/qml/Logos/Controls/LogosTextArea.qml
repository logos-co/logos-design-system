import QtQuick
import QtQuick.Controls

import Logos.Theme

// For fixed-height regions (modal dialogs, sidebars) where you don't want the
// area to expand, wrap it in a ScrollView so overflow scrolls instead of clips:
//
//     ScrollView {
//         width: 300; height: 120
//         LogosTextArea { placeholderText: "..." }
//     }
TextArea {
    id: root

    property color borderColor: Theme.palette.border
    property color backgroundColor: Theme.palette.backgroundSecondary
    property color focusBorderColor: Theme.palette.primary

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias backgroundItem: bg

    color: Theme.palette.text
    placeholderTextColor: Theme.palette.textTertiary
    font.family: Theme.typography.publicSans
    font.pixelSize: Theme.typography.primaryText
    selectByMouse: true
    wrapMode: TextEdit.Wrap

    focusPolicy: Qt.StrongFocus
    activeFocusOnTab: true

    leftPadding: Theme.spacing.medium
    rightPadding: Theme.spacing.medium
    topPadding: Theme.spacing.small
    bottomPadding: Theme.spacing.small

    background: Rectangle {
        id: bg
        color: root.backgroundColor
        border.color: root.activeFocus || root.visualFocus ? root.focusBorderColor : root.borderColor
        border.width: 1
        radius: Theme.spacing.radiusSmall
    }
}
