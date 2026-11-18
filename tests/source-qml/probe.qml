import QtQuick
import Logos.Theme

// Loaded from src/qml with no C++ (no ThemeRegistry), as apps' scene tests
// load the design system. Theme must still give Dark's palette. Exit code:
// 0 ok, 3 empty palette, 4 not Dark, 5 no size tokens. (console output is not shown by `qml`.)
Item {
    Component.onCompleted: {
        const p = Theme.palette
        if (!p || p.background === undefined)
            Qt.exit(3)
        else if (Theme.currentTheme !== "dark" || Theme.themeNames.length !== 1)
            Qt.exit(4)
        else if (!Theme.size || !Theme.controls || Theme.controls.button.height !== Theme.size.controlXLarge)
            Qt.exit(5)
        else
            Qt.exit(0)
    }
}
