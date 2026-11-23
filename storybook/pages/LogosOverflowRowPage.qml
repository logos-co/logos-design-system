import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Icons
import Logos.Controls
import Logos.Layouts

// Catalog page for LogosOverflowRow: a toolbar's buttons, or ⋯ and a menu, by
// what fits.
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

    // A toolbar: a title on the left, its actions at the end, which fold into
    // ⋯ when they don't fit beside it.
    component Toolbar: RowLayout {
        id: toolbar
        property alias folded: actions.folded
        spacing: Theme.spacing.large
        LogosText {
            text: "Packages"
            font.pixelSize: Theme.typography.panelTitleText
            font.weight: Theme.typography.weightMedium
        }
        LogosOverflowRow {
            id: actions
            Layout.fillWidth: true
            LogosButton { text: "Install Local Package"; leadingIcon.source: LogosIcons.install }
            LogosButton { text: "Reload"; leadingIcon.source: LogosIcons.refresh }
            LogosButton { text: "Manage Repositories" }
            menu: LogosMenu {
                LogosMenuItem { text: "Install Local Package…" }
                LogosMenuItem { text: "Reload" }
                LogosMenuItem { text: "Manage Repositories…" }
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
                text: "LogosOverflowRow"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
            }
            LogosText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: "A row of items, such as a toolbar's buttons, while they fit the width it is given; otherwise a ⋯ at its end that opens the app's menu, with the same actions in its own words. Public API: content (default), menu, spacing, folded. It arranges only and measures what fits, never the width class; a hidden row goes on measuring its items, so it never flickers between the two. Drag the slider."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Section {
            title: "Try it: " + Math.round(tryIt.width) + " px, " + (tryIt.folded ? "folded into ⋯" : "a row")
            LogosSlider {
                id: widthSlider
                Layout.fillWidth: true
                Layout.maximumWidth: 400
                from: 200
                to: 900
                value: 760
            }
            Toolbar {
                id: tryIt
                Layout.fillWidth: true
                Layout.maximumWidth: widthSlider.value
            }
        }

        Section {
            title: "A phone, " + Math.round(phone.width) + " px"
            Toolbar { id: phone; Layout.fillWidth: true; Layout.maximumWidth: 360 }
        }

        Section {
            title: "A desktop, " + Math.round(desktop.width) + " px"
            Toolbar { id: desktop; Layout.fillWidth: true; Layout.maximumWidth: 900 }
        }

        Item { Layout.fillHeight: true }
    }
}
