# STATIC qt_add_qml_module for Logos.Controls. See sibling Theme/ for the
# per-module CMakeLists rationale.
#
# IMPORTS Logos.Theme + Logos.Icons — several controls (LogosComboBox,
# LogosSearchBar, LogosPaginator, LogosTable, LogosWarningDialog,
# LogosCopyButton) import Logos.Icons; every control transitively depends
# on Logos.Theme's palette / typography singletons. Declaring both under
# IMPORTS lets qmlcachegen resolve their types at build time and AOT-compile
# the bindings; the target_link_libraries below ensures both plugin
# registrations end up in every binary that pulls in Controls.

qt_add_qml_module(logos_controls_qml
    URI Logos.Controls
    VERSION 1.0
    STATIC
    RESOURCE_PREFIX /qt/qml
    OUTPUT_TARGETS logos_controls_extra_targets
    IMPORTS Logos.Theme Logos.Icons
    QML_FILES
        LogosListView.qml
        LogosButton.qml
        LogosIcon.qml
        LogosIconButton.qml
        LogosText.qml
        LogosSelectableText.qml
        LogosCopyButton.qml
        LogosCopyableText.qml
        LogosLink.qml
        LogosTextField.qml
        LogosTabButton.qml
        LogosTabBar.qml
        LogosCheckbox.qml
        LogosSearchBar.qml
        LogosComboBox.qml
        LogosPaginator.qml
        LogosTable.qml
        LogosTableColumn.qml
        LogosSpinner.qml
        LogosScrollBar.qml
        LogosTextArea.qml
        LogosSwitch.qml
        LogosProgressBar.qml
        LogosRadioButton.qml
        LogosSlider.qml
        LogosMenu.qml
        LogosMenuItem.qml
        LogosDialog.qml
        LogosWarningDialog.qml
        LogosToolBar.qml
        LogosToolButton.qml
        LogosFrame.qml
        LogosGroupBox.qml
        LogosSpinBox.qml
        LogosBadge.qml
        LogosScrollView.qml
        LogosToolTip.qml
        LogosItemDelegate.qml
        LogosDrawer.qml
        LogosStackView.qml
        LogosMenuSeparator.qml
        LogosToolSeparator.qml
)

target_link_libraries(logos_controls_qml PRIVATE logos_theme_qml logos_icons_qml)

set(logos_controls_extra_targets ${logos_controls_extra_targets} PARENT_SCOPE)
