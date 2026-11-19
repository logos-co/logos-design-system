import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

import "PhoneChecks.js" as PhoneChecks

ApplicationWindow {
    id: window

    visible: true
    width: 1280
    height: 800
    title: "Logos Design System Storybook"
    color: Theme.palette.background

    property string currentPage: settings.lastPage

    // The page again in a window of a phone's or a tablet's size; see previewWindow.
    readonly property var previews: [
        { name: "off", width: 0, height: 0 },
        { name: "phone", width: 390, height: 844 },
        { name: "tablet", width: 700, height: 1000 }
    ]
    property int previewIndex: 0

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
        { section: "Controls", title: "LogosIcon",       file: "LogosIconPage.qml" },
        { section: "Controls", title: "LogosArtwork",    file: "LogosArtworkPage.qml" },
        { section: "Controls", title: "LogosTile",    file: "LogosTilePage.qml" },
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

        { section: "Controls (not designed)", title: "LogosButtonRow",      file: "LogosButtonRowPage.qml" },
        { section: "Controls (not designed)", title: "LogosCopyButton",     file: "LogosCopyButtonPage.qml" },
        { section: "Controls (not designed)", title: "LogosCopyableText",   file: "LogosCopyableTextPage.qml" },
        { section: "Controls (not designed)", title: "LogosDialog",         file: "LogosDialogPage.qml" },
        { section: "Controls (not designed)", title: "LogosWarningDialog",  file: "LogosWarningDialogPage.qml" },
        { section: "Controls (not designed)", title: "LogosDrawer",         file: "LogosDrawerPage.qml" },
        { section: "Controls (not designed)", title: "LogosFrame",          file: "LogosFramePage.qml" },
        { section: "Controls (not designed)", title: "LogosGroupBox",       file: "LogosGroupBoxPage.qml" },
        { section: "Controls (not designed)", title: "LogosItemDelegate",   file: "LogosItemDelegatePage.qml" },
        { section: "Controls (not designed)", title: "LogosLink",           file: "LogosLinkPage.qml" },
        { section: "Controls (not designed)", title: "LogosListRow",        file: "LogosListRowPage.qml" },
        { section: "Controls (not designed)", title: "LogosListView",       file: "LogosListViewPage.qml" },
        { section: "Controls (not designed)", title: "LogosMenu",           file: "LogosMenuPage.qml" },
        { section: "Controls (not designed)", title: "LogosMenuSeparator",  file: "LogosMenuSeparatorPage.qml" },
        { section: "Controls (not designed)", title: "LogosNotice",         file: "LogosNoticePage.qml" },
        { section: "Controls (not designed)", title: "LogosStatCard",       file: "LogosStatCardPage.qml" },
        { section: "Controls (not designed)", title: "LogosStateView",      file: "LogosStateViewPage.qml" },
        { section: "Controls (not designed)", title: "LogosInfoButton",     file: "LogosInfoButtonPage.qml" },
        { section: "Controls (not designed)", title: "LogosStageLane",      file: "LogosStageLanePage.qml" },
        { section: "Controls (not designed)", title: "LogosProgressBar",    file: "LogosProgressBarPage.qml" },
        { section: "Controls (not designed)", title: "LogosRadioButton",    file: "LogosRadioButtonPage.qml" },
        { section: "Controls (not designed)", title: "LogosScrollBar",      file: "LogosScrollBarPage.qml" },
        { section: "Controls (not designed)", title: "LogosScrollView",     file: "LogosScrollViewPage.qml" },
        { section: "Controls (not designed)", title: "LogosSearchToggle",   file: "LogosSearchTogglePage.qml" },
        { section: "Controls (not designed)", title: "LogosSelectableText", file: "LogosSelectableTextPage.qml" },
        { section: "Controls (not designed)", title: "LogosSlider",         file: "LogosSliderPage.qml" },
        { section: "Controls (not designed)", title: "LogosSpinBox",        file: "LogosSpinBoxPage.qml" },
        { section: "Controls (not designed)", title: "LogosSpinner",        file: "LogosSpinnerPage.qml" },
        { section: "Controls (not designed)", title: "LogosDotMatrix",      file: "LogosDotMatrixPage.qml" },
        { section: "Controls (not designed)", title: "LogosStackView",      file: "LogosStackViewPage.qml" },
        { section: "Controls (not designed)", title: "LogosSwitch",         file: "LogosSwitchPage.qml" },
        { section: "Controls (not designed)", title: "LogosTextArea",       file: "LogosTextAreaPage.qml" },
        { section: "Controls (not designed)", title: "LogosToast",          file: "LogosToastPage.qml" },
        { section: "Controls (not designed)", title: "LogosToolBar",        file: "LogosToolBarPage.qml" },
        { section: "Controls (not designed)", title: "LogosToolSeparator",  file: "LogosToolSeparatorPage.qml" },

        { section: "Layouts (not designed)", title: "LogosCardGrid",        file: "LogosCardGridPage.qml" },
        { section: "Layouts (not designed)", title: "LogosCardPair",        file: "LogosCardPairPage.qml" },
        { section: "Layouts (not designed)", title: "LogosFormLayout",      file: "LogosFormLayoutPage.qml" },
        { section: "Layouts (not designed)", title: "LogosListDetail",      file: "LogosListDetailPage.qml" },
        { section: "Layouts (not designed)", title: "LogosPageBar",         file: "LogosPageBarPage.qml" },
        { section: "Layouts (not designed)", title: "LogosSections",        file: "LogosSectionsPage.qml" },
        { section: "Layouts (not designed)", title: "LogosSidePanel",       file: "LogosSidePanelPage.qml" },
        { section: "Layouts (not designed)", title: "LogosWelcome",         file: "LogosWelcomePage.qml" },
        { section: "Layouts (not designed)", title: "LogosWizard",          file: "LogosWizardPage.qml" }
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
                compact: true
                visible: pageLoader.item && pageLoader.item.figmaUrl
                onClicked: Qt.openUrlExternally(pageLoader.item.figmaUrl)
            }

            LogosButton {
                text: "Reload"
                implicitWidth: 100
                compact: true
                onClicked: Hot.reload()
            }

            LogosButton {
                text: "Next theme"
                implicitWidth: 120
                compact: true
                visible: Theme.themeNames.length > 1
                onClicked: {
                    const names = Theme.themeNames
                    themeManager.select(names[(names.indexOf(Theme.currentTheme) + 1) % names.length])
                }
            }

            LogosButton {
                text: "Density: " + Theme.density
                implicitWidth: 170
                compact: true
                onClicked: {
                    const order = ["compact", "comfortable", "touch"]
                    themeManager.setDensity(order[(order.indexOf(Theme.density) + 1) % order.length])
                }
            }

            LogosButton {
                text: "Preview: " + window.previews[window.previewIndex].name
                implicitWidth: 150
                compact: true
                onClicked: window.previewIndex = (window.previewIndex + 1) % window.previews.length
            }
        }
    }

    // The page in a window the size of a phone or a tablet. The window has its
    // own overlay, so menus and dialogs place themselves as on the device, and
    // while it is open Theme.viewWidth is its width: a phone's gets touch sizes,
    // in both windows. Every second it marks what wouldn't work on the device:
    // in red, parts that reach past the sides; where targets are touch-sized,
    // in orange, tappable parts smaller than a fingertip.
    Window {
        id: previewWindow

        readonly property var preview: window.previews[window.previewIndex]
        property var problems: ({ overflow: [], small: [] })

        function check() {
            const page = previewLoader.item
            if (!page) {
                problems = { overflow: [], small: [] }
                return
            }
            const found = PhoneChecks.find(page, Theme.size.touchTarget)
            problems = { overflow: found.overflow, small: Theme.touch ? found.small : [] }
        }

        visible: preview.width > 0
        width: preview.width
        height: preview.height
        title: "Preview: " + preview.name + " · " + window.currentPage
        color: Theme.palette.background

        onClosing: window.previewIndex = 0

        Flickable {
            id: previewScroll
            anchors.fill: parent
            anchors.bottomMargin: Theme.size.touchTarget
            clip: true
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds
            contentWidth: width
            contentHeight: previewLoader.item
                           ? Math.max(previewLoader.item.implicitHeight || 0, height)
                           : height

            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            Loader {
                id: previewLoader
                width: previewScroll.width
                height: previewScroll.contentHeight
                source: previewWindow.visible ? pageLoader.source : ""
            }

            // Over the page, in its coordinates, so the marks scroll with it.
            Repeater {
                model: previewWindow.problems.overflow.map(item => ({ item: item, color: Theme.palette.error }))
                    .concat(previewWindow.problems.small.map(item => ({ item: item, color: Theme.palette.warning })))
                delegate: Rectangle {
                    id: mark
                    required property var modelData
                    readonly property point at: modelData.item.mapToItem(previewLoader, 0, 0)
                    x: at.x
                    y: at.y
                    width: modelData.item.width
                    height: modelData.item.height
                    color: "transparent"
                    border.width: Theme.size.focusWidth
                    border.color: modelData.color

                    HoverHandler { id: markHover }
                    LogosToolTip {
                        visible: markHover.hovered
                        text: PhoneChecks.describe(mark.modelData.item, previewLoader)
                    }
                }
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: Theme.size.touchTarget
            color: Theme.palette.backgroundSecondary

            LogosText {
                anchors.centerIn: parent
                readonly property int past: previewWindow.problems.overflow.length
                readonly property int small: previewWindow.problems.small.length
                text: past + small === 0 ? "Nothing reaches past the sides" + (Theme.touch ? " or is too small to tap" : "")
                    : [past > 0 ? past + " past the sides (red)" : "", small > 0 ? small + " too small to tap (orange)" : ""]
                      .filter(part => part !== "").join(" · ")
                font.pixelSize: Theme.typography.secondaryText
                color: past + small === 0 ? Theme.palette.textSecondary : Theme.palette.text
            }
        }

        Timer {
            interval: 1000
            repeat: true
            running: previewWindow.visible
            triggeredOnStart: true
            onTriggered: previewWindow.check()
        }
    }

    Binding {
        target: Theme
        property: "viewWidth"
        value: previewWindow.visible ? previewWindow.width : 0
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
            if (previewWindow.visible) {
                previewLoader.source = ""
                previewLoader.source = Qt.binding(() => previewWindow.visible ? pageLoader.source : "")
            }
        }
    }
}
