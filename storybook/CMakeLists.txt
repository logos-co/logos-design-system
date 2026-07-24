cmake_minimum_required(VERSION 3.16)
project(LogosStorybook VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick QuickControls2 Qml)

add_executable(LogosStorybook
    main.cpp
    storybook.qrc
)

# Storybook links the SAME STATIC design-system target that basecamp and
# logos-standalone-app do, so `import Logos.Theme/.Controls/.Icons` resolves
# from process qrc — no loose-file scanning, no LOGOS_DS_QML_DIR compile-def,
# no post-build copy_directory. This also makes the storybook a real smoke
# test for the STATIC linkage that downstream apps depend on: if the exported
# `Logos::DesignSystem` target regresses, this build catches it.
#
# The Logos::DesignSystem INTERFACE target is defined by src/qml/CMakeLists.txt
# (added via add_subdirectory in the top-level CMakeLists), so it's addressable
# by its namespaced alias here — no find_package needed for in-tree use, and
# the name matches what downstream consumers see post-install.
target_link_libraries(LogosStorybook PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Qml
    Logos::DesignSystem
)

# Pages (the storybook's own demo content, one .qml per component) stay loose
# because HotReloader watches them for on-the-fly edits — the whole point of
# the storybook. STORYBOOK_PAGES_DIR bakes the source-tree path into the dev
# build; runtime install layout ($out/lib/pages) is picked up by main.cpp's
# fallback resolver.
target_compile_definitions(LogosStorybook PRIVATE
    STORYBOOK_PAGES_DIR="${CMAKE_CURRENT_SOURCE_DIR}/pages"
)
