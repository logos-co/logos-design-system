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
                text: "LogosSwitch"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: Switch (text, checked, clicked()) + trackColorOn/Off, handleColor. Aliases: indicatorItem, handleItem, labelItem."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        ColumnLayout {
            spacing: Theme.spacing.medium
            LogosSwitch { text: "Enable notifications"; checked: true }
            LogosSwitch { text: "Use dark mode"; checked: false }
            LogosSwitch { text: "Disabled"; enabled: false }
            LogosSwitch { text: "Disabled checked"; enabled: false; checked: true }
        }

        Item { Layout.fillHeight: true }
    }
}
