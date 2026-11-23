import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Layouts

// Catalog page for LogosSidebarLayout: a catalog's categories beside it while
// it keeps its width, otherwise pickers over it.
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

    // A catalog: its categories in the sidebar, or as a picker over the
    // list once the sidebar is hidden (sideShown).
    component Catalog: LogosSidebarLayout {
        id: catalog
        property int category: 0
        readonly property var categories: ["All", "Networking", "Storage", "Wallets"]
        implicitHeight: 220
        minimumContentWidth: 360

        side: LogosListView {
            model: catalog.categories
            currentIndex: catalog.category
            delegate: LogosItemDelegate {
                required property string modelData
                required property int index
                width: ListView.view.width
                text: modelData
                highlighted: index === catalog.category
                radius: Theme.spacing.radiusLarge
                onClicked: catalog.category = index
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: Theme.spacing.radiusXlarge
            color: Theme.palette.surfaceRaised

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacing.medium
                spacing: Theme.spacing.medium
                LogosComboBox {
                    visible: !catalog.sideShown
                    Layout.fillWidth: true
                    Layout.maximumWidth: 240
                    model: catalog.categories
                    currentIndex: catalog.category
                    onActivated: index => catalog.category = index
                }
                LogosText {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    text: "Packages in " + catalog.categories[catalog.category]
                          + (catalog.sideShown ? ", picked in the sidebar" : ", picked above")
                    color: Theme.palette.textSecondary
                }
                Item { Layout.fillHeight: true }
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
                text: "LogosSidebarLayout"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
            }
            LogosText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: "A page's content with a sidebar on its left, such as a catalog's categories, while the content keeps minimumContentWidth beside it; otherwise the content alone. Public API: side, content (default), sideWidth, minimumContentWidth, spacing, sideShown. It arranges only and measures itself, never the width class. While the sidebar is hidden the app offers what it holds another way, here a picker, read from sideShown: filters are not navigation to hide behind ☰. Drag the slider."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Section {
            title: "Try it: " + Math.round(tryIt.width) + " px, " + (tryIt.sideShown ? "the sidebar beside it" : "a picker over it")
            LogosSlider {
                id: widthSlider
                Layout.fillWidth: true
                Layout.maximumWidth: 400
                from: 300
                to: 900
                value: 700
            }
            Catalog {
                id: tryIt
                Layout.fillWidth: true
                Layout.maximumWidth: widthSlider.value
            }
        }

        Section {
            title: "A phone, " + Math.round(phone.width) + " px"
            Catalog { id: phone; Layout.fillWidth: true; Layout.maximumWidth: 360 }
        }

        Section {
            title: "A desktop, " + Math.round(desktop.width) + " px"
            Catalog { id: desktop; Layout.fillWidth: true; Layout.maximumWidth: 900 }
        }

        Item { Layout.fillHeight: true }
    }
}
