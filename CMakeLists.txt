cmake_minimum_required(VERSION 3.16)
project(LogosDesignSystem VERSION 1.0.0)

# QML source files
set(QML_SOURCES
    src/qml/Theme.qml
    src/qml/ColorPalette.qml
    src/qml/Spacing.qml
    src/qml/Typography.qml
    src/qml/DarkTheme.qml
)

# Installation destination
set(INSTALL_DIR lib/Logos/DesignSystem)

# Install qmldir
install(FILES src/qml/qmldir
    DESTINATION ${INSTALL_DIR}
)

# Install QML files
install(FILES ${QML_SOURCES}
    DESTINATION ${INSTALL_DIR}
)

# Install fonts directory with all TTF files
install(DIRECTORY src/qml/fonts
    DESTINATION ${INSTALL_DIR}
    FILES_MATCHING PATTERN "*.ttf"
)

# Build examples
add_subdirectory(examples)
