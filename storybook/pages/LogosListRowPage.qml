import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Icons

// Catalog page for LogosListRow: the row's variants, and grouped settings rows.
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
                text: "LogosListRow"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
            }
            LogosText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: "A row in a list or grouped settings; the whole row is the tap target. Public API: title, subtitle, subtitleWraps, value, iconSource, showChevron, showSeparator, destructive, selected, accessory, clicked(). A tap on the row toggles its accessory."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Section {
            title: "Variants"
            ColumnLayout {
                Layout.fillWidth: false
                Layout.preferredWidth: 420
                spacing: 0
                LogosListRow { Layout.fillWidth: true; title: "Network"; value: "Testnet"; showChevron: true }
                LogosListRow { Layout.fillWidth: true; title: "Download folder"; subtitle: "/home/me/Downloads"; showChevron: true; iconSource: LogosIcons.install }
                LogosListRow { Layout.fillWidth: true; title: "Notifications"; subtitle: "A tap on the row toggles the switch"; accessory: LogosSwitch { checked: true } }
                LogosListRow { Layout.fillWidth: true; title: "Selected row (open in the detail)"; selected: true; showChevron: true }
                LogosListRow {
                    Layout.fillWidth: true
                    title: "Ana Lee"
                    subtitle: "Weekly sync"
                    caption: "Bring screenshots from the responsive lab."
                    value: "09:14"
                    menu: LogosMenu {
                        LogosMenuItem { text: "Reply" }
                        LogosMenuItem { text: "Archive" }
                    }
                }
                LogosListRow { Layout.fillWidth: true; title: "Forget this wallet"; destructive: true; iconSource: LogosIcons.trash; showSeparator: false }
            }
        }

        Section {
            title: "Wrapping subtitle"
            LogosListRow {
                Layout.preferredWidth: 420
                title: "Storage node"
                subtitle: "Downloads come from the storage network. Turn this off to download from GitHub releases instead."
                subtitleWraps: true
                accessory: LogosSwitch {}
            }
        }

        Item { Layout.fillHeight: true }
    }
}
