import QtQuick

import Logos.Theme
import Logos.Controls

// LogosToast — a LogosNotice that closes itself.
//
// Additional public API over LogosNotice:
//     duration              Auto-close after N ms. 0 disables it, leaving a toast
//                           that stays until dismissed. The countdown is held
//                           while the pointer is over the toast, so the message
//                           can be read and selected without it vanishing.
//     show(title, message)  Open, updating either field if given, and arm the
//                           timer when duration > 0.
//
// A toast should not be the only place a user can read something they cannot
// recover — a path that has just been forgotten, a code they need to report.
// Set `duration: 0` for those.
//
//     LogosToast {
//         anchors.horizontalCenter: parent.horizontalCenter
//         anchors.bottom: parent.bottom
//         anchors.bottomMargin: Theme.spacing.large
//         severity: LogosNotice.Success
//         title: qsTr("Module published")
//         message: qsTr("logos-chat-ui 0.2.2 is live on the release channel.")
//     }
LogosNotice {
    id: root

    property int duration: 4000

    closable: true
    shown: false

    function show(newTitle, newMessage) {
        if (newTitle !== undefined)
            root.title = newTitle
        if (newMessage !== undefined)
            root.message = newMessage
        root.shown = true
        d.rearm()
    }

    onDismissed: d.autoHideTimer.stop()
    onShownChanged: d.rearm()
    HoverHandler {
        id: pointerOver
        onHoveredChanged: d.rearm()
    }

    QtObject {
        id: d

        function rearm() {
            if (root.shown && root.duration > 0 && !pointerOver.hovered)
                d.autoHideTimer.restart()
            else
                d.autoHideTimer.stop()
        }

        readonly property Timer autoHideTimer: Timer {
            interval: root.duration
            repeat: false
            onTriggered: root.hide()
        }
    }

    opacity: shown ? 1 : 0
    Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    transform: Translate {
        id: slide
        y: root.shown ? 0 : 8
        Behavior on y {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }
}
