import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Layouts

// Catalog page for LogosSections: Basecamp's Settings at phone, tablet and
// desktop width.
Rectangle {
    id: page

    property string figmaUrl: ""
    property bool designed: false

    color: Theme.palette.background
    implicitHeight: column.implicitHeight + 2 * Theme.spacing.xxlarge

    component Section: ColumnLayout {
        property alias title: sectionTitle.text
        Layout.fillWidth: true
        spacing: Theme.spacing.medium
        LogosText {
            id: sectionTitle
            font.pixelSize: Theme.typography.primaryText
            font.weight: Theme.typography.weightBold
        }
        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.palette.borderHairline }
    }

    // One section's page: its title, and its rows; with `opens`, a row opens
    // something (rowOpened).
    component SectionPage: ColumnLayout {
        id: sectionPage
        property string title: ""
        property var rows: []
        property bool opens: false
        signal rowOpened(string title)
        spacing: Theme.spacing.medium

        LogosText {
            Layout.margins: Theme.spacing.large
            Layout.bottomMargin: 0
            text: sectionPage.title
            font.pixelSize: Theme.typography.panelTitleText
            font.weight: Theme.typography.weightMedium
        }
        Repeater {
            model: sectionPage.rows
            delegate: LogosListRow {
                required property var modelData
                Layout.fillWidth: true
                title: modelData.title
                subtitle: modelData.subtitle ?? ""
                value: modelData.value ?? ""
                showChevron: sectionPage.opens
                onClicked: if (sectionPage.opens) sectionPage.rowOpened(modelData.title)
            }
        }
        Item { Layout.fillHeight: true }
    }

    // frameWidth wide, or as wide as there is room for.
    component Settings: ColumnLayout {
        id: framed
        property int frameWidth: 390
        Layout.fillWidth: true
        Layout.maximumWidth: framed.frameWidth
        spacing: Theme.spacing.tiny

        LogosText {
            text: Math.round(box.width) + " px · " + Theme.windowClass(box.width)
            font.pixelSize: Theme.typography.secondaryText
            color: Theme.palette.textSecondary
        }
        Rectangle {
            id: box
            Layout.fillWidth: true
            Layout.preferredHeight: 480
            color: Theme.palette.background
            border.color: Theme.palette.borderSubtle
            clip: true

            LogosSections {
                id: settings
                anchors.fill: parent
                title: "Settings"
                subtitle: "Manage modules, apps and dashboards."
                listTitle: "Sections"
                sections: [{ title: "Dashboard" }, { title: "Apps Inspector" }, { title: "Appearance" },
                           { title: "Package Repositories" }, { title: "Trusted Publishers" }]
                // The inspector has a search, over its list; the other sections none.
                searchEnabled: currentIndex === 1 && openApp === ""
                searchPlaceholder: "Search apps…"

                // An app's detail is a level of the inspector's own: the back
                // row names the inspector and closes it.
                property string openApp: ""
                canGoBack: openApp !== ""
                backTitle: "Apps Inspector"
                onBackRequested: openApp = ""
                onCurrentIndexChanged: {
                    openApp = ""
                    closeSearch()
                }

                StackLayout {
                    anchors.fill: parent
                    currentIndex: settings.currentIndex
                    SectionPage {
                        title: "Dashboard"
                        rows: [{ title: "Version", value: "0.4.0" }, { title: "Build", value: "Portable" }]
                    }
                    StackLayout {
                        currentIndex: settings.openApp === "" ? 0 : 1
                        SectionPage {
                            title: "Apps Inspector"
                            opens: true
                            rows: [{ title: "Package Manager", value: "Loaded" },
                                   { title: "Wallet", value: "Not loaded" }]
                            onRowOpened: title => settings.openApp = title
                        }
                        SectionPage {
                            title: settings.openApp
                            rows: [{ title: "Version", value: "1.0.0" }, { title: "Status", value: "Loaded" }]
                        }
                    }
                    SectionPage { title: "Appearance"; rows: [{ title: "Theme", value: "Dark" }] }
                    SectionPage { title: "Package Repositories" }
                    SectionPage { title: "Trusted Publishers" }
                }
            }
        }
    }

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xxlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosSections"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
            }
            LogosText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: "A page with several sections, such as an app's settings. Public API: title, subtitle, listTitle, sections, currentIndex, canGoBack, backTitle, backRequested(), searchEnabled, searchPlaceholder, searchShortcutHint, searchWidth, searchText, openSearch(), closeSearch(), searchSubmitted(), twoPane, showingSection, showList(); the sections' pages are its content. From 600 px up, measured on itself, a label and pill rows (200 wide, 168 on a tablet) beside the section's card, with a section's search on the title's right. On a phone the list is the page; a tap opens the section under a ‹ Settings row, the search a 🔍 at its end that opens across it. A section a level deeper names it in the same row, and back goes up one level; beside the list the row is at the top of the card. No ☰ drawer, one way back. Tap a row in the phone frame; open Apps Inspector for the search, and an app for its detail."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Section {
            title: "Phone, tablet and desktop"
            Settings { frameWidth: 390 }
            Settings { frameWidth: 700 }
            Settings { frameWidth: 1000 }
        }

        Item { Layout.fillHeight: true }
    }
}
