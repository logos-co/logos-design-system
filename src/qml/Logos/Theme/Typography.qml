import QtQuick

QtObject {
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

    // Text font sizes (descending hierarchy)
    readonly property int mainTitleText: 256   // splash / marketing
    readonly property int pageTitleText: 36    // page-level headline
    readonly property int titleText: 30        // section / dialog title
    readonly property int panelTitleText: 24   // panel / table title
    readonly property int subtitleText: 16     // page subtitle / lead body
    readonly property int primaryText: 14      // default body text
    readonly property int secondaryText: 12    // caption / small text
    readonly property int badgeText: 8         // badge / tiny text
}
