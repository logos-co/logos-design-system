import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

// LogosCopyableText — convenience row: selectable value + copy button.
//
// Composes LogosSelectableText and LogosCopyButton. The text stays
// drag-selectable; only the button writes to the clipboard. Prefer the
// primitives directly when you need a custom layout. For plain labels use
// LogosText; for navigation use LogosLink.
//
// Public API:
//     text               Display string (selectable).
//     copyText           Clipboard value. Empty → uses text (elided display
//                        / full copy).
//     showCopyButton     Show the trailing LogosCopyButton (default true).
//     textColor          Selectable text color (default Theme.palette.text).
//     buttonSize         Copy button hit-target size in px (default 24).
//     iconSize           Copy icon footprint in px (default 16).
//     feedbackDuration   Copied-state duration in ms (default 1500).
//     feedbackText       Feedback label after copy (default "Copied").
//     recentlyCopied     True briefly after a successful copy (read-only).
//     copy()             Imperative copy via the button.
//     copied(string value)  Forwarded from the copy button.
//
// Read-only inspection aliases:
//     textItem, copyButtonItem
//
// Example:
//     LogosCopyableText {
//         text: "QmXyz…"
//         copyText: fullCid
//     }
Control {
    id: root

    property string text: ""
    property string copyText: ""
    property bool showCopyButton: true
    property color textColor: Theme.palette.text
    property int buttonSize: 24
    property int iconSize: 16
    property int feedbackDuration: 1500
    property string feedbackText: qsTr("Copied")

    readonly property bool recentlyCopied: copyButton.recentlyCopied
    readonly property alias textItem: selectable
    readonly property alias copyButtonItem: copyButton

    signal copied(string value)
    function copy() { copyButton.copy() }

    hoverEnabled: false
    opacity: enabled ? 1.0 : 0.4

    implicitWidth: contentItem.implicitWidth
    implicitHeight: Math.max(selectable.implicitHeight, root.showCopyButton ? root.buttonSize : 0)

    contentItem: RowLayout {
        spacing: Theme.spacing.small

        LogosSelectableText {
            id: selectable
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: Math.max(implicitHeight, root.showCopyButton ? root.buttonSize : implicitHeight)
            text: root.text
            color: root.textColor
            verticalAlignment: TextEdit.AlignVCenter
            enabled: root.enabled
        }

        LogosCopyButton {
            id: copyButton
            Layout.alignment: Qt.AlignVCenter
            visible: root.showCopyButton
            Layout.preferredWidth: root.showCopyButton ? root.buttonSize : 0
            Layout.preferredHeight: root.showCopyButton ? root.buttonSize : 0
            value: root.copyText.length > 0 ? root.copyText : root.text
            size: root.buttonSize
            iconSize: root.iconSize
            feedbackDuration: root.feedbackDuration
            feedbackText: root.feedbackText
            enabled: root.enabled
            onCopied: function(v) { root.copied(v) }
        }
    }
}
