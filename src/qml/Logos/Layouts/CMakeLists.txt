# STATIC qt_add_qml_module for Logos.Layouts: the pieces a page is built
# from (bars, panes), arranged by the page's width. Controls go inside them.
# See sibling Theme/ for the per-module CMakeLists rationale.

qt_add_qml_module(logos_layouts_qml
    URI Logos.Layouts
    VERSION 1.0
    STATIC
    RESOURCE_PREFIX /qt/qml
    OUTPUT_TARGETS logos_layouts_extra_targets
    IMPORTS Logos.Theme Logos.Icons Logos.Controls
    QML_FILES
        LogosPageBar.qml
        LogosListDetail.qml
        LogosSections.qml
        LogosCardGrid.qml
        LogosCardPair.qml
        LogosFormField.qml
        LogosFormLayout.qml
        LogosWizard.qml
        LogosWelcome.qml
)

target_link_libraries(logos_layouts_qml PRIVATE logos_theme_qml logos_icons_qml logos_controls_qml)

set(logos_layouts_extra_targets ${logos_layouts_extra_targets} PARENT_SCOPE)
