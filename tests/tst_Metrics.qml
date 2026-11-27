import QtQuick
import QtTest

import Logos.Theme
import LogosTests

// ThemeStore::metric(), the sizes C++ reads, is Theme's: every C++ value is the
// QML token's, and every QML spacing, size and view-independent typography
// number is in C++. A token added on one side only fails here.
TestCase {
    name: "Metrics"

    // Typography's numbers that change with the view (a phone, touch): QML's only.
    readonly property var viewDependent: ["mainTitleText", "displayText", "pageTitleText",
                                          "titleText", "panelTitleText", "badgeText"]

    function group(name) {
        return { spacing: Theme.spacing, size: Theme.size, typography: Theme.typography }[name]
    }

    function test_cppValuesAreTheQmlTokens() {
        const tokens = ThemeTestHelper.metricTokens()
        verify(tokens.length > 0)
        for (const token of tokens) {
            const [g, name] = token.split(".")
            verify(group(g) !== undefined, token + ": no Theme." + g)
            compare(ThemeTestHelper.metric(token), group(g)[name], token)
        }
    }

    function test_everyQmlNumberIsInCpp() {
        const tokens = ThemeTestHelper.metricTokens()
        for (const g of ["spacing", "size", "typography"]) {
            for (const name in group(g)) {
                if (typeof group(g)[name] !== "number" || viewDependent.indexOf(name) >= 0)
                    continue
                verify(tokens.indexOf(g + "." + name) >= 0,
                       "Theme." + g + "." + name + " is missing from ThemeStore's metrics")
            }
        }
    }

    function test_unknownTokenIsZero() {
        compare(ThemeTestHelper.metric("spacing.nope"), 0)
    }
}
