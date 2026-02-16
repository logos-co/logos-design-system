cmake_minimum_required(VERSION 3.16)
project(DesignSystemDemo VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# Find Qt packages
find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml)

# Create executable
add_executable(DesignSystemDemo 
    main.cpp
    examples.qrc
)

# Link Qt libraries
target_link_libraries(DesignSystemDemo PRIVATE 
    Qt6::Core 
    Qt6::Gui
    Qt6::Quick
    Qt6::Qml
)

# Set up QML module directories for runtime
# CMAKE_CURRENT_SOURCE_DIR is examples/; QML sources live in project root src/qml/
set(DESIGN_SYSTEM_QML ${CMAKE_CURRENT_SOURCE_DIR}/../src/qml)
set(QML_THEME_DIR ${CMAKE_CURRENT_BINARY_DIR}/qml/Logos/Theme)
set(QML_CONTROLS_DIR ${CMAKE_CURRENT_BINARY_DIR}/qml/Logos/Controls)

add_custom_command(TARGET DesignSystemDemo POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory ${QML_THEME_DIR}
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${DESIGN_SYSTEM_QML}/theme/ ${QML_THEME_DIR}/
    COMMAND ${CMAKE_COMMAND} -E make_directory ${QML_CONTROLS_DIR}
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${DESIGN_SYSTEM_QML}/controls/ ${QML_CONTROLS_DIR}/
    COMMENT "Setting up Logos.Theme and Logos.Controls QML modules for DesignSystemDemo"
)
