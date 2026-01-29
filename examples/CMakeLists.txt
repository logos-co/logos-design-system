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

# Set up QML module directory for runtime
set(QML_MODULE_DIR ${CMAKE_CURRENT_BINARY_DIR}/qml/Logos/DesignSystem)

# Copy QML module files to runtime directory
# Pure QML module - no library, just QML files + qmldir
add_custom_command(TARGET DesignSystemDemo POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory ${QML_MODULE_DIR}
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/src/qml/qmldir ${QML_MODULE_DIR}/
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/src/qml/ ${QML_MODULE_DIR}/
    COMMENT "Setting up pure QML module directory for DesignSystemDemo"
)
