import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

Rectangle {
    property string figmaUrl: ""
    property bool designed: false

    color: Theme.palette.background

    implicitHeight: contentColumn.implicitHeight + 2 * Theme.spacing.xxlarge

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosTextArea"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: TextArea (text, placeholderText, wrapMode, etc.). Alias: backgroundItem."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        LogosText {
            text: "Auto-grow (no height constraint — area grows with content)"
            color: Theme.palette.textSecondary
        }
        LogosTextArea {
            Layout.fillWidth: true
            placeholderText: "Press Enter to add lines — the area expands as you type."
        }

        LogosText {
            text: "Fixed height (clips on overflow — best when content stays short)"
            color: Theme.palette.textSecondary
            Layout.topMargin: Theme.spacing.medium
        }
        LogosTextArea {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            placeholderText: "Type a short message..."
        }

        LogosText {
            text: "Scrollable (fixed height + ScrollView wrap — best for long content in fixed regions)"
            color: Theme.palette.textSecondary
            Layout.topMargin: Theme.spacing.medium
        }
        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            clip: true

            LogosTextArea {
                placeholderText: "Press Enter many times — the ScrollView handles vertical scroll."
            }
        }

        LogosText {
            text: "Disabled"
            color: Theme.palette.textSecondary
            Layout.topMargin: Theme.spacing.medium
        }
        LogosTextArea {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            text: "Read-only / disabled"
            enabled: false
        }

        Item { Layout.fillHeight: true }
    }
}
