import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Layouts

// Catalog page for LogosSections: a wallet at phone, tablet and desktop width.
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

    // One section's page: its own bar, with ‹ back to the list on a phone.
    component SectionPage: ColumnLayout {
        id: sectionPage
        property LogosSections sections: null
        property string title: ""
        property var rows: []
        spacing: 0

        LogosPageBar {
            Layout.fillWidth: true
            title: sectionPage.title
            canGoBack: sectionPage.sections !== null && sectionPage.sections.showingSection
            onBackRequested: sectionPage.sections.showList()
        }
        Repeater {
            model: sectionPage.rows
            delegate: LogosListRow {
                required property var modelData
                Layout.fillWidth: true
                title: modelData.title
                subtitle: modelData.subtitle ?? ""
                value: modelData.value ?? ""
            }
        }
        Item { Layout.fillHeight: true }
    }

    component Wallet: ColumnLayout {
        id: framed
        property int frameWidth: 390
        spacing: Theme.spacing.tiny

        LogosText {
            text: framed.frameWidth + " px · " + Theme.windowClass(framed.frameWidth)
            font.pixelSize: Theme.typography.secondaryText
            color: Theme.palette.textSecondary
        }
        Item {
            Layout.preferredWidth: framed.frameWidth
            Layout.preferredHeight: 360
            clip: true

            LogosSections {
                id: wallet
                anchors.fill: parent
                title: "Wallet"
                sections: [{ title: "Assets" }, { title: "Activity" }, { title: "Send" },
                           { title: "Receive" }, { title: "Settings" }]
                menu: LogosMenu { LogosMenuItem { text: "Lock wallet" } }

                StackLayout {
                    anchors.fill: parent
                    currentIndex: wallet.currentIndex
                    SectionPage {
                        sections: wallet
                        title: "Assets"
                        rows: [{ title: "ETH", value: "1.204" }, { title: "USDC", value: "310.00" },
                               { title: "LGO", value: "1,000" }]
                    }
                    SectionPage {
                        sections: wallet
                        title: "Activity"
                        rows: [{ title: "Sent 0.1 ETH", subtitle: "Today, 09:42" },
                               { title: "Received 50 USDC", subtitle: "Yesterday" }]
                    }
                    SectionPage { sections: wallet; title: "Send" }
                    SectionPage { sections: wallet; title: "Receive" }
                    SectionPage { sections: wallet; title: "Settings" }
                }
            }
            // Over the sections, whose panes are opaque.
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: Theme.palette.borderSubtle
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
                text: "An app with several sections. Public API: title, sections, currentIndex, menu, twoPane, showingSection, showList(); the sections' pages are its content. From 600 px up, measured on itself, the sections are a list beside the current one; on a phone the app opens on its current section and ‹ goes back to the list. No ☰ drawer. Tap ‹ in the phone frame."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Section {
            title: "Phone, tablet and desktop"
            Wallet { frameWidth: 390 }
            Wallet { frameWidth: 700 }
            Wallet { frameWidth: 1000 }
        }

        Item { Layout.fillHeight: true }
    }
}
