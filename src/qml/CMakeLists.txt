# STATIC QML modules for Logos.Theme, Logos.Icons, Logos.Controls.
#
# Downstream apps link the exported targets (Logos::Theme etc.). Each module
# is a STATIC qt_add_qml_module: bytecode + assets are baked into the target's
# qrc data, so at runtime `import Logos.Controls` resolves from embedded qrc
# and never from disk — no dependency on the QML disk cache under
# QStandardPaths::CacheLocation, no cross-version staleness on nix-frozen
# mtimes. This replaces the historical loose-file install under lib/Logos/.
#
# Layout: sources live at Logos/<Module>/<Name>.qml relative to this dir, so
# `qt_add_qml_module URI Logos.<Module>` resolves both source paths and the
# qrc destination without needing SOURCE_PREFIX gymnastics.

# ===== Logos.Theme =====

set_source_files_properties(Logos/Theme/Theme.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(logos_theme_qml
    URI Logos.Theme
    VERSION 1.0
    STATIC
    RESOURCE_PREFIX /qt/qml
    OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/Logos/Theme
    OUTPUT_TARGETS logos_theme_extra_targets
    QML_FILES
        Logos/Theme/Theme.qml
        Logos/Theme/ColorPalette.qml
        Logos/Theme/Spacing.qml
        Logos/Theme/Typography.qml
        Logos/Theme/DarkTheme.qml
    RESOURCES
        Logos/Theme/fonts/PublicSans-Bold.ttf
        Logos/Theme/fonts/PublicSans-Medium.ttf
        Logos/Theme/fonts/PublicSans-Regular.ttf
)

# ===== Logos.Icons =====

set_source_files_properties(Logos/Icons/LogosIcons.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(logos_icons_qml
    URI Logos.Icons
    VERSION 1.0
    STATIC
    RESOURCE_PREFIX /qt/qml
    OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/Logos/Icons
    OUTPUT_TARGETS logos_icons_extra_targets
    QML_FILES
        Logos/Icons/LogosIcons.qml
    RESOURCES
        Logos/Icons/icons/arrow-left-double-line.svg
        Logos/Icons/icons/arrow-left-s-line.svg
        Logos/Icons/icons/arrow-right-double-line.svg
        Logos/Icons/icons/arrow-right-s-line.svg
        Logos/Icons/icons/check.svg
        Logos/Icons/icons/close.svg
        Logos/Icons/icons/copy.svg
        Logos/Icons/icons/delete.svg
        Logos/Icons/icons/grid.svg
        Logos/Icons/icons/install.svg
        Logos/Icons/icons/list.svg
        Logos/Icons/icons/more.svg
        Logos/Icons/icons/pages.svg
        Logos/Icons/icons/refresh.svg
        Logos/Icons/icons/search.svg
        Logos/Icons/icons/triangle_down.svg
        Logos/Icons/icons/triangle_up.svg
        Logos/Icons/icons/warning.svg
)

# ===== Logos.Controls =====
#
# IMPORTS Logos.Theme makes qmlcachegen aware of the Theme types at build
# time, so the compiled bytecode inside logos_controls_qml resolves
# `import Logos.Theme` types (Theme, ColorPalette, ...) statically. The
# target_link_libraries below ensures Theme's plugin registration ends up in
# the same binary that pulls in Controls.

qt_add_qml_module(logos_controls_qml
    URI Logos.Controls
    VERSION 1.0
    STATIC
    RESOURCE_PREFIX /qt/qml
    OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/Logos/Controls
    OUTPUT_TARGETS logos_controls_extra_targets
    IMPORTS Logos.Theme
    QML_FILES
        Logos/Controls/LogosButton.qml
        Logos/Controls/LogosIcon.qml
        Logos/Controls/LogosIconButton.qml
        Logos/Controls/LogosText.qml
        Logos/Controls/LogosTextField.qml
        Logos/Controls/LogosTabButton.qml
        Logos/Controls/LogosTabBar.qml
        Logos/Controls/LogosCheckbox.qml
        Logos/Controls/LogosSearchBar.qml
        Logos/Controls/LogosComboBox.qml
        Logos/Controls/LogosPaginator.qml
        Logos/Controls/LogosTable.qml
        Logos/Controls/LogosTableColumn.qml
        Logos/Controls/LogosSpinner.qml
        Logos/Controls/LogosScrollBar.qml
        Logos/Controls/LogosTextArea.qml
        Logos/Controls/LogosSwitch.qml
        Logos/Controls/LogosProgressBar.qml
        Logos/Controls/LogosRadioButton.qml
        Logos/Controls/LogosSlider.qml
        Logos/Controls/LogosMenu.qml
        Logos/Controls/LogosMenuItem.qml
        Logos/Controls/LogosDialog.qml
        Logos/Controls/LogosWarningDialog.qml
        Logos/Controls/LogosToolBar.qml
        Logos/Controls/LogosToolButton.qml
        Logos/Controls/LogosFrame.qml
        Logos/Controls/LogosGroupBox.qml
        Logos/Controls/LogosSpinBox.qml
        Logos/Controls/LogosBadge.qml
        Logos/Controls/LogosScrollView.qml
        Logos/Controls/LogosToolTip.qml
        Logos/Controls/LogosItemDelegate.qml
        Logos/Controls/LogosDrawer.qml
        Logos/Controls/LogosStackView.qml
        Logos/Controls/LogosMenuSeparator.qml
        Logos/Controls/LogosToolSeparator.qml
)

target_link_libraries(logos_controls_qml PRIVATE logos_theme_qml)

# ===== Umbrella INTERFACE target =====
#
# Convenience for consumers: one `target_link_libraries(<app> PRIVATE Logos::DesignSystem)`
# pulls in the three backing libs plus their plugin targets under WHOLE_ARCHIVE,
# matching the pattern already used in logos-basecamp for its own qt_add_qml_module
# STATIC libs (see src/CMakeLists.txt: main_ui). WHOLE_ARCHIVE is required so the
# QQmlEngineExtensionPlugin static constructor isn't stripped by the linker.

add_library(logos_design_system INTERFACE)
# $<TARGET_NAME:foo> makes install(EXPORT) rewrite the local target name to
# its namespaced import alias (Logos::foo) in the generated Targets file.
# Without it, `logos_*_qmlplugin` inside the LINK_LIBRARY genexpr survives
# verbatim into the exported INTERFACE_LINK_LIBRARIES — downstream then
# silently drops the plugin from the link line (no local target of that
# name), and every qmlplugin symbol (qml_register_types_*, qInitResources_
# qmlcache_*) resolves to `undefined` at dlopen.
target_link_libraries(logos_design_system INTERFACE
    logos_theme_qml
    logos_icons_qml
    logos_controls_qml
    $<LINK_LIBRARY:WHOLE_ARCHIVE,$<TARGET_NAME:logos_theme_qmlplugin>>
    $<LINK_LIBRARY:WHOLE_ARCHIVE,$<TARGET_NAME:logos_icons_qmlplugin>>
    $<LINK_LIBRARY:WHOLE_ARCHIVE,$<TARGET_NAME:logos_controls_qmlplugin>>
)

# Aggregate Qt-generated helper targets (resources_N, plugin_init) into a
# single list. install(EXPORT ...) in the top-level CMakeLists installs
# these under the LogosDesignSystemTargets set so downstream find_package
# consumers can resolve every reachable transitive dep.
set(logos_design_system_extra_targets
    ${logos_theme_extra_targets}
    ${logos_icons_extra_targets}
    ${logos_controls_extra_targets}
    PARENT_SCOPE
)
