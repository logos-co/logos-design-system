import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

ApplicationWindow {
    id: window

    visible: true
    width: 1280
    height: 800
    title: "Logos Design System Storybook"
    color: Theme.palette.background

    property string currentPage: settings.lastPage

    Settings {
        id: settings
        category: "LogosStorybook"
        property string lastPage: "ColorsPage.qml"
    }

    // Pages on the left, content on the right. Sections grouped by `section`.
    readonly property var pages: [
        { section: "Tokens",   title: "Colors",         file: "ColorsPage.qml" },
        { section: "Tokens",   title: "Icons",          file: "LogosIconsPage.qml" },
        { section: "Tokens",   title: "Spacing",        file: "SpacingPage.qml" },
        { section: "Tokens",   title: "Typography",     file: "TypographyPage.qml" },
        { section: "Controls", title: "LogosBadge",     file: "LogosBadgePage.qml" },
        { section: "Controls", title: "LogosButton",    file: "LogosButtonPage.qml" },
        { section: "Controls", title: "LogosIconButton", file: "LogosIconButtonPage.qml" },
        { section: "Controls", title: "LogosCheckbox",  file: "LogosCheckboxPage.qml" },
        { section: "Controls", title: "LogosComboBox",  file: "LogosComboBoxPage.qml" },
        { section: "Controls", title: "LogosPaginator", file: "LogosPaginatorPage.qml" },
        { section: "Controls", title: "LogosSearchBar", file: "LogosSearchBarPage.qml" },
        { section: "Controls", title: "LogosTabBar",    file: "LogosTabBarPage.qml" },
        { section: "Controls", title: "LogosTable",     file: "LogosTablePage.qml" },
        { section: "Controls", title: "LogosText",      file: "LogosTextPage.qml" },
        { section: "Controls", title: "LogosTextField", file: "LogosTextFieldPage.qml" },
        { section: "Controls", title: "LogosToolTip",   file: "LogosToolTipPage.qml" },

        { section: "Controls (not designed)", title: "LogosDialog",         file: "LogosDialogPage.qml" },
        { section: "Controls (not designed)", title: "LogosDrawer",         file: "LogosDrawerPage.qml" },
        { section: "Controls (not designed)", title: "LogosFrame",          file: "LogosFramePage.qml" },
        { section: "Controls (not designed)", title: "LogosGroupBox",       file: "LogosGroupBoxPage.qml" },
        { section: "Controls (not designed)", title: "LogosItemDelegate",   file: "LogosItemDelegatePage.qml" },
        { section: "Controls (not designed)", title: "LogosMenu",           file: "LogosMenuPage.qml" },
        { section: "Controls (not designed)", title: "LogosMenuSeparator",  file: "LogosMenuSeparatorPage.qml" },
        { section: "Controls (not designed)", title: "LogosProgressBar",    file: "LogosProgressBarPage.qml" },
        { section: "Controls (not designed)", title: "LogosRadioButton",    file: "LogosRadioButtonPage.qml" },
        { section: "Controls (not designed)", title: "LogosScrollBar",      file: "LogosScrollBarPage.qml" },
        { section: "Controls (not designed)", title: "LogosScrollView",     file: "LogosScrollViewPage.qml" },
        { section: "Controls (not designed)", title: "LogosSlider",         file: "LogosSliderPage.qml" },
        { section: "Controls (not designed)", title: "LogosSpinBox",        file: "LogosSpinBoxPage.qml" },
        { section: "Controls (not designed)", title: "LogosSpinner",        file: "LogosSpinnerPage.qml" },
        { section: "Controls (not designed)", title: "LogosStackView",      file: "LogosStackViewPage.qml" },
        { section: "Controls (not designed)", title: "LogosSwitch",         file: "LogosSwitchPage.qml" },
        { section: "Controls (not designed)", title: "LogosTextArea",       file: "LogosTextAreaPage.qml" },
        { section: "Controls (not designed)", title: "LogosToolBar",        file: "LogosToolBarPage.qml" },
        { section: "Controls (not designed)", title: "LogosToolSeparator",  file: "LogosToolSeparatorPage.qml" }
    ]

    ListModel {
        id: pageModel
        Component.onCompleted: {
            for (let i = 0; i < window.pages.length; i++)
                append(window.pages[i])
        }
    }

    header: Rectangle {
        height: 56
        color: Theme.palette.backgroundSecondary

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacing.large
            anchors.rightMargin: Theme.spacing.large
            spacing: Theme.spacing.medium

            LogosText {
                text: "Logos Design System"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }

            Item { Layout.fillWidth: true }

            LogosButton {
                text: "Open in Figma"
                implicitWidth: 140
                implicitHeight: 36
                visible: pageLoader.item && pageLoader.item.figmaUrl
                onClicked: Qt.openUrlExternally(pageLoader.item.figmaUrl)
            }

            LogosButton {
                text: "Reload"
                implicitWidth: 100
                implicitHeight: 36
                onClicked: Hot.reload()
            }

            LogosButton {
                text: Theme.isDark ? "Light" : "Dark"
                implicitWidth: 100
                implicitHeight: 36
                onClicked: Theme.switchTheme()
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ---- Sidebar ----
        Rectangle {
            Layout.preferredWidth: 240
            Layout.fillHeight: true
            color: Theme.palette.backgroundSecondary

            ListView {
                id: pageList

                anchors.fill: parent
                anchors.topMargin: Theme.spacing.medium
                model: pageModel
                clip: true
                currentIndex: -1

                section.property: "section"
                section.delegate: Item {
                    width: pageList.width
                    height: 36

                    LogosText {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacing.large
                        anchors.bottomMargin: Theme.spacing.tiny
                        verticalAlignment: Text.AlignBottom
                        text: section
                        font.pixelSize: Theme.typography.secondaryText
                        font.weight: Theme.typography.weightBold
                        color: Theme.palette.textTertiary
                    }
                }

                delegate: Rectangle {
                    width: pageList.width
                    height: 36
                    color: window.currentPage === model.file
                           ? Theme.palette.primary
                           : (mouseArea.containsMouse
                              ? Theme.palette.surfaceRaised
                              : "transparent")

                    LogosText {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacing.large
                        verticalAlignment: Text.AlignVCenter
                        text: model.title
                        font.pixelSize: Theme.typography.secondaryText
                        color: window.currentPage === model.file
                               ? Theme.palette.background
                               : Theme.palette.text
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            window.currentPage = model.file
                            settings.lastPage = model.file
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            color: Theme.palette.borderHairline
        }

        // ---- Page area ----
        Flickable {
            id: pageScroll

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds

            contentWidth: width
            contentHeight: pageLoader.item
                           ? Math.max(pageLoader.item.implicitHeight || 0, height)
                           : height

            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            Loader {
                id: pageLoader

                width: pageScroll.width
                height: pageScroll.contentHeight
                asynchronous: false
                source: window.currentPage
                        ? "file:" + Hot.pagesDir + "/" + window.currentPage
                        : ""

                onStatusChanged: {
                    if (status === Loader.Error)
                        console.warn("Failed to load page:", source)
                }
            }
        }
    }

    Connections {
        target: Hot
        function onReloadRequested() {
            const src = pageLoader.source
            pageLoader.source = ""
            pageLoader.source = src
        }
    }
}
