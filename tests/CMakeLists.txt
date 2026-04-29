cmake_minimum_required(VERSION 3.16)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick QuickControls2 Qml QuickTest Test)

add_executable(LogosDesignSystemTests main.cpp test-resources.qrc)

target_link_libraries(LogosDesignSystemTests PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Qml
    Qt6::QuickTest
    Qt6::Test
)

# Bake source paths into the binary:
#   - QUICK_TEST_SOURCE_DIR: required by Qt's QUICK_TEST_MAIN_WITH_SETUP macro
#     to find tst_*.qml files. Must be a compile-time define — the env var
#     fallback is unreliable across ctest invocations.
#   - LOGOS_DS_QML_DIR: import path for Logos.Theme / Logos.Controls, added
#     to each test engine in main.cpp.
target_compile_definitions(LogosDesignSystemTests PRIVATE
    QUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}"
    LOGOS_DS_QML_DIR="${CMAKE_CURRENT_SOURCE_DIR}/../src/qml"
)

add_test(NAME LogosDesignSystemTests COMMAND LogosDesignSystemTests)
set_tests_properties(LogosDesignSystemTests PROPERTIES
    ENVIRONMENT "QT_QPA_PLATFORM=offscreen"
)
