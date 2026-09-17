import QtQuick
import QtQuick.Controls

import Logos.Theme
import Logos.Controls

// LogosInfoButton — a small "i" that opens an explanation in a modal dialog.
//
// For the long-form answer to "what is this number?" next to a field, a stat or
// a table header. Click to open; Escape, the scrim, or close() dismisses.
//
// Opens a centred LogosDialog rather than a popover anchored to the button. An
// explanation is something the user stops to read, so it gets the screen while
// they do; an anchored panel has to fight window edges and scroll containers to
// stay visible, and still reads as an aside. For a short hint that follows the
// pointer, use LogosToolTip instead.
//
// The trigger is drawn as a hairline ring around a lowercase "i", sized to the
// glyph (16px) rather than to a touch target, so it sits inline with the label
// it annotates. An icon-button footprint would push it out of alignment. That
// is also why it does not use LogosIcons.info.
//
// Public API:
//     text         the explanation. Wraps. Empty renders an empty dialog
//     title        dialog heading. Empty hides the header
//     dialogWidth  preferred width of the dialog (default 560, the design's
//                  info modal). Always clamped to the host view, whatever the
//                  dialog is centred on
//     dialogParent what the dialog centres on. Null (default) centres it on
//                  the host view; set an Item to centre on that instead, e.g.
//                  `dialogParent: <the button>` to open it over the thing it
//                  explains
//     open() / close() / toggle()
//     opened       read-only; true while the dialog is showing
//
// Read-only inspection aliases (for tests):
//     ringItem, glyphItem, dialogItem, textItem
//
// Inherited from LogosAbstractButton: hovered, pressed, isActive, interactive,
// clicked(), mouseAreaItem.
//
// The ring and glyph are light grey at rest and go white while hovered or while
// the dialog is open, so an open dialog keeps its trigger lit.
//
// For richer content than a paragraph — sections, a state table, a copyable
// docs link — set `dialogContentItem` to your own Item. It replaces the body of
// the dialog the trigger already owns, so there is no second dialog to stand up
// and no clicked() to re-wire.
//
// Example:
//     LogosInfoButton {
//         title: qsTr("Slot")
//         text: qsTr("Consensus slot of the current chain tip.")
//     }
LogosAbstractButton {
    id: root

    property string text: ""
    property string title: ""
    property int dialogWidth: 560

    // What the dialog centres on. Null (default) centres it on the host view —
    // in basecamp and the standalone app that is the module's own QQuickWidget,
    // so it never blanks the shell around it. Set an Item to centre on that
    // instead; `dialogParent: <the button>` opens it over the thing it explains.
    property Item dialogParent: null

    readonly property bool opened: dialog.visible

    // The dialog's body.
    property alias dialogContentItem: dialog.contentItem

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias ringItem: ring
    readonly property alias glyphItem: glyph
    readonly property alias dialogItem: dialog
    readonly property alias textItem: dialog.messageItem

    function open() { dialog.open() }
    function close() { dialog.close() }
    function toggle() { dialog.visible ? dialog.close() : dialog.open() }

    QtObject {
        id: d

        readonly property bool lit: root.hovered || dialog.visible
    }

    implicitWidth: 16
    implicitHeight: 16
    padding: 0

    Accessible.role: Accessible.Button
    Accessible.name: qsTr("More information")
    Accessible.description: root.text

    background: Rectangle {
        id: ring
        radius: width / 2
        color: "transparent"
        border.width: 1
        border.color: d.lit ? Theme.palette.text : Theme.palette.borderGlyph
        Behavior on border.color { ColorAnimation { duration: 120 } }
    }

    contentItem: LogosText {
        id: glyph
        text: "i"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 9
        color: d.lit ? Theme.palette.text : Theme.palette.textMuted
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    LogosDialog {
        id: dialog

        readonly property Item hostOverlay: Overlay.overlay
        parent: root.dialogParent ? root.dialogParent : hostOverlay
        anchors.centerIn: parent

        title: root.title
        message: root.text
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        width: hostOverlay
               ? Math.min(root.dialogWidth,
                          hostOverlay.width - 2 * Theme.spacing.xxlarge)
               : root.dialogWidth
    }

    onClicked: root.toggle()
}
