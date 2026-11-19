import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

// Catalog page for LogosSearchToggle: folded, unfolded, and as a plain field.
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

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xxlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosSearchToggle"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
            }
            LogosText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: "Search that folds into an icon at phone width; opened, the bar becomes the search, a field with no box of its own. Public API: text, placeholderText, folds, expanded, open(), close(), submitted(). It stays open while it holds text; ✕ clears and folds; Escape folds."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Section {
            title: "In a 390 px bar"
            Rectangle {
                Layout.fillWidth: true
                Layout.maximumWidth: 390
                Layout.preferredHeight: Theme.size.touchTarget
                color: Theme.palette.backgroundSecondary
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacing.large
                    LogosText {
                        visible: !barSearch.expanded
                        Layout.fillWidth: true
                        text: "Applications"
                        font.weight: Theme.typography.weightBold
                    }
                    LogosSearchToggle {
                        id: barSearch
                        placeholderText: "Search apps"
                    }
                }
            }
            LogosText {
                text: "Query: \"" + barSearch.text + "\""
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Section {
            title: "Without folding (folds: false)"
            LogosSearchToggle {
                folds: false
                placeholderText: "Search packages"
            }
        }

        Item { Layout.fillHeight: true }
    }
}
