import QtQuick
import QtQuick.Controls

import Logos.Theme

// Themed TabBar that owns a sliding indicator beneath the active tab.
//
// Public API:
//     indicatorColor      color of the underline (default: Theme.palette.primary)
//     indicatorHeight     pixel height of the underline (default: 3)
//     animationDuration   slide duration in ms (default: 200)
//
// Use with LogosTabButton.
//
// Example:
//     LogosTabBar {
//         id: bar
//         Layout.fillWidth: true
//         LogosTabButton { text: qsTr("Files");  icon.source: "qrc:/icons/files.svg"  }
//         LogosTabButton { text: qsTr("Images"); icon.source: "qrc:/icons/images.svg" }
//         LogosTabButton { text: qsTr("Videos") }
//     }
//
//     StackLayout {
//         Layout.fillWidth: true
//         Layout.fillHeight: true
//         currentIndex: bar.currentIndex
//
//         FilesView  {}
//         ImagesView {}
//         VideosView {}
//     }
TabBar {
    id: root

    property color indicatorColor: Theme.palette.primary
    property int indicatorHeight: 3
    property int animationDuration: 200

    background: Rectangle {
        color: "transparent"
    }

    Rectangle {
        id: indicator

        z: 1
        height: root.indicatorHeight
        color: root.indicatorColor
        radius: height / 2
        y: root.height - height
        x: 0
        width: 0

        // Suppresses the first-paint slide-from-(0,0) flash; flipped on after
        // the initial geometry settles.
        property bool ready: false
        visible: ready && root.currentItem

        Behavior on x {
            enabled: indicator.ready
            NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
        }
        Behavior on width {
            enabled: indicator.ready
            NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
        }

        function refresh() {
            if (!root.currentItem)
                return
            const p = root.currentItem.mapToItem(root, 0, 0)
            indicator.x = p.x
            indicator.width = root.currentItem.width
        }
    }

    onCurrentItemChanged: indicator.refresh()
    onWidthChanged: indicator.refresh()

    Connections {
        target: root.currentItem
        ignoreUnknownSignals: true
        function onXChanged() { indicator.refresh() }
        function onWidthChanged() { indicator.refresh() }
    }

    Component.onCompleted: {
        indicator.refresh()
        Qt.callLater(function() { indicator.ready = true })
    }
}
