import QtQuick
import QtTest

import Logos.Icons
import LogosTests

TestCase {
    id: root
    name: "LogosIcons"
    width: 100
    height: 100

    // Every icon named is one that ships: listed in RESOURCES.
    function test_every_icon_ships() {
        let named = 0
        for (const key in LogosIcons) {
            const value = String(LogosIcons[key])
            if (!/\.(svg|png|jpg)$/.test(value)) continue
            ++named
            verify(Resources.exists(value), key + ": " + value)
        }
        verify(named > 20)
    }

    function test_filter_is_the_funnel() {
        verify(String(LogosIcons.filter).endsWith("icons/filter.svg"))
    }
}
