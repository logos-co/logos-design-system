import QtQuick
import QtQuick.Controls

import Logos.Theme

// Themed TabBar that owns a sliding indicator beneath the active tab.
//
// Public API:
//     indicatorColor      color of the selected underline (default: Theme.palette.primary)
//     indicatorHeight     pixel height of the underline (default: 3)
//     animationDuration   slide duration in ms (default: 200)
//     trackColor          full-width baseline under all tabs
//                         (default: Theme.palette.borderHairline)
//
// Use with LogosTabButton.
//
// Example:
//     LogosTabBar {
//         id: bar
//         Layout.fillWidth: true
//         LogosTabButton { text: qsTr("Files");  iconSource: "qrc:/icons/files.svg"  }
//         LogosTabButton { text: qsTr("Images"); iconSource: "qrc:/icons/images.svg" }
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
    property color trackColor: Theme.palette.borderHairline

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias indicatorItem: indicator
    readonly property alias trackItem: track

    background: Item {
        clip: true

        // Low-opacity baseline under every tab; selected segment uses indicatorColor.
        Rectangle {
            id: track
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: Math.max(1, Math.round(root.indicatorHeight / 3))
            color: root.trackColor
        }

        Rectangle {
            id: indicator

            z: 1
            height: root.indicatorHeight
            color: root.indicatorColor
            radius: height / 2
            y: parent.height - height
            x: 0
            width: 0

            property bool ready: true
            visible: ready

            Behavior on x {
                enabled: indicator.ready
                NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
            }
            Behavior on width {
                enabled: indicator.ready
                NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
            }

            function refresh() {
                if (!root.currentItem || root.currentItem.width <= 0)
                    return
                const p = root.currentItem.mapToItem(root, 0, 0)
                indicator.x = p.x
                indicator.width = root.currentItem.width
            }
        }
    }

    onCurrentItemChanged: indicator.refresh()
    onWidthChanged: indicator.refresh()
    onVisibleChanged: if (visible) Qt.callLater(indicator.refresh)
    Component.onCompleted: Qt.callLater(indicator.refresh)

    Connections {
        target: root.currentItem
        ignoreUnknownSignals: true
        function onXChanged() { indicator.refresh() }
        function onWidthChanged() { indicator.refresh() }
    }

    Connections {
        target: root.contentItem
        ignoreUnknownSignals: true
        function onContentXChanged() { indicator.refresh() }
        function onWidthChanged() { indicator.refresh() }
    }
}
