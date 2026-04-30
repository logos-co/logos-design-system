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
                text: "LogosSpinner"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: BusyIndicator (running) + ringColor, thickness, dotSize. Aliases: ringItem, dotItem."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        RowLayout {
            spacing: Theme.spacing.large
            LogosSpinner { running: true }
            LogosSpinner { running: true; implicitWidth: 24; implicitHeight: 24; thickness: 2; dotSize: 4 }
            LogosSpinner { running: false }
        }

        Item { Layout.fillHeight: true }
    }
}
