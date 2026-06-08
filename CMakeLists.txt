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

# ===== Logos.Icons module =====
# Curated icon set as its own module so icon-only consumers (or chrome-only
# apps) can `import Logos.Icons` without dragging the full controls library in.
set(ICONS_DIR lib/Logos/Icons)
set(ICONS_SOURCES
    src/qml/Logos/Icons/LogosIcons.qml
)

install(FILES src/qml/Logos/Icons/qmldir DESTINATION ${ICONS_DIR})
install(FILES ${ICONS_SOURCES}           DESTINATION ${ICONS_DIR})
install(DIRECTORY src/qml/Logos/Icons/icons
    DESTINATION ${ICONS_DIR}
    FILES_MATCHING PATTERN "*.svg" PATTERN "*.png"
)

# ===== Logos.Controls module =====
set(CONTROLS_DIR lib/Logos/Controls)
set(CONTROLS_SOURCES
    src/qml/Logos/Controls/LogosButton.qml
    src/qml/Logos/Controls/LogosIcon.qml
    src/qml/Logos/Controls/LogosIconButton.qml
    src/qml/Logos/Controls/LogosText.qml
    src/qml/Logos/Controls/LogosTextField.qml
    src/qml/Logos/Controls/LogosTabButton.qml
    src/qml/Logos/Controls/LogosTabBar.qml
    src/qml/Logos/Controls/LogosCheckbox.qml
    src/qml/Logos/Controls/LogosSearchBar.qml
    src/qml/Logos/Controls/LogosComboBox.qml
    src/qml/Logos/Controls/LogosPaginator.qml
    src/qml/Logos/Controls/LogosTable.qml
    src/qml/Logos/Controls/LogosTableColumn.qml
    src/qml/Logos/Controls/LogosSpinner.qml
    src/qml/Logos/Controls/LogosScrollBar.qml
    src/qml/Logos/Controls/LogosTextArea.qml
    src/qml/Logos/Controls/LogosSwitch.qml
    src/qml/Logos/Controls/LogosProgressBar.qml
    src/qml/Logos/Controls/LogosRadioButton.qml
    src/qml/Logos/Controls/LogosSlider.qml
    src/qml/Logos/Controls/LogosMenu.qml
    src/qml/Logos/Controls/LogosMenuItem.qml
    src/qml/Logos/Controls/LogosDialog.qml
    src/qml/Logos/Controls/LogosToolBar.qml
    src/qml/Logos/Controls/LogosToolButton.qml
    src/qml/Logos/Controls/LogosFrame.qml
    src/qml/Logos/Controls/LogosGroupBox.qml
    src/qml/Logos/Controls/LogosSpinBox.qml
    src/qml/Logos/Controls/LogosBadge.qml
    src/qml/Logos/Controls/LogosScrollView.qml
    src/qml/Logos/Controls/LogosToolTip.qml
    src/qml/Logos/Controls/LogosItemDelegate.qml
    src/qml/Logos/Controls/LogosDrawer.qml
    src/qml/Logos/Controls/LogosStackView.qml
    src/qml/Logos/Controls/LogosMenuSeparator.qml
    src/qml/Logos/Controls/LogosToolSeparator.qml
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
