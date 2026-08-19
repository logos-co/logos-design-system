import QtQuick

import Logos.Theme
import Logos.Controls

// LogosToast — a LogosNotice that closes itself.
//
// Additional public API over LogosNotice:
//     duration              Auto-close after N ms. 0 disables it, leaving a toast
//                           that stays until dismissed.
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
        if (root.duration > 0)
            d.autoHideTimer.restart()
    }

    onDismissed: d.autoHideTimer.stop()

    QtObject {
        id: d

        readonly property Timer autoHideTimer: Timer {
            interval: root.duration
            running: root.shown && root.duration > 0
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
