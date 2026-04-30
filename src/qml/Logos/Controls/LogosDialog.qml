import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

Dialog {
    id: root

    property color borderColor: Theme.palette.border
    property color backgroundColor: Theme.palette.backgroundSecondary

    property list<Item> leftActions
    property list<Item> rightActions

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias backgroundItem: bg
    readonly property alias headerItem: titleLabel
    readonly property alias footerItem: footerWrap

    modal: true
    padding: Theme.spacing.large

    background: Rectangle {
        id: bg
        color: root.backgroundColor
        border.color: root.borderColor
        radius: Theme.spacing.radiusLarge
    }

    header: LogosText {
        id: titleLabel
        text: root.title
        color: Theme.palette.text
        font.pixelSize: Theme.typography.primaryText
        font.weight: Theme.typography.weightBold
        leftPadding: Theme.spacing.large
        topPadding: Theme.spacing.large
        rightPadding: Theme.spacing.large
        bottomPadding: Theme.spacing.small
        visible: root.title.length > 0
    }

    footer: Rectangle {
        id: footerWrap
        color: "transparent"
        visible: root.leftActions.length > 0 || root.rightActions.length > 0
        implicitHeight: visible
                        ? footerLayout.implicitHeight + Theme.spacing.medium + Theme.spacing.large
                        : 0

        RowLayout {
            id: footerLayout
            anchors.fill: parent
            anchors.leftMargin: Theme.spacing.large
            anchors.rightMargin: Theme.spacing.large
            anchors.topMargin: Theme.spacing.medium
            anchors.bottomMargin: Theme.spacing.large
            spacing: Theme.spacing.small

            Row {
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                spacing: Theme.spacing.small
                children: root.leftActions
            }

            Item { Layout.fillWidth: true }

            Row {
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                spacing: Theme.spacing.small
                children: root.rightActions
            }
        }
    }
}
