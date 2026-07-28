import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Icons

// Public API:
//     text             alias — read/write the current query
//     placeholderText  alias — default "Search..."
//     echoMode         alias
//     iconSource       URL of the leading icon (empty hides it; defaults to
//                      the bundled icons/search.svg)
//     shortcutHint     literal text to render in the trailing chip
//                      (e.g. "⌘ K", "Ctrl+K"). Display-only — does not
//                      bind anything. For platform-aware text, pass the
//                      `nativeText` of the consumer's own Shortcut.
//
// Read-only inspection aliases:
//     textInput        the inner TextInput (cursor, selection, etc.)
//     fieldItem        the inner LogosTextField
//     iconItem         the leading icon container
//     shortcutItem     the trailing shortcut chip
//
// Signal:
//     submitted(text)  emitted when the user presses Return/Enter
//
// Example (with consumer-owned shortcut and platform-aware chip text):
//     Shortcut {
//         id: searchShortcut
//         sequence: "Ctrl+K"
//         context: Qt.WindowShortcut
//         onActivated: {
//             searchBar.textInput.forceActiveFocus()
//             searchBar.textInput.selectAll()
//         }
//     }
//     LogosSearchBar {
//         id: searchBar
//         shortcutHint: searchShortcut.nativeText   // "⌘ K" on macOS
//         placeholderText: qsTr("Search packages...")
//         onSubmitted: function(text) { runSearch(text) }
//     }
Control {
    id: root

    property alias text: field.text
    property alias placeholderText: field.placeholderText
    property alias echoMode: field.echoMode
    property url iconSource: LogosIcons.search
    property string shortcutHint: ""

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias textInput: field.textInput
    readonly property alias fieldItem: field
    readonly property alias iconItem: iconHolder
    readonly property alias shortcutItem: shortcutChip

    signal submitted(string text)

    implicitWidth: 400
    implicitHeight: 54

    // Match the figma spec (8/8/8/10) using existing tokens.
    leftPadding: Theme.spacing.small + 2
    rightPadding: Theme.spacing.small
    topPadding: Theme.spacing.small
    bottomPadding: Theme.spacing.small

    focusPolicy: Qt.StrongFocus
    activeFocusOnTab: true
    onActiveFocusChanged: if (activeFocus)
        field.textInput.forceActiveFocus()

    background: Rectangle {
        color: Theme.palette.background
        radius: Theme.spacing.radiusLarge
        border.width: 1
        border.color: field.textInput.activeFocus
                      ? Theme.palette.primary
                      : Theme.palette.borderSubtle
    }

    contentItem: RowLayout {
        spacing: Theme.spacing.small

        Item {
            id: iconHolder

            Layout.alignment: Qt.AlignVCenter
            visible: root.iconSource.toString().length > 0
            implicitWidth: 20
            implicitHeight: 20

            Image {
                id: iconImg
                anchors.fill: parent
                source: root.iconSource
                sourceSize: Qt.size(parent.width * 2, parent.height * 2)
                fillMode: Image.PreserveAspectFit
                visible: false
            }
            MultiEffect {
                anchors.fill: iconImg
                source: iconImg
                colorization: 1.0
                colorizationColor: Theme.palette.textSecondary
            }
        }

        LogosTextField {
            id: field

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            background: Item {}
            placeholderText: "Search..."
            activeFocusOnTab: false
            textInput.activeFocusOnTab: false
        }

        Rectangle {
            id: shortcutChip

            Layout.alignment: Qt.AlignVCenter
            visible: root.shortcutHint.length > 0
            implicitWidth: shortcutLabel.implicitWidth + Theme.spacing.medium
            implicitHeight: 20

            color: Theme.palette.surfaceRaised
            radius: Theme.spacing.radiusSmall
            border.width: 1
            border.color: Theme.palette.borderSubtle

            LogosText {
                id: shortcutLabel

                anchors.centerIn: parent
                text: root.shortcutHint
                font.pixelSize: Theme.typography.secondaryText
                font.weight: Theme.typography.weightMedium
                color: Theme.palette.textSecondary
            }
        }
    }

    // Forward the inner TextInput's `accepted` signal 
    Connections {
        target: field.textInput
        function onAccepted() { root.submitted(field.text) }
    }
}
