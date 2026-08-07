import QtQuick
import QtTest

import Logos.Controls

TestCase {
    id: tc
    name: "LogosArtwork"
    width: 200
    height: 200
    when: windowShown

    LogosArtwork {
        id: icon
        source: "qrc:/test-icon.png"
        width: 40
        height: 40
        anchors.centerIn: parent
    }

    function init() {
        icon.source = "qrc:/test-icon.png"
        icon.radius = 0
        icon.brightness = 0
        icon.width = 40
        icon.height = 40
    }

    // ── The defect this component exists to avoid ─────────────────────────
    // LogosIcon hardcodes `colorization: 1.0`, which flattens a package's
    // artwork to a single-colour silhouette. Every app icon in basecamp was
    // rendering that way. If this assertion ever fails, full-colour app
    // icons are broken again and it will not be obvious from a screenshot
    // review of chrome-only screens.
    function test_does_not_colorize() {
        compare(icon.effectItem.colorization, 0)
    }

    // Full-bleed: crop rather than letterbox, so an off-spec non-square
    // source still fills its tile instead of leaving bars.
    function test_fill_mode_is_preserve_aspect_crop() {
        compare(icon.imageItem.fillMode, Image.PreserveAspectCrop)
    }

    function test_sourceSize_is_2x_for_hidpi() {
        icon.width = 40
        icon.height = 40
        compare(icon.imageItem.sourceSize.width, 80)
        compare(icon.imageItem.sourceSize.height, 80)
    }

    // `clip: true` would clip to the bounding rect, not the rounded rect,
    // so an opaque full-bleed icon would show square corners on a rounded
    // tile. The mask must be an effect.
    function test_radius_enables_mask() {
        icon.radius = 8
        tryCompare(icon.effectItem, "maskEnabled", true)
    }

    // Without multisampling on the mask layer the rounded corners rasterise
    // as a 1-bit staircase and the artwork reads as pixelated. These are the
    // settings that fix it, so they are worth pinning.
    function test_mask_layer_is_antialiased() {
        icon.radius = 8
        compare(icon.effectItem.maskEnabled, true)
        // These three are the fix, not decoration. The Rectangle antialiases
        // its own corners, but the layer texture it rasterises into does not
        // unless asked: without `samples` the mask edge is a hard staircase
        // and the artwork's rounded corners come out visibly jagged.
        // `smooth` filters the texture when sampled at fractional scale
        // (LogosTile's 0.96 press state).
        compare(icon.maskItem.antialiasing, true)
        compare(icon.maskItem.layer.enabled, true)
        compare(icon.maskItem.layer.samples, 4)
        compare(icon.maskItem.layer.smooth, true)
    }

    function test_zero_radius_disables_mask() {
        icon.radius = 0
        tryCompare(icon.effectItem, "maskEnabled", false)
        // No mask wanted means no FBO: LogosTile instantiates one of these
        // per grid cell and per sidebar entry.
        compare(icon.maskItem.layer.enabled, false)
    }

    function test_brightness_propagates_to_multieffect() {
        icon.brightness = 0.08
        tryCompare(icon.effectItem, "brightness", 0.08)
    }

    function test_source_round_trips() {
        icon.source = "qrc:/test-icon.png"
        compare(icon.source.toString(), "qrc:/test-icon.png")
        compare(icon.imageItem.source.toString(), "qrc:/test-icon.png")
    }

    function test_source_can_be_cleared() {
        icon.source = ""
        compare(icon.source.toString(), "")
        compare(icon.imageItem.source.toString(), "")
    }

    function test_default_implicit_size_is_40() {
        var defaults = Qt.createQmlObject(
            'import Logos.Controls; LogosArtwork { source: "qrc:/test-icon.png" }',
            tc, "defaultsAppIcon")
        compare(defaults.implicitWidth, 40)
        compare(defaults.implicitHeight, 40)
        defaults.destroy()
    }

    function test_default_brightness_and_radius_are_zero() {
        var defaults = Qt.createQmlObject(
            'import Logos.Controls; LogosArtwork { source: "qrc:/test-icon.png" }',
            tc, "defaultsZero")
        compare(defaults.brightness, 0)
        compare(defaults.radius, 0)
        defaults.destroy()
    }
}
