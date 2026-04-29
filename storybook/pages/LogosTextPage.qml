import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

Rectangle {
    property string figmaUrl: ""

    color: Theme.palette.background

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xxlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny

            LogosText {
                text: "LogosText"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Themed Text. Inherits Text's full API; defaults to Theme typography."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Variants"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.palette.borderHairline
            }

            LogosText {
                text: "Title — primary text color"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Body — primary text color, regular weight"
                font.pixelSize: Theme.typography.primaryText
                color: Theme.palette.text
            }
            LogosText {
                text: "Body — secondary color"
                font.pixelSize: Theme.typography.primaryText
                color: Theme.palette.textSecondary
            }
            LogosText {
                text: "Body — tertiary color"
                font.pixelSize: Theme.typography.primaryText
                color: Theme.palette.textTertiary
            }
            LogosText {
                text: "Caption — secondary text size, muted color"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textMuted
            }
        }

        Item { Layout.fillHeight: true }
    }
}
