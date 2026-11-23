import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Icons
import Logos.Controls

// LogosSearchToggle — a search that folds into an icon, for bars at phone
// width. Folded, it is a search icon; tapped, the bar becomes the search: a
// flat field, its icon first, with ✕, which clears and folds it, as Escape
// does. It stays unfolded while it holds text, and a query set from outside
// unfolds it. With `folds: false` it is a plain search
// field that never folds: one field at every width, so the query survives a
// change of width class. The field is as tall as the toggle: a touch target,
// unless you size it.
//
// Public API:
//     text, placeholderText   the query and its placeholder
//     shortcutHint            a keyboard shortcut shown in the field, e.g. "Ctrl+K"
//     folds                   fold into an icon (default true)
//     expanded                read-only; true while the field shows
//     open() / close()        unfold and focus / clear and fold
//     submitted(string text)  Enter in the field
//
// Read-only inspection aliases: searchBarItem, openButtonItem, closeButtonItem.
//
// Hide a bar's title while the search is unfolded:
//     RowLayout {
//         LogosText { visible: !search.expanded; Layout.fillWidth: true; text: qsTr("Apps") }
//         LogosSearchToggle { id: search; placeholderText: qsTr("Search apps") }
//     }
Control {
    id: root

    property alias text: bar.text
    property alias placeholderText: bar.placeholderText
    property alias shortcutHint: bar.shortcutHint
    property bool folds: true
    readonly property bool expanded: !folds || d.unfolded

    signal submitted(string text)

    readonly property alias searchBarItem: bar
    readonly property alias openButtonItem: openButton
    readonly property alias closeButtonItem: closeButton

    function open() {
        if (folds)
            d.unfolded = true
        bar.textInput.forceActiveFocus()
    }

    function close() {
        const hadFocus = bar.textInput.activeFocus
        bar.text = ""
        d.unfolded = false
        // Back to its icon, so the next Esc goes on, e.g. back a page.
        if (hadFocus && folds)
            openButton.forceActiveFocus()
    }

    QtObject {
        id: d
        property bool unfolded: false
    }

    // Once it folds, it is open only while it holds a query.
    onFoldsChanged: d.unfolded = folds && bar.text !== ""

    Layout.fillWidth: folds && expanded
    implicitWidth: !folds ? Theme.controls.searchToggle.fieldWidth
                 : expanded ? Theme.controls.searchToggle.fieldWidth : Theme.size.touchTarget
    implicitHeight: Theme.size.touchTarget

    contentItem: Item {
        LogosIconButton {
            id: openButton
            visible: !root.expanded
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            size: Theme.size.touchTarget
            flat: true
            iconSource: LogosIcons.search
            Accessible.name: qsTr("Search")
            onClicked: root.open()
        }

        RowLayout {
            visible: root.expanded
            anchors.fill: parent
            spacing: Theme.spacing.tiny

            LogosSearchBar {
                id: bar
                Layout.fillWidth: true
                Layout.fillHeight: true
                flat: root.folds
                leftPadding: root.folds ? 0 : Theme.controls.search.paddingLeft
                clearable: !root.folds
                onSubmitted: function(text) { root.submitted(text) }
                // A query opens it, however it came: folded, it would filter
                // out of sight.
                onTextChanged: if (root.folds && text !== "") d.unfolded = true
                // Only a folding search uses Esc; otherwise it goes on, e.g. to close a dialog.
                Keys.onEscapePressed: function(event) {
                    if (root.folds)
                        root.close()
                    else
                        event.accepted = false
                }
            }

            LogosIconButton {
                id: closeButton
                visible: root.folds
                size: Theme.size.touchTarget
                flat: true
                iconSource: LogosIcons.close
                Accessible.name: qsTr("Close search")
                onClicked: root.close()
            }
        }
    }
}
