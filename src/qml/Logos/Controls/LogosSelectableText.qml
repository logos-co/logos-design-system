import QtQuick

import Logos.Theme

// LogosSelectableText — themed display text that can be drag-selected.
//
// Looks like LogosText (same font/color defaults) but uses TextEdit so the
// user can select (mouse drag or Shift+arrows) and Cmd/Ctrl+C. No insert
// caret — it should not look like an editor.
//
// Public API (plus TextEdit selection helpers: selectAll, deselect, …):
//     text               Display string (also the selection source).
//     color              Text color (default Theme.palette.text).
//     selectByMouse      Enable drag-select (default true).
//     selectByKeyboard   Enable Shift+arrow selection (default true; required
//                        because readOnly TextEdit otherwise disables it).
//     wrapMode           TextEdit wrap mode (default NoWrap).
//     clip               Clip overflow (default true).
//     selectedText       Currently selected substring (read-only, TextEdit).
//     horizontalAlignment / verticalAlignment  Alignment within the item.
//
// Contract: treat as display+select, not an editor. Do not set readOnly to
// false — use LogosTextField for input.
//
// Example:
//     LogosSelectableText {
//         text: cid
//     }
TextEdit {
    id: root

    readOnly: true
    selectByMouse: true
    selectByKeyboard: true
    textFormat: TextEdit.PlainText
    wrapMode: TextEdit.NoWrap
    clip: true
    activeFocusOnTab: true

    font.family: Theme.typography.publicSans
    font.pixelSize: Theme.typography.primaryText
    font.weight: Theme.typography.weightRegular
    color: Theme.palette.text
    selectedTextColor: Theme.palette.text
    selectionColor: Theme.palette.overlayOrange
    persistentSelection: false
}
