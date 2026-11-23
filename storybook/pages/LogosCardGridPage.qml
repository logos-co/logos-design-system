pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Layouts

// Catalog page for LogosCardGrid: stat cards and a catalogue of tiles at
// phone, tablet and desktop width.
Rectangle {
    id: page

    property string figmaUrl: ""
    property bool designed: false

    color: Theme.palette.background
    implicitHeight: column.implicitHeight + 2 * Theme.spacing.xxlarge

    readonly property var stats: [
        { label: "Peers", value: "12" },
        { label: "Height", value: "1,204,311" },
        { label: "Epoch", value: "812" },
        { label: "Rewards", value: "4.21 LGO" }
    ]
    readonly property var apps: ["Wallet", "Chat", "Storage", "Explorer", "Blockchain", "Keystore", "Uniswap", "Monero", "Docs", "Token list"]

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

    // frameWidth wide, or as wide as there is room for.
    component Frame: ColumnLayout {
        id: frame
        property int frameWidth: 390
        default property alias content: holder.data
        Layout.fillWidth: true
        Layout.maximumWidth: frame.frameWidth
        spacing: Theme.spacing.tiny
        LogosText {
            text: Math.round(box.width) + " px"
            font.pixelSize: Theme.typography.secondaryText
            color: Theme.palette.textSecondary
        }
        Rectangle {
            id: box
            Layout.fillWidth: true
            Layout.preferredHeight: holder.childrenRect.height + 2 * Theme.spacing.large
            color: Theme.palette.backgroundSecondary
            border.color: Theme.palette.borderSubtle
            Item {
                id: holder
                anchors.fill: parent
                anchors.margins: Theme.spacing.large
            }
        }
    }

    component Stats: LogosCardGrid {
        width: parent ? parent.width : 0
        Repeater {
            model: page.stats
            delegate: LogosStatCard {
                required property var modelData
                label: modelData.label
                value: modelData.value
            }
        }
    }

    component Catalogue: LogosCardGrid {
        id: catalogue
        width: parent ? parent.width : 0
        balanced: false
        minimumCellWidth: Theme.tileWidth(width)
        Repeater {
            model: page.apps
            delegate: ColumnLayout {
                required property string modelData
                spacing: Theme.spacing.tiny
                LogosTile { label: parent.modelData; Layout.alignment: Qt.AlignHCenter }
                LogosText {
                    Layout.fillWidth: true
                    text: parent.modelData
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    font.pixelSize: Theme.typography.secondaryText
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
                text: "LogosCardGrid"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
            }
            LogosText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: "Cards in as many equal columns as fit at minimumCellWidth, from the width the grid gets. Public API: minimumCellWidth, maximumColumns, balanced, maximumWidth (1200, centred), spacing (16, across and down), columns. Balanced, never one card alone on the last row when fewer columns avoid it: four stat cards are 4, 2 × 2 or 1. A catalogue sets balanced: false."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Section {
            title: "Stat cards"
            Frame { frameWidth: 390; Stats {} }
            Frame { frameWidth: 700; Stats {} }
            Frame { frameWidth: 1000; Stats {} }
        }

        Section {
            title: "A catalogue of tiles (104 / 140 / 180 px cells)"
            Frame { frameWidth: 390; Catalogue {} }
            Frame { frameWidth: 1000; Catalogue {} }
        }

        Item { Layout.fillHeight: true }
    }
}
