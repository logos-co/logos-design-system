import QtQuick
import QtTest

import Logos.Controls

TestCase {
    name: "LogosMenuSeparator"
    width: 200
    height: 20
    when: windowShown

    LogosMenu {
        id: menu
        LogosMenuSeparator { id: sep }
    }

    function test_alias_resolves() {
        verify(sep.separatorItem)
    }

    function test_separator_color_themed() {
        verify(sep.separatorColor.toString().length > 0)
    }
}
