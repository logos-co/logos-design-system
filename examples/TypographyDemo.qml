import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Logos.DesignSystem 1.0

Rectangle {
    color: Theme.palette.background
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        
        ColumnLayout {
            width: parent.width
            spacing: Theme.spacing.xxlarge
            
            Text {
                text: "Typography System"
                font.pixelSize: Theme.typography.secondary.size
                font.weight: Theme.typography.secondary.weight
                color: Theme.palette.text
            }
            
            // Typography styles (primary/secondary/tertiary)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.large
                
                Text {
                    text: "Styles"
                    font.pixelSize: Theme.typography.tertiary.size
                    font.weight: Theme.typography.tertiary.weight
                    color: Theme.palette.text
                }
                
                Repeater {
                    model: [
                        {name: "Primary", key: "primary", style: Theme.typography.primary},
                        {name: "Secondary", key: "secondary", style: Theme.typography.secondary},
                        {name: "Tertiary", key: "tertiary", style: Theme.typography.tertiary}
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
                                
                                Text {
                                    text: modelData.name
                                    font.pixelSize: 12
                                    font.weight: Theme.typography.weightMedium
                                    color: Theme.palette.text
                                }
                                
                                Text {
                                    text: "Theme.typography." + modelData.key
                                    font.pixelSize: 11
                                    color: Theme.palette.textSecondary
                                }
                                
                                Text {
                                    text: modelData.style.size + "px / " + modelData.style.lineHeight + "px"
                                    font.pixelSize: 11
                                    color: Theme.palette.textTertiary
                                }
                            }
                            
                            Rectangle {
                                Layout.preferredWidth: 1
                                Layout.fillHeight: true
                                color: Theme.palette.border
                            }
                            
                            Text {
                                id: sampleText
                                Layout.fillWidth: true
                                text: "The quick brown fox jumps over the lazy dog"
                                font.family: modelData.style.family
                                font.pixelSize: modelData.style.size
                                font.weight: modelData.style.weight
                                font.letterSpacing: modelData.style.letterSpacing
                                lineHeight: modelData.style.lineHeight
                                lineHeightMode: Text.FixedHeight
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
                
                Text {
                    text: "Spacing Scale"
                    font.pixelSize: Theme.typography.tertiary.size
                    font.weight: Theme.typography.tertiary.weight
                    color: Theme.palette.text
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
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 60
                        color: Theme.palette.backgroundSecondary
                        radius: Theme.spacing.radiusLarge
                        border.width: 1
                        border.color: Theme.palette.border
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.spacing.large
                            spacing: Theme.spacing.large
                            
                            ColumnLayout {
                                Layout.preferredWidth: 150
                                spacing: Theme.spacing.tiny
                                
                                Text {
                                    text: modelData.name
                                    font.pixelSize: 12
                                    font.weight: Theme.typography.weightMedium
                                    color: Theme.palette.text
                                }
                                
                                Text {
                                    text: "Theme.spacing." + modelData.key
                                    font.pixelSize: 11
                                    color: Theme.palette.textSecondary
                                }
                            }
                            
                            Rectangle {
                                width: modelData.value
                                height: 30
                                color: Theme.palette.primary
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.value + "px"
                                    font.pixelSize: 11
                                    color: Theme.palette.background
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
