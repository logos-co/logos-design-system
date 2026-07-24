# STATIC QML modules for Logos.Theme, Logos.Icons, Logos.Controls.
#
# Each module is defined in its own subdirectory CMakeLists so that
# QML_FILES / RESOURCES stay bare basenames — their path relative to their
# module's CMAKE_CURRENT_SOURCE_DIR matches the qrc destination under
# RESOURCE_PREFIX/Logos/<Module>/ that qt_add_qml_module derives from URI.
#
# Doing it from THIS scope with `QML_FILES Logos/<Mod>/<Name>.qml` produces
# a doubled --resource-path (`/qt/qml/Logos/Controls/Logos/Controls/X.qml`)
# to qmlcachegen. Linux qmlcachegen tolerates the duplication; macOS Qt
# 6.9.2 crashes with SIGBUS (exit 138) somewhere in its AOT type resolution.
# Isolating each module to its own directory keeps qmlcachegen happy on
# every platform.

add_subdirectory(Logos/Theme)
add_subdirectory(Logos/Icons)
add_subdirectory(Logos/Controls)

# ===== Umbrella INTERFACE target =====
#
# One `target_link_libraries(<app> PRIVATE Logos::DesignSystem)` pulls in
# the three backing libs plus their plugin targets under WHOLE_ARCHIVE,
# matching the pattern already used in logos-basecamp for its own
# qt_add_qml_module STATIC libs (see src/CMakeLists.txt: main_ui).
# WHOLE_ARCHIVE is required so the QQmlEngineExtensionPlugin static
# constructor isn't stripped by the linker.

add_library(logos_design_system INTERFACE)

# Exported as Logos::DesignSystem — the short, Qt-idiomatic name that every
# consumer (basecamp, standalone-app, CMake package config) uses. The local
# in-tree name stays `logos_design_system` so it doesn't collide with the
# EXPORT_NAME rewrite; the namespaced alias below lets in-tree targets also
# refer to Logos::DesignSystem, mirroring how consumers see it after
# find_package.
set_target_properties(logos_design_system PROPERTIES EXPORT_NAME DesignSystem)
add_library(Logos::DesignSystem ALIAS logos_design_system)

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

# Aggregate Qt-generated helper targets (resources_N, plugin_init) from
# each sub-module into a single list. install(EXPORT ...) in the top-level
# CMakeLists installs these under the LogosDesignSystemTargets set so
# downstream find_package consumers can resolve every reachable transitive
# dep. Each sub-module set(... PARENT_SCOPE)s its own list into this scope.
set(logos_design_system_extra_targets
    ${logos_theme_extra_targets}
    ${logos_icons_extra_targets}
    ${logos_controls_extra_targets}
    PARENT_SCOPE
)
