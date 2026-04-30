import QtQuick
import QtQuick.Controls

import Logos.Theme

MenuSeparator {
    id: root

    property color separatorColor: Theme.palette.borderHairline

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias separatorItem: line

    padding: Theme.spacing.tiny

    contentItem: Rectangle {
        id: line
        implicitHeight: 1
        color: root.separatorColor
    }
}
