// Example: Theme Switcher Button
// Shows how to add a button that toggles between light and dark themes

import QtQuick
import QtQuick.Controls
import Logos.Theme 1.0
import Logos.Controls 1.0

LogosButton {
    id: themeSwitcher

    // Button text changes based on current theme
    text: Theme.isDark ? "☀️ Light Mode" : "🌙 Dark Mode"

    implicitWidth: 200
    implicitHeight: 36

    // Toggle theme on click
    onClicked: Theme.switchTheme()

    Behavior on opacity {
        NumberAnimation { duration: 150 }
    }
}
