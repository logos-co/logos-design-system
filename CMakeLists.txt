cmake_minimum_required(VERSION 3.16)
project(LogosDesignSystem VERSION 1.0.0)

# Source layout mirrors the QML import path so `import Logos.Theme` resolves
# from the source tree directly (no install-time path rewrite needed).

# ===== Logos.Theme module =====
set(THEME_DIR lib/Logos/Theme)
set(THEME_SOURCES
    src/qml/Logos/Theme/Theme.qml
    src/qml/Logos/Theme/ColorPalette.qml
    src/qml/Logos/Theme/Spacing.qml
    src/qml/Logos/Theme/Typography.qml
    src/qml/Logos/Theme/DarkTheme.qml
)

install(FILES src/qml/Logos/Theme/qmldir DESTINATION ${THEME_DIR})
install(FILES ${THEME_SOURCES}           DESTINATION ${THEME_DIR})
install(DIRECTORY src/qml/Logos/Theme/fonts
    DESTINATION ${THEME_DIR}
    FILES_MATCHING PATTERN "*.ttf"
)

# ===== Logos.Controls module =====
set(CONTROLS_DIR lib/Logos/Controls)
set(CONTROLS_SOURCES
    src/qml/Logos/Controls/LogosButton.qml
    src/qml/Logos/Controls/LogosText.qml
    src/qml/Logos/Controls/LogosTextField.qml
    src/qml/Logos/Controls/LogosTabButton.qml
    src/qml/Logos/Controls/LogosTabBar.qml
)

install(FILES src/qml/Logos/Controls/qmldir DESTINATION ${CONTROLS_DIR})
install(FILES ${CONTROLS_SOURCES}           DESTINATION ${CONTROLS_DIR})

# Build storybook (opt-in: host app for browsing components + token catalog)
option(LOGOS_DS_BUILD_STORYBOOK "Build the design-system storybook host app" OFF)
if(LOGOS_DS_BUILD_STORYBOOK)
    add_subdirectory(storybook)
endif()

# Build QML unit tests (opt-in)
option(LOGOS_DS_BUILD_TESTS "Build the design-system QML unit tests" OFF)
if(LOGOS_DS_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()
