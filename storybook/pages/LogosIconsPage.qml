import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Icons

Rectangle {
    property string figmaUrl: ""

    color: Theme.palette.background

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: Theme.spacing.xxlarge

            Item { Layout.preferredHeight: Theme.spacing.large }

            ColumnLayout {
                Layout.leftMargin: Theme.spacing.xxlarge
                Layout.rightMargin: Theme.spacing.xxlarge
                spacing: Theme.spacing.tiny

                LogosText {
                    text: "Icons"
                    font.pixelSize: Theme.typography.titleText
                    font.weight: Theme.typography.weightBold
                    color: Theme.palette.text
                }
                LogosText {
                    text: "Curated icon set shipped with Logos.Icons. Use as LogosIcons.<name>."
                    font.pixelSize: Theme.typography.secondaryText
                    color: Theme.palette.textSecondary
                }
            }

            Section {
                title: "Arrows"
                items: [
                    { name: "arrowLeft",        value: LogosIcons.arrowLeft },
                    { name: "arrowLeftDouble",  value: LogosIcons.arrowLeftDouble },
                    { name: "arrowRight",       value: LogosIcons.arrowRight },
                    { name: "arrowRightDouble", value: LogosIcons.arrowRightDouble },
                    { name: "triangleUp",       value: LogosIcons.triangleUp },
                    { name: "triangleDown",     value: LogosIcons.triangleDown }
                ]
            }

            Section {
                title: "Actions"
                items: [
                    { name: "refresh", value: LogosIcons.refresh },
                    { name: "install", value: LogosIcons.install },
                    { name: "trash",   value: LogosIcons.trash },
                    { name: "more",    value: LogosIcons.more },
                    { name: "search",  value: LogosIcons.search }
                ]
            }

            Section {
                title: "Status"
                items: [
                    { name: "warning", value: LogosIcons.warning }
                ]
            }

            Item { Layout.preferredHeight: Theme.spacing.xxlarge }
        }
    }

    component Section: ColumnLayout {
        property string title
        property var items: []

        Layout.fillWidth: true
        Layout.leftMargin: Theme.spacing.xxlarge
        Layout.rightMargin: Theme.spacing.xxlarge
        spacing: Theme.spacing.medium

        LogosText {
            text: title
            font.pixelSize: Theme.typography.primaryText
            font.weight: Theme.typography.weightBold
            color: Theme.palette.text
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.palette.borderHairline
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 5
            columnSpacing: Theme.spacing.medium
            rowSpacing: Theme.spacing.medium

            Repeater {
                model: items

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.small

                    LogosIconButton {
                        Layout.alignment: Qt.AlignHCenter
                        iconSource: modelData.value
                        background: Item{}
                    }

                    LogosText {
                        Layout.alignment: Qt.AlignHCenter
                        text: "LogosIcons." + modelData.name
                        font.pixelSize: Theme.typography.secondaryText
                        font.weight: Theme.typography.weightMedium
                        color: Theme.palette.text
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
