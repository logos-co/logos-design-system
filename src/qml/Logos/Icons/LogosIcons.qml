pragma Singleton
import QtQuick

QtObject {
    // Arrows
    readonly property url arrowLeft:        Qt.resolvedUrl("icons/arrow-left-s-line.svg")
    readonly property url arrowLeftDouble:  Qt.resolvedUrl("icons/arrow-left-double-line.svg")
    readonly property url arrowRight:       Qt.resolvedUrl("icons/arrow-right-s-line.svg")
    readonly property url arrowRightDouble: Qt.resolvedUrl("icons/arrow-right-double-line.svg")
    readonly property url triangleUp:       Qt.resolvedUrl("icons/triangle_up.svg")
    readonly property url triangleDown:     Qt.resolvedUrl("icons/triangle_down.svg")

    // Actions
    readonly property url refresh:  Qt.resolvedUrl("icons/refresh.svg")
    readonly property url install:  Qt.resolvedUrl("icons/install.svg")
    readonly property url trash:    Qt.resolvedUrl("icons/delete.svg")
    readonly property url more:     Qt.resolvedUrl("icons/more.svg")
    readonly property url search:   Qt.resolvedUrl("icons/search.svg")
    readonly property url close:    Qt.resolvedUrl("icons/close.svg")
    readonly property url copy:     Qt.resolvedUrl("icons/copy.svg")
    readonly property url check:    Qt.resolvedUrl("icons/check.svg")

    // View modes
    readonly property url grid:     Qt.resolvedUrl("icons/grid.svg")
    readonly property url list:     Qt.resolvedUrl("icons/list.svg")
    readonly property url pages:    Qt.resolvedUrl("icons/pages.svg")

    // Status
    readonly property url warning:  Qt.resolvedUrl("icons/warning.svg")
    readonly property url info:     Qt.resolvedUrl("icons/info.svg")
}
