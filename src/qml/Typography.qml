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

    // weights
    readonly property int weightRegular: 400
    readonly property int weightMedium: 500
    readonly property int weightBold: 700

    // Text font sizes
    readonly property int mainTitleText: 256
    readonly property int headerText: 30
    readonly property int secondaryText: 14
}
