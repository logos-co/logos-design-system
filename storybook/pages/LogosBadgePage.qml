import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Icons

Rectangle {
    property string figmaUrl: ""

    color: Theme.palette.background

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosBadge"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: text, iconSource, color. Aliases: iconItem, labelItem. Non-clickable."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        ColumnLayout {
            spacing: Theme.spacing.medium

            LogosText { text: "Default (accent orange)"; color: Theme.palette.textSecondary }
            LogosBadge { text: "alpha" }

            LogosText { text: "With icon"; color: Theme.palette.textSecondary; Layout.topMargin: Theme.spacing.medium }
            LogosBadge { text: "new"; iconSource: LogosIcons.install }

            LogosText { text: "Custom colors via the color property"; color: Theme.palette.textSecondary; Layout.topMargin: Theme.spacing.medium }
            RowLayout {
                spacing: Theme.spacing.large
                LogosBadge { text: "stable";  color: Theme.palette.success }
                LogosBadge { text: "warning"; color: Theme.palette.warning }
                LogosBadge { text: "error";   color: Theme.palette.error }
                LogosBadge { text: "info";    color: Theme.palette.info }
            }

            LogosText { text: "Radius variants"; color: Theme.palette.textSecondary; Layout.topMargin: Theme.spacing.medium }
            RowLayout {
                spacing: Theme.spacing.large
                LogosBadge { text: "square"; radius: 0 }
                LogosBadge { text: "default" }
                LogosBadge { text: "pill"; radius: height / 2 }
            }

            LogosText { text: "Borderless"; color: Theme.palette.textSecondary; Layout.topMargin: Theme.spacing.medium }
            RowLayout {
                spacing: Theme.spacing.large
                LogosBadge { text: "alpha"; borderWidth: 0 }
                LogosBadge { text: "stable"; color: Theme.palette.success; borderWidth: 0 }
                LogosBadge { text: "pill"; borderWidth: 0; radius: height / 2 }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
