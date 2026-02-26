import QtQuick

QtObject {
    // Based on Basecamp MVP v.1 Figma design

    function getColor(baseColor, alpha) {
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, alpha)
    }
    
    readonly property color white: "#FFFFFF"
    readonly property color whiteOpacity06: getColor(white, 0.06)
    readonly property color whiteOpacity63: getColor(white, 0.63)
    readonly property color black: "#000000"
    readonly property color blackOpacity10: getColor(black, 0.1)
    
    // Grey shades
    readonly property color gray50: "#FAFAFA"
    readonly property color gray100: "#EBEBEB"
    readonly property color gray200: "#D9D9D9"
    readonly property color gray300: "#434343"
    readonly property color gray330: "#333333"
    readonly property color gray340: "#2F2F2F"
    readonly property color gray400: "#A4A4A4"
    readonly property color gray500: "#969696"
    readonly property color gray550: "#808080"
    readonly property color gray600: "#717784"
    readonly property color gray700: "#5C5C5C"
    readonly property color gray800: "#2B303B"
    readonly property color gray850: "#262626"
    readonly property color gray875: "#1C1C1C"
    readonly property color gray925: "#141414"
    readonly property color gray900: "#171717"
    readonly property color gray950: "#0E121B"
    readonly property color gray975: "#101214"
    readonly property color gray550Opacity07: getColor(gray550, 0.07)
    readonly property color gray550Opacity30: getColor(gray550, 0.3)
    
    // Orange shades (Primary/Accent)
    readonly property color orange300: "#ED7B58"
    readonly property color orange350: "#FF6F42"
    readonly property color orange400: "#FF8800"
    readonly property color orange450: "#FF4911"
    readonly property color orange400Opacity30: getColor(orange400, 0.3)
    readonly property color orange500: "#F55702"
    readonly property color orange600: "#F57A02"
    readonly property color orange700: "#BF5104"
    
    // Red shades (Error/Notifications)
    readonly property color red400: "#FF736A"
    readonly property color red500: "#FB3748"
    readonly property color red600: "#F44336"
    readonly property color red700: "#DC2626"
    
    // yellow shades (Warning)
    readonly property color yellow400: "#FEBC2E"
    readonly property color yellow500: "#FFA726"
    readonly property color yellow300: "#EEF083"
    
    // Green shades (Success)
    readonly property color green400: "#6CCC93"
    readonly property color green500: "#49F563"
    readonly property color green600: "#19C332"
    readonly property color green700: "#16A34A"
    readonly property color green800: "#15803D"
    
    // Blue shades (Info)
    readonly property color blue400: "#4A90E2"
    readonly property color blue500: "#3578C7"
    readonly property color blue600: "#2563EB"
    readonly property color blue700: "#1D4ED8"
    
    // Cyan shades
    readonly property color cyan400: "#29B6F6"
    readonly property color cyan500: "#0284C7"
}
