import QtQuick

QtObject {
    //  font family
    readonly property FontLoader publicSansRegular: FontLoader {
        source: Qt.resolvedUrl("fonts/PublicSans-Regular.ttf")
    }
    readonly property FontLoader publicSansMedium: FontLoader {
        source: Qt.resolvedUrl("fonts/PublicSans-Medium.ttf")
    }
    readonly property FontLoader publicSansBold: FontLoader {
        source: Qt.resolvedUrl("fonts/PublicSans-Bold.ttf")
    }
    readonly property string publicSans: "Public Sans"

    // weighteights
    readonly property int weightRegular: 400
    readonly property int weightMedium: 500
    readonly property int weightBold: 700

    readonly property QtObject primary: QtObject {
        readonly property string family: publicSans
        readonly property int size: 256
        readonly property int weight: weightBold
        readonly property real lineHeight: 230.4
        readonly property real letterSpacing: -0.04
    }

    readonly property QtObject secondary: QtObject {
        readonly property string family: publicSans
        readonly property int size: 30
        readonly property int weight: weightBold
        readonly property real lineHeight: 33
        readonly property real letterSpacing: 0
    }

    readonly property QtObject tertiary: QtObject {
        readonly property string family: publicSans
        readonly property int size: 30
        readonly property int weight: weightMedium
        readonly property real lineHeight: 33
        readonly property real letterSpacing: 0
    }
}
