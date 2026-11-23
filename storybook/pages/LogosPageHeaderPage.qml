import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Layouts

// Catalog page for LogosPageHeader: a page's title and subtitle with its
// search, a 🔍 on a phone.
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
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            font.pixelSize: Theme.typography.primaryText
            font.weight: Theme.typography.weightBold
        }
        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.palette.borderHairline }
    }

    component Header: LogosPageHeader {
        title: "Package Manager"
        subtitle: "Manage your plugins and packages."
        searchEnabled: true
        searchPlaceholder: "Search packages…"
        searchShortcutHint: "Ctrl+K"
    }

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xxlarge

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosPageHeader"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
            }
            LogosText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: "The head of a page a shell already frames: its title and subtitle, and a search on their right, searchWidth wide or what the title leaves. Public API: title, subtitle, searchEnabled, searchPlaceholder, searchShortcutHint, searchWidth, searchText, openSearch(), closeSearch(), searchSubmitted(). On a phone, measured on itself, the search is a 🔍 at the end of the title's line, never a row of its own; a tap opens it across that line in place of the title, ✕ clears and folds it. Its search is LogosSections'. Tap the 🔍 in the phone frame."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Section {
            title: "A phone, " + Math.round(phone.width) + " px" + (phone.searchText !== "" ? ": " + phone.searchText : "")
            Header { id: phone; Layout.fillWidth: true; Layout.maximumWidth: 360 }
        }

        Section {
            title: "A tablet, " + Math.round(tablet.width) + " px"
            Header { id: tablet; Layout.fillWidth: true; Layout.maximumWidth: 700 }
        }

        Section {
            title: "A desktop, " + Math.round(desktop.width) + " px"
            Header { id: desktop; Layout.fillWidth: true; Layout.maximumWidth: 1100; searchWidth: 605 }
        }

        Item { Layout.fillHeight: true }
    }
}
