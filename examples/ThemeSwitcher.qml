// Example: Theme Switcher Button
// Shows how to add a button that toggles between light and dark themes

import QtQuick
import QtQuick.Controls
import Logos.DesignSystem 1.0

Button {
    id: themeSwitcher
    
    // Button text changes based on current theme
    text: Theme.isDark ? "☀️ Light Mode" : "🌙 Dark Mode"
    
    // Width adjusts to content
    implicitWidth: contentItem.implicitWidth + Theme.spacing.xlarge * 2
    implicitHeight: 36
    
    // Toggle theme on click
    onClicked: Theme.switchTheme()
    
    // Custom background with theme colors
    background: Rectangle {
        color: {
            if (parent.pressed) return Theme.palette.primaryPressed
            if (parent.hovered) return Theme.palette.primaryHover
            return Theme.palette.primary
        }
        radius: Theme.spacing.radiusSmall
        border.width: 1
        border.color: Theme.palette.focus
    }
    
    // Custom text styling
    contentItem: Text {
        text: parent.text
        color: Theme.palette.background
        font.pixelSize: Theme.typography.body
        font.weight: Theme.typography.weightNormal
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    
    // Hover effect
    hoverEnabled: true
    
    // Smooth transitions
    Behavior on opacity {
        NumberAnimation { duration: 150 }
    }
}
