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
                text: "LogosSlider"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: Slider (from, to, value, stepSize, etc.) + trackColor, fillColor, handleColor. Aliases: trackItem, fillItem, handleItem."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        ColumnLayout {
            spacing: Theme.spacing.large
            Layout.fillWidth: true

            RowLayout {
                Layout.fillWidth: true
                LogosText { text: "Volume"; color: Theme.palette.text; Layout.preferredWidth: 80 }
                LogosSlider { id: vol; Layout.fillWidth: true; from: 0; to: 100; value: 60 }
                LogosText { text: Math.round(vol.value); color: Theme.palette.textSecondary; Layout.preferredWidth: 40 }
            }

            RowLayout {
                Layout.fillWidth: true
                LogosText { text: "Stepped"; color: Theme.palette.text; Layout.preferredWidth: 80 }
                LogosSlider { Layout.fillWidth: true; from: 0; to: 10; stepSize: 1; value: 4; snapMode: Slider.SnapAlways }
            }

            RowLayout {
                Layout.fillWidth: true
                LogosText { text: "Disabled"; color: Theme.palette.text; Layout.preferredWidth: 80 }
                LogosSlider { Layout.fillWidth: true; from: 0; to: 1; value: 0.3; enabled: false }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
