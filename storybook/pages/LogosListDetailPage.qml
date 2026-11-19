pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Layouts

// Catalog page for LogosListDetail: an inbox at phone, tablet and desktop
// width, with a LogosPageBar that shows ‹ while the phone shows the detail.
Rectangle {
    id: page

    property string figmaUrl: ""
    property bool designed: false

    color: Theme.palette.background
    implicitHeight: column.implicitHeight + 2 * Theme.spacing.xxlarge

    readonly property var messages: [
        { from: "Alice", subject: "Node update", body: "The node restarted on the new release." },
        { from: "Bob", subject: "Rewards", body: "Rewards for epoch 812 are ready to claim." },
        { from: "Carol", subject: "Storage", body: "Your upload finished: 3 files, 12 MB." }
    ]

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

    // One inbox: page bar + list → detail, sized to `frameWidth`.
    component Inbox: ColumnLayout {
        id: inbox
        property int frameWidth: 390
        property int current: 0
        spacing: Theme.spacing.tiny

        LogosText {
            text: inbox.frameWidth + " px · " + Theme.windowClass(inbox.frameWidth)
            font.pixelSize: Theme.typography.secondaryText
            color: Theme.palette.textSecondary
        }
        Rectangle {
            Layout.preferredWidth: inbox.frameWidth
            Layout.preferredHeight: 320
            color: Theme.palette.background
            border.color: Theme.palette.borderSubtle
            clip: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                LogosPageBar {
                    Layout.fillWidth: true
                    title: listDetail.showingDetail ? page.messages[inbox.current].from : "Inbox"
                    canGoBack: listDetail.showingDetail
                    onBackRequested: listDetail.detailOpen = false
                }

                LogosListDetail {
                    id: listDetail
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    detailActions: [
                        LogosButton { text: "Reply"; variant: LogosButton.Variant.Primary },
                        LogosButton { text: "Archive" }
                    ]
                    list: ListView {
                        model: page.messages
                        delegate: LogosListRow {
                            required property var modelData
                            required property int index
                            width: ListView.view.width
                            title: modelData.from
                            subtitle: modelData.subject
                            selected: listDetail.twoPane && index === inbox.current
                            showChevron: !listDetail.twoPane
                            onClicked: {
                                inbox.current = index
                                listDetail.detailOpen = true
                            }
                        }
                    }
                    detail: ColumnLayout {
                        spacing: Theme.spacing.small
                        Item { Layout.preferredHeight: Theme.spacing.large }
                        LogosText {
                            Layout.leftMargin: Theme.spacing.large
                            text: page.messages[inbox.current].subject
                            font.pixelSize: Theme.typography.subtitleText
                            font.weight: Theme.typography.weightBold
                        }
                        LogosText {
                            Layout.leftMargin: Theme.spacing.large
                            Layout.rightMargin: Theme.spacing.large
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                            text: page.messages[inbox.current].body
                        }
                        Item { Layout.fillHeight: true }
                    }
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
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosListDetail"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
            }
            LogosText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: "A list and the detail of its open item. Public API: list, detail, detailOpen, twoPane, showingDetail. From 600 px up, measured on itself, both show (list 320 / 360); below, the detail replaces the list and the page bar shows ‹. Tap a row in the phone frame."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Section {
            title: "Phone, tablet and desktop"
            Inbox { frameWidth: 390 }
            Inbox { frameWidth: 700 }
            Inbox { frameWidth: 1000 }
        }

        Item { Layout.fillHeight: true }
    }
}
