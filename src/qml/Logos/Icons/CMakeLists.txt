# STATIC qt_add_qml_module for Logos.Icons. See sibling Theme/ for the
# per-module CMakeLists rationale (avoids the doubled-URI-path qmlcachegen
# SIGBUS on macOS).

set_source_files_properties(LogosIcons.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(logos_icons_qml
    URI Logos.Icons
    VERSION 1.0
    STATIC
    RESOURCE_PREFIX /qt/qml
    OUTPUT_TARGETS logos_icons_extra_targets
    QML_FILES
        LogosIcons.qml
    RESOURCES
        icons/arrow-left-double-line.svg
        icons/arrow-left-s-line.svg
        icons/arrow-right-double-line.svg
        icons/arrow-right-s-line.svg
        icons/check.svg
        icons/close.svg
        icons/copy.svg
        icons/delete.svg
        icons/grid.svg
        icons/install.svg
        icons/list.svg
        icons/more.svg
        icons/pages.svg
        icons/refresh.svg
        icons/search.svg
        icons/triangle_down.svg
        icons/triangle_up.svg
        icons/warning.svg
        icons/info.svg
)

set(logos_icons_extra_targets ${logos_icons_extra_targets} PARENT_SCOPE)
