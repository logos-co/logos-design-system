import QtQuick
import QtQuick.Layouts

import Logos.Icons
import Logos.Theme
import Logos.Controls

// LogosWarningDialog — a LogosDialog pre-styled for destructive or
// cautionary confirmations.
//
// A single `accentColor` drives the icon tint and border so the visual
// language stays consistent without per-property repetition. The icon
// source is swappable so the same component covers warning, error, and
// info severity levels.
//
// Public API (additions over LogosDialog):
//     accentColor     Color applied to the icon tint and border.
//                     Default: Theme.palette.accentOrange
//     iconSource      URL of the header icon. Default: LogosIcons.warning.
//
// Read-only inspection aliases:
//     warningIconItem  The LogosIcon in the header (for tests / tooling).
//
// Inherited from LogosDialog:
//     message       Convenience body text — renders as themed LogosText.
//     contentItem   Override for rich body content (lists, links, etc.).
//     leftActions / rightActions   Footer buttons.
//
// Example:
//     LogosWarningDialog {
//         anchors.centerIn: parent
//         title: "Remove default repository?"
//         message: "You can restore it later by re-adding its URL."
//         leftActions:  [ LogosButton { text: "Cancel"; onClicked: dlg.close() } ]
//         rightActions: [ LogosButton { text: "Remove"; onClicked: { doIt(); dlg.close() } } ]
//     }
//
// Error severity example:
//     LogosWarningDialog {
//         accentColor: Theme.palette.error
//         iconSource:  LogosIcons.warning
//         title: "Delete account?"
//         message: "This cannot be undone."
//         rightActions: [ LogosButton { text: "Delete"; onClicked: dlg.accept() } ]
//     }
LogosDialog {
    id: root

    property color accentColor: Theme.palette.accentOrange
    property url   iconSource:  LogosIcons.warning

    // only for tests
    readonly property alias warningIconItem: warningIcon

    // Wire accentColor to the inherited borderColor.
    borderColor: root.accentColor

    header: Item {
        visible: root.title.length > 0
        implicitHeight: visible
                        ? headerRow.implicitHeight + Theme.spacing.large + Theme.spacing.small
                        : 0

        RowLayout {
            id: headerRow
            anchors {
                left:  parent.left;  leftMargin:  Theme.spacing.large
                right: parent.right; rightMargin: Theme.spacing.large
                top:   parent.top;   topMargin:   Theme.spacing.large
            }
            spacing: Theme.spacing.small

            LogosIcon {
                id: warningIcon
                source: root.iconSource
                color: root.accentColor
                brightness: 1.0
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
                Layout.alignment: Qt.AlignVCenter
            }

            LogosText {
                Layout.fillWidth: true
                text: root.title
                color: Theme.palette.text
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
            }
        }
    }
}
