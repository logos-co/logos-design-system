import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

// Catalog page for LogosStateView: empty, loading and error, at phone and
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

    component Framed: Rectangle {
        id: framed
        property int kind: LogosStateView.Empty
        Layout.preferredHeight: 320
        color: Theme.palette.backgroundSecondary
        border.color: Theme.palette.borderSubtle

        LogosStateView {
            anchors.fill: parent
            kind: framed.kind
            title: framed.kind === LogosStateView.Loading ? "Loading packages…"
                 : framed.kind === LogosStateView.Error ? "Couldn't load packages"
                 : "No packages yet"
            message: framed.kind === LogosStateView.Loading ? ""
                   : framed.kind === LogosStateView.Error ? "Check your connection and try again."
                   : "Packages you install appear here."
            leftActions: framed.kind === LogosStateView.Error ? [ framed.details ] : []
            rightActions: framed.kind === LogosStateView.Loading ? [] : [ framed.action ]
        }

        // Unparented until a state view shows them.
        property LogosButton details: LogosButton { text: "Details" }
        property LogosButton action: LogosButton { text: framed.kind === LogosStateView.Error ? "Try again" : "Browse the catalogue" }
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
                text: "LogosStateView"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
            }
            LogosText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: "What a page shows in place of its content while it loads, when there is nothing to show, or when loading failed. Public API: kind (Empty, Loading, Error), title, message, iconSource, leftActions, rightActions. Centred and at most 400 px wide; on a phone it fills the page margins and its buttons stack, the main one last."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Section {
            title: "At 390 px"
            Flow {
                id: phoneFrames
                Layout.fillWidth: true
                Layout.maximumWidth: 2 * 390 + spacing
                spacing: Theme.spacing.large
                Framed { width: Math.min(390, phoneFrames.width); height: 320; kind: LogosStateView.Empty }
                Framed { width: Math.min(390, phoneFrames.width); height: 320; kind: LogosStateView.Loading }
            }
            Framed { Layout.fillWidth: true; Layout.maximumWidth: 390; kind: LogosStateView.Error }
        }

        Section {
            title: "At 1000 px"
            Framed { Layout.fillWidth: true; Layout.maximumWidth: 1000; kind: LogosStateView.Error }
        }

        Item { Layout.fillHeight: true }
    }
}
