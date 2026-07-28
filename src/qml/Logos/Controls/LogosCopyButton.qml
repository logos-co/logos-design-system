import QtQuick
import QtQuick.Controls

import Logos.Theme
import Logos.Controls
import Logos.Icons

// LogosCopyButton — flat LogosIconButton that copies a value to the clipboard.
//
// Public API (in addition to LogosIconButton — size, iconSize, flat,
// isActive, clicked(), iconImage, backgroundItem, mouseAreaItem):
//     value              String written to the clipboard on activate.
//     feedbackDuration   How long recentlyCopied / the tip stay, in ms
//                        (default 1500).
//     feedbackText       Feedback label after a successful copy (default
//                        "Copied").
//     recentlyCopied     True briefly after a successful copy (read-only).
//     copy()             Imperative copy helper (same as a click).
//     copied(string value)  Emitted after a successful clipboard write.
//
// Read-only inspection aliases (for tests):
//     feedbackTipItem   LogosToolTip shown after copy (open/close, position).
//                       Closing it also clears recentlyCopied (same as the
//                       feedback timer), so tests reset via tip.close().
//     feedbackLabelItem tip label text (feedbackText flow-through).
//
// Example:
//     LogosCopyButton {
//         value: fullCid
//     }
LogosIconButton {
    id: root

    property string value: ""
    property int feedbackDuration: 1500
    property string feedbackText: qsTr("Copied")
    readonly property bool recentlyCopied: d.recentlyCopied

    // for tests
    readonly property alias feedbackTipItem: copiedTip
    readonly property Item feedbackLabelItem: copiedTip.labelItem

    signal copied(string value)
    function copy() { d.copy() }

    flat: true
    size: 24
    iconSize: 16
    iconSource: d.recentlyCopied ? LogosIcons.check : LogosIcons.copy
    iconColor: d.recentlyCopied ? Theme.palette.success
                                : (root.isActive ? Theme.palette.text
                                                 : Theme.palette.textTertiary)

    Accessible.role: Accessible.Button
    Accessible.name: root.value.length > 0 ? ("Copy " + root.value) : "Copy"
    Accessible.onPressAction: d.copy()
    onClicked: d.copy()

    QtObject {
        id: d

        property bool recentlyCopied: false

        readonly property TextEdit clipboardHelper: TextEdit {
            visible: false
            width: 0
            height: 0
        }

        readonly property Timer resetTimer: Timer {
            interval: root.feedbackDuration
            onTriggered: copiedTip.close()
        }

        function copy() {
            if (!root.enabled || root.value.length === 0)
                return
            clipboardHelper.text = root.value
            clipboardHelper.selectAll()
            clipboardHelper.copy()
            recentlyCopied = true
            copiedTip.open()
            resetTimer.restart()
            root.copied(root.value)
        }
    }

    // Copy confirmation — the design-system tooltip. Closing (timer or
    // otherwise) clears the copied icon state.
    LogosToolTip {
        id: copiedTip
        parent: root
        text: root.feedbackText
        placement: LogosToolTip.Top
        delay: 0
        timeout: -1
        closePolicy: Popup.NoAutoClose
        onClosed: {
            d.recentlyCopied = false
            d.resetTimer.stop()
        }
    }
}
