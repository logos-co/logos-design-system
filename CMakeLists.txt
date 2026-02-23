cmake_minimum_required(VERSION 3.16)
project(LogosDesignSystem VERSION 1.0.0)

# ===== Logos.Theme module =====
set(THEME_DIR lib/Logos/Theme)
set(THEME_SOURCES
    src/qml/theme/Theme.qml
    src/qml/theme/ColorPalette.qml
    src/qml/theme/Spacing.qml
    src/qml/theme/Typography.qml
    src/qml/theme/DarkTheme.qml
)

install(FILES src/qml/theme/qmldir DESTINATION ${THEME_DIR})
install(FILES ${THEME_SOURCES}     DESTINATION ${THEME_DIR})
install(DIRECTORY src/qml/theme/fonts
    DESTINATION ${THEME_DIR}
    FILES_MATCHING PATTERN "*.ttf"
)

# ===== Logos.Controls module =====
set(CONTROLS_DIR lib/Logos/Controls)
set(CONTROLS_SOURCES
    src/qml/controls/LogosButton.qml
    src/qml/controls/LogosText.qml
    src/qml/controls/LogosTextField.qml
    src/qml/controls/LogosTabButton.qml
)

install(FILES src/qml/controls/qmldir DESTINATION ${CONTROLS_DIR})
install(FILES ${CONTROLS_SOURCES}      DESTINATION ${CONTROLS_DIR})

# Build examples
add_subdirectory(examples)
