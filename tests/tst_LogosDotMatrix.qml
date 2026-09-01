import QtQuick
import QtTest

import Logos.Controls

TestCase {
    id: tc
    name: "LogosDotMatrix"
    width: 200
    height: 200
    when: windowShown

    LogosDotMatrix {
        id: matrix
        // animationInterval 0 keeps the ripple timer stopped, so `animated`
        // can be asserted on its resting state instead of intermediate frames.
        animationInterval: 0
    }

    function init() {
        matrix.columns = 5
        matrix.dotSize = 8
        matrix.dotSpacing = 4
        matrix.animated = false
        matrix.pattern = matrix.ringPattern
        // Opacities too: tests that tweak them run before others that assume
        // the defaults, and TestCase does not restore properties for you.
        matrix.activeOpacity = 1.0
        matrix.inactiveOpacity = 1.0
        matrix.trailOpacity = 0.35
        matrix._d.phase = 0
    }

    function test_ringPatternIsAFullGrid() {
        compare(matrix.ringPattern.length, 25)
    }

    function test_rowsFollowPatternLength() {
        compare(matrix.rows, 5)

        matrix.pattern = [1, 0, 1]
        compare(matrix.rows, 1)

        matrix.pattern = [1, 0, 1, 0, 1, 1]
        compare(matrix.rows, 2)
    }

    // A short pattern must not be padded out — only the cells it describes
    // are drawn, so a caller can render a partial grid.
    function test_cellCountFollowsPattern() {
        matrix.pattern = [1, 1, 1]
        compare(matrix._d.cellCount, 3)
    }

    // Animated mode ignores the pattern and lights the whole square.
    function test_animatedFillsTheGrid() {
        matrix.pattern = [1, 1, 1]
        matrix.animated = true
        compare(matrix._d.cellCount, 25)
    }

    function test_implicitSizeCountsSpacingBetweenDotsOnly() {
        // 5 dots of 8 with 4 gaps of 4 => 40 + 16
        compare(matrix.implicitWidth, 56)
        compare(matrix.implicitHeight, 56)

        matrix.columns = 1
        matrix.pattern = [1]
        compare(matrix.implicitWidth, 8)
    }

    function test_litCellsFollowPattern() {
        matrix.pattern = [1, 0, 0, 0, 0]
        verify(matrix._d.isLit(0))
        verify(!matrix._d.isLit(1))
    }

    // Indices past the end of a short pattern read as unlit rather than
    // throwing or coercing undefined into a truthy value.
    function test_outOfRangeCellsAreUnlit() {
        matrix.pattern = [1]
        verify(!matrix._d.isLit(7))
    }

    function test_emptyPatternRendersNothing() {
        matrix.pattern = []
        compare(matrix._d.cellCount, 0)
    }

    function test_staticOpacityIgnoresPhase() {
        matrix.pattern = [1, 0, 0, 0, 0]
        matrix.activeOpacity = 1.0
        matrix.inactiveOpacity = 0.25
        compare(matrix._d.cellOpacity(0), 1.0)
        compare(matrix._d.cellOpacity(1), 0.25)
    }

    // The ripple travels on Manhattan distance from the centre cell, so the
    // centre of a 5-wide grid is distance 0 and the corners are distance 4.
    function test_rippleDistanceIsMeasuredFromCentre() {
        compare(matrix._d.ringDistance(12), 0)
        compare(matrix._d.ringDistance(0), 4)
        compare(matrix._d.ringDistance(24), 4)
    }

    function test_animatedOpacityPeaksOnTheWavefront() {
        matrix.animated = true
        matrix.activeOpacity = 1.0
        matrix.inactiveOpacity = 0.0
        matrix._d.phase = 0
        // Centre sits on the wavefront; its neighbours trail it; far cells rest.
        compare(matrix._d.cellOpacity(12), 1.0)
        compare(matrix._d.cellOpacity(7), matrix.trailOpacity)
        compare(matrix._d.cellOpacity(0), 0.0)
    }

    // Regression: the trailing ring used to be derived as the midpoint of
    // activeOpacity and inactiveOpacity. Both default to 1.0, so the midpoint
    // was 1.0 too — every dot identical and the ripple invisible. With the
    // defaults untouched the wavefront and its trail must still differ.
    function test_rippleIsVisibleWithDefaultOpacities() {
        matrix.animated = true
        verify(matrix.activeOpacity === matrix.inactiveOpacity)
        matrix._d.phase = 0
        verify(matrix._d.cellOpacity(12) !== matrix._d.cellOpacity(7))
    }

    function test_colorsRoundTrip() {
        matrix.dotColor = "#ff0000"
        matrix.inactiveDotColor = "#00ff00"
        compare(matrix.dotColor, "#ff0000")
        compare(matrix.inactiveDotColor, "#00ff00")
    }
}
