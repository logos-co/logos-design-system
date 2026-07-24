# 3.24 is required for `$<LINK_LIBRARY:WHOLE_ARCHIVE,...>` used in
# src/qml/CMakeLists.txt's umbrella INTERFACE target. Older CMake silently
# drops that generator expression, so the qmlplugin static-init symbols
# would never get pulled into consuming binaries and Logos.* registration
# would silently no-op — every consumer would fail at first `import Logos.*`.
cmake_minimum_required(VERSION 3.24)
project(LogosDesignSystem VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Qml Quick QuickControls2)
qt_standard_project_setup(REQUIRES 6.5)

# Build the STATIC qt_add_qml_module targets for Logos.Theme / .Icons /
# .Controls. See src/qml/CMakeLists.txt for the module definitions and the
# Logos::DesignSystem umbrella target consumers link. The storybook and
# tests below link the same target — one code path for QML loading across
# every build in the repo.
add_subdirectory(src/qml)

# ===== Install + export =====
#
# Downstream apps discover the STATIC targets via find_package(LogosDesignSystem
# CONFIG). The umbrella `logos_design_system` INTERFACE target is exported as
# Logos::DesignSystem — linking it pulls in every backing lib + plugin
# with the right WHOLE_ARCHIVE flag.

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

install(TARGETS
    logos_theme_qml    logos_theme_qmlplugin
    logos_icons_qml    logos_icons_qmlplugin
    logos_controls_qml logos_controls_qmlplugin
    logos_design_system
    ${logos_design_system_extra_targets}
    EXPORT LogosDesignSystemTargets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    # Qt's qt_add_qml_module STATIC builds two OBJECT libraries per module for
    # its resource compilation intermediates (logos_<mod>_qml_resources_N,
    # logos_<mod>_qmlplugin_init). Without OBJECTS DESTINATION, the exported
    # target's `$<TARGET_OBJECTS:...>` reference dangles at find_package time.
    OBJECTS DESTINATION ${CMAKE_INSTALL_LIBDIR}/objects
)

install(EXPORT LogosDesignSystemTargets
    FILE   LogosDesignSystemTargets.cmake
    NAMESPACE Logos::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/LogosDesignSystem
)

configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/LogosDesignSystemConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/LogosDesignSystemConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/LogosDesignSystem
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/LogosDesignSystemConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/LogosDesignSystemConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/LogosDesignSystemConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/LogosDesignSystem
)

# ===== Storybook + tests (opt-in) =====
#
# Storybook and tests still consume Logos.* via LOGOS_DS_QML_DIR pointing at
# the source tree — the STATIC install path is for downstream apps, not for
# the design-system's own dev harness.

option(LOGOS_DS_BUILD_STORYBOOK "Build the design-system storybook host app" OFF)
if(LOGOS_DS_BUILD_STORYBOOK)
    add_subdirectory(storybook)
endif()

option(LOGOS_DS_BUILD_TESTS "Build the design-system QML unit tests" OFF)
if(LOGOS_DS_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()
