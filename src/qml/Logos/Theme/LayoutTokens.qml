import QtQuick

// The dimensions of the Logos.Layouts types. Density doesn't scale them; it
// scales the controls inside.
QtObject {
    id: tokens

    required property Sizes size

    readonly property QtObject cardGrid: QtObject {
        readonly property int maximumWidth: 1200
        readonly property int statCardWidth: 150
        readonly property int tileWidthPhone: 104
        readonly property int tileWidthTablet: 140
        readonly property int tileWidthDesktop: 180
    }

    readonly property QtObject cardPair: QtObject {
        readonly property int minimumMainWidth: 400
        readonly property int minimumSideWidth: 220
    }

    readonly property QtObject form: QtObject {
        readonly property int maximumWidth: 720
        readonly property int labelWidth: 200
    }

    readonly property QtObject itemLayout: QtObject {
        readonly property int minimumContentWidth: 120
        readonly property int lineSpacing: 4
    }

    readonly property QtObject listDetail: QtObject {
        readonly property int tabletListWidth: 320
        readonly property int desktopListWidth: 360
    }

    readonly property QtObject pageBar: QtObject {
        readonly property int height: 56
        readonly property int phoneHeight: tokens.size.touchTarget
    }

    readonly property QtObject sidePanel: QtObject {
        readonly property int width: 320
    }

    readonly property QtObject sidebarLayout: QtObject {
        readonly property int sideWidth: 200
        readonly property int minimumContentWidth: 560
    }

    readonly property QtObject sections: QtObject {
        readonly property int listWidth: 200
        readonly property int tabletListWidth: 168
    }

    readonly property QtObject welcome: QtObject {
        readonly property int maximumWidth: 520
        readonly property int buttonWidth: 320
        readonly property int buttonHeight: 48
        readonly property int logoSize: 48
    }

    readonly property QtObject wizard: QtObject {
        readonly property int railHeight: 4
        readonly property int railLabelText: 11
        readonly property int nextMinWidth: 160
    }
}
