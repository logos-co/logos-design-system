import QtQuick
import QtQuick.Controls

import Logos.Theme

// LogosAbstractButton — shared button interaction, no content and no chrome.
//
// Exists so LogosButton and LogosTile cannot drift apart in how they
// respond to the mouse and keyboard. It deliberately assigns neither
// `background` nor `contentItem`: both are left entirely to the deriving
// control, which is what makes this safe to extend.
//
// That constraint is the whole point. LogosButton could not be extended
// directly for this purpose — its `text` is an alias into its own
// contentItem (`property alias text: label.text`), so a derived type that
// replaces contentItem leaves the alias with no target. A base that owns no
// content has nothing to break.
//
// Derived controls get:
//     pressed        read-only; mouse held, or Space/Enter held with focus
//     isActive       enabled && (pressed || hovered || activeFocus)
//     clicked()      emitted on mouse click, or Space/Enter release
//     mouseAreaItem  read-only alias, for tests (synthesized mouse events do
//                    not reliably reach an inner MouseArea through a Control
//                    on offscreen QPA — drive this directly instead)
//
// Derived controls are expected to set `Accessible.name`; the role and press
// action are wired here.
//
// Example:
//     LogosAbstractButton {
//         Accessible.name: root.label
//         background: Rectangle { color: pressed ? "#222" : "#333" }
//         contentItem: LogosText { text: root.label }
//     }
Control {
    id: root

    readonly property bool pressed: interactive
                                    && (mouseArea.containsPress || impl.keyboardPressed)
    readonly property bool isActive: root.enabled && root.interactive
                                     && (root.pressed || root.hovered || root.activeFocus)

    // False turns the control into inert presentation: no hover tracking, no
    // focus, no press, no clicked(). Distinct from `enabled: false`, which
    // means "a control that is temporarily unavailable" and would eventually
    // carry a greyed-out look.
    //
    // It must suppress hoverEnabled, not just gate the state functions.
    // Control.hovered goes true regardless of the state gates, so a preview
    // placed under the cursor would compute hover chrome for a frame and then
    // animate back — a visible flash.
    property bool interactive: true

    signal clicked()

    readonly property alias mouseAreaItem: mouseArea

    QtObject {
        id: impl

        property bool keyboardPressed: false

        function isActivateKey(key) {
            return key === Qt.Key_Return || key === Qt.Key_Enter || key === Qt.Key_Space
        }

        function emitClicked() {
            if (root.enabled && root.interactive)
                root.clicked()
        }
    }

    hoverEnabled: interactive
    focusPolicy: interactive ? Qt.StrongFocus : Qt.NoFocus
    activeFocusOnTab: interactive

    Accessible.role: Accessible.Button
    Accessible.onPressAction: impl.emitClicked()

    onActiveFocusChanged: {
        if (!activeFocus)
            impl.keyboardPressed = false
    }

    onInteractiveChanged: {
        if (!interactive)
            impl.keyboardPressed = false
    }

    Keys.onPressed: function(event) {
        if (!impl.isActivateKey(event.key) || event.isAutoRepeat || !root.interactive)
            return
        impl.keyboardPressed = root.enabled
        event.accepted = true
    }

    Keys.onReleased: function(event) {
        if (!impl.isActivateKey(event.key) || event.isAutoRepeat || !root.interactive)
            return
        if (impl.keyboardPressed) {
            impl.keyboardPressed = false
            impl.emitClicked()
        }
        event.accepted = true
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.enabled && root.interactive
        hoverEnabled: root.interactive
        cursorShape: (root.enabled && root.interactive) ? Qt.PointingHandCursor
                                                        : Qt.ArrowCursor
        onPressed: root.forceActiveFocus()
        onClicked: impl.emitClicked()
    }
}
