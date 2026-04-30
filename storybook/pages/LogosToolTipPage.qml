import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

Rectangle {
    property string figmaUrl: ""
    property bool designed: true

    color: Theme.palette.background

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosToolTip"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Directional tooltip with a tail. Set `placement` to Top/Bottom/Left/Right; the tail rotates to point at the parent. Hover the labels below to see each variant."
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        // Each cell shows a LogosText with a HoverHandler-driven tooltip in
        // the placement named below it. We give the grid generous spacing so
        // the tooltips can pop out without overlapping their neighbours.
        GridLayout {
            columns: 4
            rowSpacing: Theme.spacing.xxlarge
            columnSpacing: Theme.spacing.xxlarge
            Layout.alignment: Qt.AlignHCenter

            Repeater {
                model: [
                    { label: "Top",    placement: LogosToolTip.Top,    hint: "Tooltip on top" },
                    { label: "Bottom", placement: LogosToolTip.Bottom, hint: "Tooltip on bottom" },
                    { label: "Left",   placement: LogosToolTip.Left,   hint: "Tooltip on left" },
                    { label: "Right",  placement: LogosToolTip.Right,  hint: "Tooltip on right" }
                ]

                delegate: Item {
                    id: cell
                    required property var modelData
                    Layout.preferredWidth: 140
                    Layout.preferredHeight: 60

                    LogosText {
                        anchors.centerIn: parent
                        text: cell.modelData.label
                        font.pixelSize: Theme.typography.primaryText
                        font.weight: Theme.typography.weightBold
                        color: Theme.palette.text

                        HoverHandler { id: hover }

                        LogosToolTip {
                            text: cell.modelData.hint
                            placement: cell.modelData.placement
                            visible: hover.hovered
                        }
                    }
                }
            }
        }

        // On a Button, mirror Qt's `ToolTip.visible: down` pattern by
        // binding LogosToolTip.visible to `parent.down`. Press and hold to
        // see it.
        ColumnLayout {
            spacing: Theme.spacing.small
            Layout.topMargin: Theme.spacing.xlarge

            LogosText {
                text: "On a button (press and hold)"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }

            LogosButton {
                id: saveBtn
                text: qsTr("Save")
                implicitWidth: 140
                implicitHeight: 36

                LogosToolTip {
                    text: qsTr("Save the active project")
                    placement: LogosToolTip.Bottom
                    visible: saveBtn.mouseAreaItem.pressed
                }
            }
        }

        ColumnLayout {
            spacing: Theme.spacing.small
            Layout.topMargin: Theme.spacing.xlarge

            LogosText {
                text: "Usage"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "// Hover\nLogosText {\n    text: \"Hover me\"\n    HoverHandler { id: hover }\n\n    LogosToolTip {\n        text: \"Hint\"\n        placement: LogosToolTip.Top\n        visible: hover.hovered\n    }\n}\n\n// Button press (LogosButton extends Control, not Button —\n// use the exposed mouseAreaItem alias instead of `down`)\nLogosButton {\n    id: saveBtn\n    text: qsTr(\"Save\")\n    LogosToolTip {\n        text: qsTr(\"Save the active project\")\n        visible: saveBtn.mouseAreaItem.pressed\n    }\n}"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Item { Layout.fillHeight: true }
    }
}
