import QtQuick

// Each control's own dimensions. Values shared between controls come from
// Sizes and Spacing; the rest are the control's own. Strokes are read from
// Theme.size directly.
QtObject {
    id: tokens

    required property Sizes size
    required property Spacing spacing

    readonly property QtObject artwork: QtObject {
        readonly property int size: tokens.size.controlLarge
    }

    readonly property QtObject badge: QtObject {
        readonly property int iconSize: tokens.size.iconXSmall
        readonly property int fontSize: 11
        readonly property real letterSpacing: 0.22
    }

    readonly property QtObject button: QtObject {
        readonly property int height: tokens.size.controlXLarge
        readonly property int compactHeight: tokens.size.controlSmall
        readonly property int minWidth: 100
        readonly property int compactMinWidth: 72
        readonly property int iconSize: tokens.size.iconMedium
    }

    readonly property QtObject checkbox: QtObject {
        readonly property int indicatorSize: tokens.size.controlXSmall
    }

    readonly property QtObject combo: QtObject {
        readonly property int height: tokens.size.controlSmall
        readonly property int paddingX: 10
        readonly property int indicatorSize: tokens.size.iconMedium
        readonly property int popupGap: 2
    }

    readonly property QtObject copyButton: QtObject {
        readonly property int size: tokens.size.controlXSmall
        readonly property int iconSize: tokens.size.iconSmall
    }

    readonly property QtObject dotMatrix: QtObject {
        readonly property int dotSize: 8
    }

    readonly property QtObject field: QtObject {
        readonly property int width: 200
        readonly property int height: tokens.size.controlLarge
        readonly property int paddingX: tokens.spacing.medium
    }

    readonly property QtObject icon: QtObject {
        readonly property int size: tokens.size.iconMedium
    }

    readonly property QtObject iconButton: QtObject {
        readonly property int size: tokens.size.controlLarge
        readonly property int iconSize: tokens.size.iconMedium
    }

    readonly property QtObject infoButton: QtObject {
        readonly property int size: tokens.size.iconSmall
        readonly property int fontSize: 9
        readonly property int dialogWidth: 560
    }

    readonly property QtObject listItem: QtObject {
        readonly property int height: tokens.size.controlMedium
    }

    readonly property QtObject menu: QtObject {
        readonly property int width: 200
    }

    readonly property QtObject menuItem: QtObject {
        readonly property int height: tokens.size.controlSmall
    }

    readonly property QtObject notice: QtObject {
        readonly property int iconPlateSize: 28
        readonly property int iconSize: tokens.size.iconSmall
        readonly property int closeButtonSize: tokens.size.iconMedium
        readonly property int closeIconSize: tokens.size.iconXSmall
    }

    readonly property QtObject paginator: QtObject {
        readonly property int height: tokens.size.controlMedium
        readonly property int buttonSize: tokens.size.controlMedium
        readonly property int buttonMinWidth: tokens.size.controlXSmall
        readonly property int pageSizeMinWidth: 80
        readonly property int pageSizeWidth: 130
    }

    readonly property QtObject progressBar: QtObject {
        readonly property int width: 200
        readonly property int height: 8
    }

    readonly property QtObject radio: QtObject {
        readonly property int indicatorSize: 22
        readonly property int dotSize: 8
    }

    readonly property QtObject scrollBar: QtObject {
        readonly property int thickness: 6
    }

    readonly property QtObject search: QtObject {
        readonly property int width: 400
        readonly property int height: 54
        readonly property int paddingLeft: 10
        readonly property int iconSize: tokens.size.iconMedium
        readonly property int clearButtonSize: tokens.size.iconMedium
        readonly property int clearIconSize: 14
        readonly property int hintHeight: 20
    }

    readonly property QtObject slider: QtObject {
        readonly property int width: 200
        readonly property int trackHeight: 4
        readonly property int handleSize: 18
    }

    readonly property QtObject spinBox: QtObject {
        readonly property int height: tokens.size.controlSmall
        readonly property int buttonWidth: 28
    }

    readonly property QtObject spinner: QtObject {
        readonly property int size: tokens.size.controlMedium
        readonly property int thickness: 3
        readonly property int dotSize: 6
        readonly property int dotInset: 2
    }

    readonly property QtObject stageLane: QtObject {
        readonly property int width: 200
        readonly property int height: 30
        readonly property int notch: 14
        readonly property int gap: 2
        readonly property int cornerRadius: 3
    }

    readonly property QtObject statCard: QtObject {
        readonly property int minHeight: 108
        readonly property int iconSize: tokens.size.iconSmall
    }

    readonly property QtObject tab: QtObject {
        readonly property int height: tokens.size.controlLarge
        readonly property int spacing: 6
        readonly property int iconSize: tokens.size.iconMedium
        readonly property int underlineHeight: 2
    }

    readonly property QtObject tabBar: QtObject {
        readonly property int indicatorHeight: 3
    }

    readonly property QtObject table: QtObject {
        readonly property int rowHeight: 64
        readonly property int headerHeight: tokens.size.controlMedium
        readonly property int columnMinWidth: 80
        readonly property int selectionColumnWidth: tokens.size.controlLarge
        readonly property int sortIconWidth: tokens.size.iconXSmall
        readonly property int sortIconHeight: 8
    }

    readonly property QtObject tile: QtObject {
        readonly property int size: tokens.size.controlLarge
    }

    // LogosSwitch (`switch` is reserved in JavaScript).
    readonly property QtObject toggle: QtObject {
        readonly property int width: 40
        readonly property int height: tokens.size.controlXSmall
        readonly property int trackWidth: 36
        readonly property int trackHeight: 20
    }

    readonly property QtObject toolButton: QtObject {
        readonly property int size: tokens.size.controlMedium
    }

    readonly property QtObject toolSeparator: QtObject {
        readonly property int length: tokens.size.controlXSmall
    }

    readonly property QtObject toolTip: QtObject {
        readonly property int height: 20
        readonly property int paddingX: 6
        readonly property int paddingY: 2
    }

    readonly property QtObject warningDialog: QtObject {
        readonly property int iconSize: 18
    }
}
