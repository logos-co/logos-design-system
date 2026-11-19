import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Layouts

// Catalog page for LogosSidePanel: a packages table and the details of the
// package you open, at phone, tablet and desktop width.
Rectangle {
    id: page

    property string figmaUrl: ""
    property bool designed: false

    color: Theme.palette.background
    implicitHeight: column.implicitHeight + 2 * Theme.spacing.xxlarge

    ListModel {
        id: packages
        ListElement { name: "chat-ui";     type: "ui_qml"; status: "Installed";     about: "Decentralised messaging." }
        ListElement { name: "wallet-ui";   type: "ui_qml"; status: "Upgrade";       about: "A multi-chain wallet." }
        ListElement { name: "storage";     type: "core";   status: "Installed";     about: "Local and remote storage." }
        ListElement { name: "telemetry";   type: "core";   status: "Not Installed"; about: "Anonymous metrics." }
    }

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

    // One packages page, `frameWidth` wide, or as wide as there is room for.
    // `openIndex` opens a package's details from the start.
    component Packages: ColumnLayout {
        id: frame
        property int frameWidth: 390
        property int openIndex: -1
        readonly property var openRow: openIndex >= 0 ? packages.get(openIndex) : null
        Layout.fillWidth: true
        Layout.maximumWidth: frame.frameWidth
        spacing: Theme.spacing.tiny

        LogosText {
            text: Math.round(box.width) + " px · " + Theme.windowClass(box.width)
            font.pixelSize: Theme.typography.secondaryText
            color: Theme.palette.textSecondary
        }
        Rectangle {
            id: box
            Layout.fillWidth: true
            Layout.preferredHeight: 360
            color: Theme.palette.background
            border.color: Theme.palette.borderSubtle
            clip: true

            LogosSidePanel {
                id: sidePanel
                anchors.fill: parent
                // Open from the start when openIndex says so; after that the
                // rows open it, and closing it clears the open package.
                panelOpen: frame.openIndex >= 0
                onPanelOpenChanged: if (!panelOpen) frame.openIndex = -1
                title: frame.openRow ? frame.openRow.name : ""
                panelActions: [
                    LogosButton { text: "Install"; variant: LogosButton.Variant.Primary }
                ]
                content: ColumnLayout {
                    spacing: 0
                    LogosPageBar { Layout.fillWidth: true; title: "Packages" }
                    LogosTable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: packages
                        onRowClicked: (index, row) => {
                            frame.openIndex = index
                            sidePanel.panelOpen = true
                        }
                        columns: [
                            LogosTableColumn { title: "Package"; role: "name";   minWidth: 120; fillWidth: true },
                            LogosTableColumn { title: "Type";    role: "type";   minWidth: 80 },
                            LogosTableColumn { title: "Status";  role: "status"; minWidth: 110 }
                        ]
                    }
                }
                panel: ColumnLayout {
                    spacing: Theme.spacing.small
                    LogosText {
                        Layout.fillWidth: true
                        Layout.leftMargin: Theme.spacing.large
                        Layout.rightMargin: Theme.spacing.large
                        wrapMode: Text.Wrap
                        text: frame.openRow ? frame.openRow.about : ""
                    }
                    LogosText {
                        Layout.leftMargin: Theme.spacing.large
                        text: frame.openRow ? frame.openRow.type + " · " + frame.openRow.status : ""
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textSecondary
                    }
                    Item { Layout.fillHeight: true }
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
            Layout.fillWidth: true
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosSidePanel"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
            }
            LogosText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: "A page's content and a panel beside it, opened on demand. Public API: content, panel, panelOpen, panelWidth (320), title, panelActions, beside, showingPanel. From 600 px up, measured on itself, the panel is beside the content, which narrows for it; below, the open panel is the page. A title gives the panel a page bar: ✕ beside the content, ‹ on a phone. Esc and Back close it. Tap a row in the phone frame."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
            LogosText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: "Which layout: if the open item is what the page is for (a message, a settings page), LogosListDetail; if the page is (a table, a thread) and the item's details are secondary, LogosSidePanel."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Section {
            title: "Phone, tablet and desktop"
            Packages { frameWidth: 390 }
            Packages { frameWidth: 700; openIndex: 1 }
            Packages { frameWidth: 1000; openIndex: 1 }
        }

        Item { Layout.fillHeight: true }
    }
}
