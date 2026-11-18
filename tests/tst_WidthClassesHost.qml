import QtQuick
import QtTest

import LogosTests

// ThemeManager::followViewWidth, as Basecamp calls it for each app view. In a
// file of its own: on Qt 6.7 a second engine that loads Logos.Theme breaks the
// Theme of the engine the tests run in, so nothing else may run here after it.
TestCase {
    name: "WidthClassesHost"
    when: windowShown

    function test_hostKeepsTheViewWidth() {
        compare(ThemeTestHelper.viewClassesFollowing(390, 1024), ["phone", "desktop"])
    }
}
