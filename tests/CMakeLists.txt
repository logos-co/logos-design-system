cmake_minimum_required(VERSION 3.16)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick QuickControls2 Qml QuickTest Test)

add_executable(LogosDesignSystemTests main.cpp test-resources.qrc)

# Tests link the same STATIC design-system target that basecamp / storybook
# use, so `import Logos.Theme|Controls|Icons` resolves from process qrc.
# `logos_design_system` is the INTERFACE target from src/qml/CMakeLists.txt.
target_link_libraries(LogosDesignSystemTests PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Qml
    Qt6::QuickTest
    Qt6::Test
    Logos::DesignSystem
)

# QUICK_TEST_SOURCE_DIR is where Qt's QUICK_TEST_MAIN_WITH_SETUP finds
# tst_*.qml files. Must be a compile-time define — the env var fallback is
# unreliable across ctest invocations.
target_compile_definitions(LogosDesignSystemTests PRIVATE
    QUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}"
)

add_test(NAME LogosDesignSystemTests COMMAND LogosDesignSystemTests)
set_tests_properties(LogosDesignSystemTests PROPERTIES
    ENVIRONMENT "QT_QPA_PLATFORM=offscreen"
)
