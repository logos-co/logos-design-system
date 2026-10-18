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

    // Text size multiplier, from the person's setting (Theme.setTextScale).
    property real scale: 1.0
    function scaled(size) { return Math.round(size * scale) }

    // Text font sizes (descending hierarchy), scaled
    readonly property int mainTitleText: scaled(256)   // splash / marketing
    readonly property int pageTitleText: scaled(36)    // page-level headline
    readonly property int titleText: scaled(30)        // section / dialog title
    readonly property int panelTitleText: scaled(24)   // panel / table title
    readonly property int subtitleText: scaled(16)     // page subtitle / lead body
    readonly property int primaryText: scaled(14)      // default body text
    readonly property int secondaryText: scaled(12)    // caption / small text
    readonly property int badgeText: scaled(8)         // badge / tiny text
}
