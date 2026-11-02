# STATIC qt_add_qml_module for Logos.Theme.
#
# Placed under Logos/Theme/ so QML_FILES / RESOURCES stay as bare basenames —
# their filesystem path relative to CMAKE_CURRENT_SOURCE_DIR then matches
# their qrc destination under RESOURCE_PREFIX/Logos/Theme/. From a parent
# scope the same qt_add_qml_module gets qmlcachegen called with a doubled
# `Logos/Theme/Logos/Theme/<name>.qml` --resource-path, which crashes
# qmlcachegen with SIGBUS on macOS Qt 6.9.2 (exit 138). See the top-level
# src/qml/CMakeLists.txt for the umbrella target that pulls these three
# modules together.

set_source_files_properties(Theme.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(logos_theme_qml
    URI Logos.Theme
    VERSION 1.0
    STATIC
    RESOURCE_PREFIX /qt/qml
    OUTPUT_TARGETS logos_theme_extra_targets
    SOURCES
        ThemeStore.h
        ThemeStore.cpp
        ThemeRegistry.h
        ThemeRegistry.cpp
        ThemeInstaller.h
        ThemeInstaller.cpp
    QML_FILES
        Theme.qml
        ColorPalette.qml
        Spacing.qml
        Typography.qml
        DarkTheme.qml
    RESOURCES
        fonts/PublicSans-Bold.ttf
        fonts/PublicSans-Medium.ttf
        fonts/PublicSans-Regular.ttf
)

# ThemeStore parses theme.json with QJsonDocument and hands QColor values
# to QML.
target_link_libraries(logos_theme_qml PRIVATE Qt6::Core Qt6::Gui Qt6::Qml)

# Logos::ThemeStore and Logos::ThemeInstaller are public C++ API for hosts.
include(GNUInstallDirs)
target_include_directories(logos_theme_qml PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/LogosDesignSystem>)
install(FILES ThemeStore.h ThemeInstaller.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/LogosDesignSystem)

# Bubble Qt-generated helper targets (resources_N, plugin_init) up to
# src/qml/CMakeLists.txt so install(EXPORT ...) can include them.
set(logos_theme_extra_targets ${logos_theme_extra_targets} PARENT_SCOPE)
