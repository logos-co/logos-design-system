import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Logos.DesignSystem 1.0

Rectangle {
    id: root
    width: 800
    height: 600
    color: Theme.palette.background
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        
        ColumnLayout {
            width: parent.width
            spacing: Theme.spacing.xxlarge
            
            // Header with theme switcher
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.large
                
                Text {
                    text: "Logos Design System Color Demo"
                    font.pixelSize: Theme.typography.secondary.size
                    font.weight: Theme.typography.secondary.weight
                    color: Theme.palette.text
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: Theme.isDark ? "☀️ Light Mode" : "🌙 Dark Mode"
                    onClicked: Theme.switchTheme()
                    
                    background: Rectangle {
                        color: parent.pressed ? Theme.palette.primaryPressed :
                               parent.hovered ? Theme.palette.primaryHover :
                               Theme.palette.primary
                        radius: Theme.spacing.radiusSmall
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: Theme.palette.background
                        font.pixelSize: 12
                        font.weight: Theme.typography.weightMedium
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    hoverEnabled: true
                }
            }
            
            // Backgrounds Section
            ColorSection {
                title: "Backgrounds"
                colors: [
                    {name: "background", color: Theme.palette.background},
                    {name: "backgroundSecondary", color: Theme.palette.backgroundSecondary},
                    {name: "backgroundTertiary", color: Theme.palette.backgroundTertiary},
                    {name: "backgroundElevated", color: Theme.palette.backgroundElevated},
                    {name: "backgroundMuted", color: Theme.palette.backgroundMuted}
                ]
            }
            
            // Text Section
            ColorSection {
                title: "Text"
                colors: [
                    {name: "text", color: Theme.palette.text},
                    {name: "textSecondary", color: Theme.palette.textSecondary},
                    {name: "textTertiary", color: Theme.palette.textTertiary}
                ]
            }
            
            // Borders Section
            ColorSection {
                title: "Borders"
                colors: [
                    {name: "border", color: Theme.palette.border},
                    {name: "borderSecondary", color: Theme.palette.borderSecondary},
                    {name: "borderTertiary", color: Theme.palette.borderTertiary},
                    {name: "borderTertiaryMuted", color: Theme.palette.borderTertiaryMuted}
                ]
            }
            
            // Primary Colors
            ColorSection {
                title: "Primary (Orange)"
                colors: [
                    {name: "primary", color: Theme.palette.primary},
                    {name: "primaryHover", color: Theme.palette.primaryHover},
                    {name: "primaryPressed", color: Theme.palette.primaryPressed}
                ]
            }
            
            // Success Colors
            ColorSection {
                title: "Success (Green)"
                colors: [
                    {name: "success", color: Theme.palette.success},
                    {name: "successHover", color: Theme.palette.successHover},
                    {name: "successPressed", color: Theme.palette.successPressed}
                ]
            }
            
            // Error Colors
            ColorSection {
                title: "Error (Red)"
                colors: [
                    {name: "error", color: Theme.palette.error},
                    {name: "errorHover", color: Theme.palette.errorHover},
                    {name: "errorPressed", color: Theme.palette.errorPressed}
                ]
            }
            
            // Other Colors
            ColorSection {
                title: "Other"
                colors: [
                    {name: "warning", color: Theme.palette.warning},
                    {name: "warningHover", color: Theme.palette.warningHover},
                    {name: "info", color: Theme.palette.info},
                    {name: "notification", color: Theme.palette.notification},
                    {name: "accentOrange", color: Theme.palette.accentOrange},
                    {name: "accentBurntOrange", color: Theme.palette.accentBurntOrange},
                    {name: "accentYellowSoft", color: Theme.palette.accentYellowSoft}
                ]
            }
            
            // Interactive States
            ColorSection {
                title: "Interactive States"
                colors: [
                    {name: "hover", color: Theme.palette.hover},
                    {name: "pressed", color: Theme.palette.pressed},
                    {name: "disabled", color: Theme.palette.disabled},
                    {name: "focus", color: Theme.palette.focus}
                ]
            }

            // Overlay / Glass
            ColorSection {
                title: "Overlay / Glass"
                colors: [
                    {name: "glassOverlay", color: Theme.palette.glassOverlay},
                    {name: "glassStrong", color: Theme.palette.glassStrong},
                    {name: "overlayLight", color: Theme.palette.overlayLight},
                    {name: "overlayOrange", color: Theme.palette.overlayOrange}
                ]
            }
        }
    }
    
    // Color section component
    component ColorSection: ColumnLayout {
        property string title
        property var colors: []
        
        Layout.fillWidth: true
        spacing: Theme.spacing.medium
        
        Text {
            text: title
            font.pixelSize: Theme.typography.tertiary.size
            font.weight: Theme.typography.tertiary.weight
            color: Theme.palette.text
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.palette.border
        }
        
        GridLayout {
            Layout.fillWidth: true
            columns: 3
            columnSpacing: Theme.spacing.large
            rowSpacing: Theme.spacing.medium
            
            Repeater {
                model: colors
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 80
                    color: modelData.color
                    radius: Theme.spacing.radiusLarge
                    border.width: 1
                    border.color: Theme.palette.border
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacing.tiny
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.name
                            font.pixelSize: 12
                            font.weight: Theme.typography.weightMedium
                            color: {
                                // Pick contrasting text color
                                var r = ((modelData.color >> 16) & 0xFF) / 255;
                                var g = ((modelData.color >> 8) & 0xFF) / 255;
                                var b = (modelData.color & 0xFF) / 255;
                                var luminance = 0.299 * r + 0.587 * g + 0.114 * b;
                                return luminance > 0.5 ? "#000000" : "#ffffff";
                            }
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.color.toString()
                            font.pixelSize: 11
                            color: {
                                var r = ((modelData.color >> 16) & 0xFF) / 255;
                                var g = ((modelData.color >> 8) & 0xFF) / 255;
                                var b = (modelData.color & 0xFF) / 255;
                                var luminance = 0.299 * r + 0.587 * g + 0.114 * b;
                                return luminance > 0.5 ? "#000000" : "#ffffff";
                            }
                        }
                    }
                }
            }
        }
    }
}
