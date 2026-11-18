import QtQuick

// The dimensions of the Logos.Layouts types. Density doesn't scale them; it
// scales the controls inside.
QtObject {
    id: tokens

    required property Sizes size

    readonly property QtObject listDetail: QtObject {
        readonly property int tabletListWidth: 320
        readonly property int desktopListWidth: 360
    }

    readonly property QtObject pageBar: QtObject {
        readonly property int height: 56
        readonly property int phoneHeight: tokens.size.touchTarget
    }

    readonly property QtObject sections: QtObject {
        readonly property int listWidth: 240
    }
}
