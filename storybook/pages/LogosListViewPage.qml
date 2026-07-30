import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

Rectangle {
    property string figmaUrl: ""
    property bool designed: false

    color: Theme.palette.background

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosListView"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "ListView wrapper with a themed LogosScrollBar attached by default " +
                      "(4-px inset from the list's right border), and sensible clip / " +
                      "spacing / bounds-behavior defaults so consumers don't repeat them."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.spacing.xlarge

            // ─── Fits: no overflow, no scroll bar. ───
            Rectangle {
                Layout.preferredWidth: 220
                Layout.fillHeight: true
                color: Theme.palette.surfaceRaised
                radius: Theme.spacing.radiusLarge
                clip: true

                LogosListView {
                    id: fitsList
                    // Fills the outer rounded rectangle edge-to-edge — the
                    // scroll bar's 4-px inset is measured from the visible
                    // outer border. Content gap comes from the delegate's own
                    // leftPadding / rightPadding, not from wrapping padding.
                    anchors.fill: parent
                    model: 4

                    header: LogosText {
                        width: fitsList.width
                        topPadding: Theme.spacing.tiny
                        bottomPadding: Theme.spacing.tiny
                        text: "Fits"
                        font.pixelSize: Theme.typography.subtitleText
                        font.weight: Theme.typography.weightMedium
                        color: Theme.palette.text
                    }

                    delegate: LogosItemDelegate {
                        width: ListView.view.width
                        text: "Row " + index
                        radius: Theme.spacing.radiusLarge
                    }
                }
            }

            // ─── Overflows: scroll bar visible, 4 px from the right border. ───
            Rectangle {
                Layout.preferredWidth: 220
                Layout.fillHeight: true
                color: Theme.palette.surfaceRaised
                radius: Theme.spacing.radiusLarge
                clip: true

                LogosListView {
                    id: overflowList
                    // Fills the outer rounded rectangle edge-to-edge — the
                    // scroll bar's 4-px inset is measured from the visible
                    // outer border. Content gap comes from the delegate's own
                    // leftPadding / rightPadding, not from wrapping padding.
                    anchors.fill: parent
                    model: 30

                    header: LogosText {
                        width: overflowList.width
                        topPadding: Theme.spacing.tiny
                        bottomPadding: Theme.spacing.tiny
                        text: "Overflows"
                        font.pixelSize: Theme.typography.subtitleText
                        font.weight: Theme.typography.weightMedium
                        color: Theme.palette.text
                    }

                    delegate: LogosItemDelegate {
                        width: ListView.view.width
                        text: "Row " + index
                        radius: Theme.spacing.radiusLarge
                    }
                }
            }

            // ─── currentIndex + clickable highlight. ───
            Rectangle {
                Layout.preferredWidth: 220
                Layout.fillHeight: true
                color: Theme.palette.surfaceRaised
                radius: Theme.spacing.radiusLarge
                clip: true

                LogosListView {
                    id: selectableList
                    // Fills the outer rounded rectangle edge-to-edge — the
                    // scroll bar's 4-px inset is measured from the visible
                    // outer border. Content gap comes from the delegate's own
                    // leftPadding / rightPadding, not from wrapping padding.
                    anchors.fill: parent
                    model: 12
                    currentIndex: 0

                    header: LogosText {
                        width: selectableList.width
                        topPadding: Theme.spacing.tiny
                        bottomPadding: Theme.spacing.tiny
                        text: "Click a row"
                        font.pixelSize: Theme.typography.subtitleText
                        font.weight: Theme.typography.weightMedium
                        color: Theme.palette.text
                    }

                    delegate: LogosItemDelegate {
                        id: cell
                        width: ListView.view.width
                        text: "Item " + index
                        highlighted: ListView.isCurrentItem
                        radius: Theme.spacing.radiusLarge
                        highlightColor: Theme.palette.backgroundButton
                        hoverColor: "transparent"
                        textColor: (cell.highlighted || cell.hovered)
                                       ? Theme.palette.text
                                       : Theme.palette.textTertiary
                        onClicked: selectableList.currentIndex = index
                    }
                }
            }
        }
    }
}
