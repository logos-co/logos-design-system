import QtQuick

QtObject {
    // Set by Theme: the view is phone-wide; targets are touch-sized.
    property bool phone: false
    property bool touch: false

    //  font family - using resolved URL for better compatibility
    readonly property FontLoader publicSansRegular: FontLoader {
        source: Qt.resolvedUrl("fonts/PublicSans-Regular.ttf")
        onStatusChanged: if (status == FontLoader.Error) console.warn("Failed to load PublicSans-Regular")
    }
    readonly property FontLoader publicSansMedium: FontLoader {
        source: Qt.resolvedUrl("fonts/PublicSans-Medium.ttf")
        onStatusChanged: if (status == FontLoader.Error) console.warn("Failed to load PublicSans-Medium")
    }
    readonly property FontLoader publicSansBold: FontLoader {
        source: Qt.resolvedUrl("fonts/PublicSans-Bold.ttf")
        onStatusChanged: if (status == FontLoader.Error) console.warn("Failed to load PublicSans-Bold")
    }
    // Fallback to system font if custom font fails
    readonly property string publicSans: publicSansRegular.status == FontLoader.Ready ? publicSansRegular.name : "sans-serif"

    // Family for hex identifiers, addresses and code, where fixed-width glyphs
    // aid scanning and copying. No monospace face is bundled, so this resolves
    // to the platform's own.
    readonly property string mono: "monospace"

    // weights
    readonly property int weightRegular: 400
    readonly property int weightMedium: 500
    readonly property int weightBold: 700

    // Text font sizes (descending hierarchy). In a phone-wide view the titles
    // step down; where targets are touch-sized, badge text grows to stay legible.
    readonly property int mainTitleText: phone ? 96 : 256   // splash / marketing
    readonly property int displayText: phone ? 28 : 40      // a welcome or hero line
    readonly property int pageTitleText: phone ? 28 : 36    // page-level headline
    readonly property int titleText: phone ? 24 : 30        // section / dialog title
    readonly property int panelTitleText: phone ? 20 : 24   // panel / table title
    readonly property int subtitleText: 16     // page subtitle / lead body
    readonly property int primaryText: 14      // default body text
    readonly property int secondaryText: 12    // caption / small text
    readonly property int badgeText: touch ? 10 : 8         // badge / tiny text
}
