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
                text: "LogosSpinBox"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: SpinBox (from, to, value, stepSize, editable). Aliases: backgroundItem, contentLabel."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        ColumnLayout {
            spacing: Theme.spacing.medium

            LogosSpinBox { from: 0; to: 100; value: 25 }
            LogosSpinBox { from: -50; to: 50; value: 0; stepSize: 5 }
            LogosSpinBox { from: 0; to: 10; value: 3; enabled: false }
        }

        Item { Layout.fillHeight: true }
    }
}
