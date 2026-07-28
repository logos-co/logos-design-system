import QtQuick

import Logos.Theme

// LogosSelectableText — themed display text that can be drag-selected.
//
// Looks like LogosText (same font/color defaults) but uses TextEdit so the
// user can select and Cmd/Ctrl+C
//
// Public API (plus TextEdit selection helpers: selectAll, deselect, …):
//     text               Display string (also the selection source).
//     color              Text color (default Theme.palette.text).
//     selectByMouse      Enable drag-select (default true).
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
    wrapMode: TextEdit.NoWrap
    clip: true

    font.family: Theme.typography.publicSans
    font.pixelSize: Theme.typography.primaryText
    font.weight: Theme.typography.weightRegular
    color: Theme.palette.text
    selectedTextColor: Theme.palette.text
    selectionColor: Theme.palette.overlayOrange
    persistentSelection: false
}
