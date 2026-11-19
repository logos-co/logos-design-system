pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Layouts
import Logos.Icons

// Catalog page for LogosPageBar: the same bar at phone, tablet and desktop
// width, with knobs for back, search and the overflow menu.
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

    // frameWidth wide, or as wide as there is room for.
    component Framed: ColumnLayout {
        id: framed
        property int frameWidth: 390
        default property alias content: holder.data
        Layout.fillWidth: true
        Layout.maximumWidth: framed.frameWidth
        spacing: Theme.spacing.tiny
        LogosText {
            text: Math.round(box.width) + " px · " + Theme.windowClass(box.width)
            font.pixelSize: Theme.typography.secondaryText
            color: Theme.palette.textSecondary
        }
        Item {
            id: box
            Layout.fillWidth: true
            Layout.preferredHeight: holder.childrenRect.height
            clip: true
            Item { id: holder; anchors.fill: parent }
            // Over the bar, whose background is opaque.
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
                text: "LogosPageBar"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
            }
            LogosText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: "The first row of a page a shell already frames. Public API: title, leading, canGoBack, searchEnabled, searchPlaceholder, searchText, actions, menu, phone, backRequested(), searchSubmitted(). Below 600 px, measured on the bar, search folds into an icon, and opening it turns the bar into the search field."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Section {
            title: "Knobs"
            Flow {
                Layout.fillWidth: true
                spacing: Theme.spacing.large
                LogosCheckbox { id: backKnob; text: "canGoBack" }
                LogosCheckbox { id: searchKnob; text: "searchEnabled"; checked: true }
                LogosCheckbox { id: menuKnob; text: "menu"; checked: true }
            }
        }

        Section {
            title: "Phone, tablet and desktop"
            Repeater {
                model: [390, 700, 1000]
                delegate: Framed {
                    required property int modelData
                    frameWidth: modelData
                    LogosPageBar {
                        width: parent.width
                        title: "Packages"
                        canGoBack: backKnob.checked
                        searchEnabled: searchKnob.checked
                        menu: menuKnob.checked ? overflow : null
                        actions: [
                            LogosIconButton { flat: true; iconSource: LogosIcons.refresh; Accessible.name: "Reload" }
                        ]
                        LogosMenu {
                            id: overflow
                            LogosMenuItem { text: "Install a local package" }
                            LogosMenuItem { text: "Manage repositories" }
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
