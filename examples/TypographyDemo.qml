import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Logos.Theme 1.0
import Logos.Controls 1.0

Rectangle {
    color: Theme.palette.background
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        
        ColumnLayout {
            width: parent.width
            spacing: Theme.spacing.xxlarge
            
            LogosText {
                text: "Typography System"
            }
            
            // Typography styles (primary/secondary/tertiary)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.large
                
                LogosText {
                    text: "Styles"
                }
                
                Repeater {
                    model: [
                        {name: "Primary", key: "primaryText", pixelSize: Theme.typography.primaryText},
                        {name: "Secondary", key: "secondaryText", pixelSize: Theme.typography.secondaryText},
                    ]
                    
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: sampleText.implicitHeight + Theme.spacing.large * 2
                        color: "transparent"

                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.spacing.large
                            spacing: Theme.spacing.large
                            
                            ColumnLayout {
                                Layout.preferredWidth: 180
                                spacing: Theme.spacing.tiny
                                
                                LogosText {
                                    text: modelData.name
                                    font.pixelSize: 12
                                    font.weight: Theme.typography.weightMedium
                                    color: Theme.palette.text
                                }
                                
                                LogosText {
                                    text: "Theme.typography." + modelData.key
                                    font.pixelSize: 11
                                    color: Theme.palette.textSecondary
                                }
                                
                                LogosText {
                                    text: modelData.pixelSize + "px"
                                    font.pixelSize: 11
                                    color: Theme.palette.textTertiary
                                }
                            }
                            
                            Rectangle {
                                Layout.preferredWidth: 1
                                Layout.fillHeight: true
                                color: Theme.palette.border
                            }
                            
                            LogosText {
                                id: sampleText
                                Layout.fillWidth: true
                                text: "The quick brown fox jumps over the lazy dog"
                                font.family: Theme.typography.publicSans
                                font.pixelSize: modelData.pixelSize
                                color: Theme.palette.text
                            }
                        }
                    }
                }
            }
            
            // Spacing examples
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.large
                
                LogosText {
                    text: "Spacing Scale"
                }
                
                Repeater {
                    model: [
                        {name: "Tiny", value: Theme.spacing.tiny, key: "tiny"},
                        {name: "Small", value: Theme.spacing.small, key: "small"},
                        {name: "Medium", value: Theme.spacing.medium, key: "medium"},
                        {name: "Large", value: Theme.spacing.large, key: "large"},
                        {name: "XLarge", value: Theme.spacing.xlarge, key: "xlarge"},
                        {name: "XXLarge", value: Theme.spacing.xxlarge, key: "xxlarge"}
                    ]
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: modelData.value

                        Rectangle {
                            Layout.preferredWidth: 150
                            Layout.preferredHeight: 60
                            color: Theme.palette.backgroundSecondary
                            radius: Theme.spacing.radiusLarge
                            border.width: 1
                            border.color: Theme.palette.border
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Theme.spacing.tiny
                                
                                LogosText {
                                    Layout.topMargin: Theme.spacing.small
                                    Layout.leftMargin: Theme.spacing.small
                                    text: modelData.name
                                    font.pixelSize: 12
                                    font.weight: Theme.typography.weightMedium
                                    color: Theme.palette.text
                                }
                                
                                LogosText {
                                    Layout.leftMargin: Theme.spacing.small
                                    text: "Theme.spacing." + modelData.key
                                    font.pixelSize: 11
                                    color: Theme.palette.textSecondary
                                }

                                LogosText {
                                    Layout.leftMargin: Theme.spacing.small
                                    text: modelData.value + "px"
                                    font.pixelSize: 8
                                    color: Theme.palette.textSecondary
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: modelData.value
                            Layout.preferredHeight: 30
                            color: Theme.palette.primary
                        }
                    }
                }
            }
        }
    }
}
