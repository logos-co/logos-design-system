import QtQuick
import QtQuick.Controls

import Logos.Theme
import Logos.Controls

// A vertically-oriented list view with the design-system's default scroll
// behavior baked in: LogosScrollBar attached on the right (with the standard
// 4-px inset from the ListView's right border)
// Example:
//     LogosListView {
//         Layout.preferredWidth: 200
//         Layout.fillHeight: true
//         model: categories
//         header: LogosText { text: qsTr("Categories") }
//         delegate: LogosItemDelegate {
//             width: ListView.view.width
//             text: modelData
//             onClicked: ...
//         }
//     }
ListView {
    id: root

    clip: true
    spacing: Theme.spacing.tiny
    boundsBehavior: Flickable.StopAtBounds

    ScrollBar.vertical: LogosScrollBar {
        policy: ScrollBar.AsNeeded
        visible: root.contentHeight > root.height
        rightPadding: Theme.spacing.tiny
    }
}
