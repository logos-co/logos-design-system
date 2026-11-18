import QtQuick

import Logos.Theme
import Logos.Controls

// Internal. At touch density a long-press on `control` opens the
// LogosToolTips declared in it, and is then not also a click. It listens
// only while the control has such a tip, so elsewhere a long-press is still
// a click, as on desktop. `source` is what emits pressAndHold: the control
// itself, or the MouseArea it takes clicks through.
Connections {
    id: root

    required property Item control
    property QtObject source: control

    // Found once the control is complete: a binding can't follow `data`.
    property var tips: []
    readonly property bool hasTips: {
        for (let i = 0; i < tips.length; ++i)
            if (tips[i].openOnLongPress && tips[i].text.length > 0)
                return true
        return false
    }

    target: Theme.touch && hasTips ? source : null

    function onPressAndHold() {
        for (let i = 0; i < tips.length; ++i)
            if (tips[i].openOnLongPress && tips[i].text.length > 0)
                tips[i].open()
    }

    Component.onCompleted: {
        const found = []
        for (let i = 0; i < control.data.length; ++i)
            if (control.data[i] instanceof LogosToolTip)
                found.push(control.data[i])
        tips = found
    }
}
