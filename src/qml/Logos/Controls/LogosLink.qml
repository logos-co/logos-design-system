import QtQuick
import QtQuick.Controls

import Logos.Theme
import Logos.Controls

// LogosLink — themed hyperlink text for navigation / activation.
//
// Public API:
//     text             Link label.
//     href             Target associated with the link (may be empty for
//                      in-app handlers that only need activated).
//     linkColor        Idle text color (default Theme.palette.primary).
//     hoverColor       Hover/press text color (default Theme.palette.primaryHover).
//     underline        Always show underline when true (default). When false,
//                      underline appears only while hovered/pressed.
//     elide            Text elide mode (default Text.ElideNone).
//     activated(url href)  Emitted on every enabled click / activate().
//     activate()           Imperative activate (same as a click / Enter / Space).
//
// Read-only inspection aliases (for tests):
//     labelItem, mouseAreaItem
//
// Joins the Tab focus chain; Space/Enter show pressed then call activate().
//
// Example:
//     LogosLink {
//         text: "Docs"
//         href: "https://example.com/docs"
//         onActivated: (url) => Qt.openUrlExternally(url)
//     }
//
//     LogosLink {
//         text: "Settings"
//         onActivated: stack.push(settingsPage)
//     }
Control {
    id: root

    property string text: ""
    property url href: ""
    property color linkColor: Theme.palette.primary
    property color hoverColor: Theme.palette.primaryHover
    property bool underline: true
    property int elide: Text.ElideNone

    // for tests
    readonly property alias labelItem: label
    readonly property alias mouseAreaItem: mouseArea

    signal activated(url href)

    function activate() { d.activate() }

    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    activeFocusOnTab: true
    opacity: enabled ? 1.0 : 0.4

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Accessible.role: Accessible.Link
    Accessible.name: root.text
    Accessible.onPressAction: d.activate()

    Keys.onPressed: function(event) {
        if (!d.isActivateKey(event.key) || event.isAutoRepeat)
            return
        d.keyboardPressed = root.enabled
        event.accepted = true
    }

    Keys.onReleased: function(event) {
        if (!d.isActivateKey(event.key) || event.isAutoRepeat)
            return
        if (d.keyboardPressed) {
            d.keyboardPressed = false
            d.activate()
        }
        event.accepted = true
    }

    onActiveFocusChanged: {
        if (!activeFocus)
            d.keyboardPressed = false
    }

    QtObject {
        id: d
        property bool keyboardPressed: false

        readonly property bool isActive: root.enabled
                                         && (mouseArea.pressed || d.keyboardPressed
                                             || root.hovered || root.activeFocus)
        readonly property bool showUnderline: root.underline || isActive

        function isActivateKey(key) {
            return key === Qt.Key_Return || key === Qt.Key_Enter || key === Qt.Key_Space
        }

        function activate() {
            if (!root.enabled)
                return
            root.activated(root.href)
        }
    }

    contentItem: LogosText {
        id: label
        text: root.text
        color: d.isActive ? root.hoverColor : root.linkColor
        font.underline: d.showUnderline
        elide: root.elide
        maximumLineCount: 1
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onPressed: root.forceActiveFocus()
        onClicked: d.activate()
    }
}
