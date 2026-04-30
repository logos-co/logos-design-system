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
                text: "LogosFrame"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: Frame (padding, contentItem) + borderColor, backgroundColor. Alias: backgroundItem."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        LogosFrame {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: Theme.spacing.medium

                LogosText { text: "Framed content"; font.weight: Theme.typography.weightBold; color: Theme.palette.text }
                LogosText { text: "Anything inside a LogosFrame is bordered and padded by default."; color: Theme.palette.textSecondary; Layout.fillWidth: true; wrapMode: Text.WordWrap }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
