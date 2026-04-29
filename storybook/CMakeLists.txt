cmake_minimum_required(VERSION 3.16)
project(LogosStorybook VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml)

add_executable(LogosStorybook
    main.cpp
    storybook.qrc
)

target_link_libraries(LogosStorybook PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::Qml
)

# Bake in absolute paths so the binary can locate pages and the design-system
# QML modules from the source tree. Lets us hot-reload edits without reinstall.
target_compile_definitions(LogosStorybook PRIVATE
    STORYBOOK_PAGES_DIR="${CMAKE_CURRENT_SOURCE_DIR}/pages"
    LOGOS_DS_QML_DIR="${CMAKE_CURRENT_SOURCE_DIR}/../src/qml"
)

# Mirror the QML modules next to the binary too — useful when running the
# installed/packaged binary without env overrides. Source layout already
# matches the import path so a single recursive copy suffices.
add_custom_command(TARGET LogosStorybook POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/qml
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_CURRENT_SOURCE_DIR}/../src/qml/Logos
        ${CMAKE_CURRENT_BINARY_DIR}/qml/Logos
    COMMENT "Copying Logos.Theme and Logos.Controls QML modules for LogosStorybook"
)
