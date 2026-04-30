import QtQuick
import QtQuick.Controls
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
                text: "LogosRadioButton"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: RadioButton (text, checked, clicked()) + activeColor, borderColor, boxColor. Aliases: indicatorItem, labelItem."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        ButtonGroup { id: priorityGroup }

        ColumnLayout {
            spacing: Theme.spacing.medium
            LogosRadioButton { text: "Low";    checked: true;  ButtonGroup.group: priorityGroup }
            LogosRadioButton { text: "Medium"; ButtonGroup.group: priorityGroup }
            LogosRadioButton { text: "High";   ButtonGroup.group: priorityGroup }
            LogosRadioButton { text: "Disabled"; enabled: false }
        }

        Item { Layout.fillHeight: true }
    }
}
