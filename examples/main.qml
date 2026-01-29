import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Logos.DesignSystem 1.0

ApplicationWindow {
    id: window
    width: 1000
    height: 700
    visible: true
    title: "Logos Design System Demo - " + (Theme.isDark ? "Dark Mode" : "Light Mode")
    
    color: Theme.palette.background
    
    // Header with theme switcher
    header: Rectangle {
        height: 60
        color: Theme.palette.backgroundSecondary
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacing.large
            spacing: Theme.spacing.large
            
            Text {
                text: "Logos Design System"
                font.pixelSize: Theme.typography.secondary.size
                font.weight: Theme.typography.secondary.weight
                color: Theme.palette.text
            }
            
            Item { Layout.fillWidth: true }
            
            // Theme switcher button
            Button {
                text: Theme.isDark ? "☀️ Light Mode" : "🌙 Dark Mode"
                implicitHeight: 40
                
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
                
                onClicked: Theme.switchTheme()
                hoverEnabled: true
            }
        }
    }
    
    // Main content area with tabs
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // Tab bar
        TabBar {
            id: tabBar
            Layout.fillWidth: true
            implicitHeight: 48

            background: Rectangle {
                color: Theme.palette.backgroundSecondary
            }

            Repeater {
                model: ["Colors Demo", "Typography"]

                TabButton {
                    text: modelData
                    implicitWidth: 150

                    background: Rectangle {
                        color: tabBar.currentIndex === index ?
                               Theme.palette.background : "transparent"
                    }

                    contentItem: Text {
                        text: parent.text
                        color: tabBar.currentIndex === index ?
                               Theme.palette.text : Theme.palette.textSecondary
                        font.pixelSize: Theme.typography.tertiary.size
                        font.weight: tabBar.currentIndex === index ?
                                     Theme.typography.weightBold : Theme.typography.weightRegular
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
        
        // Content area
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex
            
            // Tab 1: Colors Demo
            Loader {
                source: "ColorDemo.qml"
            }                
            
            // Tab 4: Typography Demo
            TypographyDemo {}
        }
    }
}
