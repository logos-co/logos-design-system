import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Logos.Theme 1.0
import Logos.Controls 1.0

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
            
            LogosText {
                text: "Logos Design System"
                font.pixelSize: Theme.typography.secondaryText
                font.weight: Theme.typography.weightMedium
                color: Theme.palette.text
            }
            
            Item { Layout.fillWidth: true }
            
            // Theme switcher button
            LogosButton {
                text: Theme.isDark ? "☀️ Light Mode" : "🌙 Dark Mode"
                implicitHeight: 40
                onClicked: Theme.switchTheme()
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

                    contentItem: LogosText {
                        text: parent.text
                        color: tabBar.currentIndex === index ?
                               Theme.palette.text : Theme.palette.textSecondary
                        font.pixelSize: Theme.typography.secondaryText
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
