import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Layouts

// Catalog page for LogosCardPair: a wide card and its side card, stacked and
// side by side.
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

    component Card: LogosFrame {
        id: card
        property string heading: ""
        property string body: ""
        property list<Item> actions
        ColumnLayout {
            width: parent.width
            spacing: Theme.spacing.small
            LogosText { text: card.heading; font.weight: Theme.typography.weightBold }
            LogosText {
                Layout.fillWidth: true
                text: card.body
                wrapMode: Text.Wrap
                color: Theme.palette.textSecondary
            }
            LogosButtonRow {
                visible: card.actions.length > 0
                Layout.fillWidth: true
                stackOnPhone: false
                rightActions: card.actions
            }
        }
    }

    component Pair: LogosCardPair {
        main: Card {
            heading: "Blocks per hour"
            body: "A chart of the last day would go here. The main card takes two parts of the width, the side card one."
        }
        side: Card {
            heading: "Your node"
            body: "Online, 12 peers."
            actions: [ LogosButton { text: "Restart" }, LogosButton { text: "Settings" } ]
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
                text: "LogosCardPair"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
            }
            LogosText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: "A wide card and a card that goes with it. Public API: main, side, sideBySide. Side by side, two parts to one and as tall as each other, while the main card keeps 400 px and the side card 220 px; otherwise stacked, the main card first. The side card's buttons stay a row while they fit (LogosButtonRow, stackOnPhone: false)."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Section {
            title: "At " + Math.round(narrowPair.width) + " px: " + (narrowPair.sideBySide ? "side by side" : "stacked")
            Pair { id: narrowPair; Layout.fillWidth: true; Layout.maximumWidth: 600 }
        }

        Section {
            title: "At " + Math.round(widePair.width) + " px: " + (widePair.sideBySide ? "side by side" : "stacked")
            Pair { id: widePair; Layout.fillWidth: true; Layout.maximumWidth: 1000 }
        }

        Item { Layout.fillHeight: true }
    }
}
