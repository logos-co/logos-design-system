import QtQuick
import QtQuick.Controls
import QtTest

import Logos.Controls

TestCase {
    name: "LogosScrollView"
    width: 600
    height: 400
    when: windowShown

    // Default fixture — long child that overflows. Mirrors the original test.
    LogosScrollView {
        id: scroll
        x: 0; y: 0
        width: 200; height: 200

        Rectangle {
            implicitWidth: 200
            implicitHeight: 800
            color: "transparent"
        }
    }

    // Use case 2: short content that fits the viewport (no overflow).
    LogosScrollView {
        id: shortScroll
        x: 220; y: 0
        width: 200; height: 200

        Rectangle {
            implicitWidth: 200
            implicitHeight: 50
            color: "transparent"
        }
    }

    // Use case 3: bounded box with explicit Column children — exercises the
    // realistic consumer pattern (and `clip: true`).
    LogosScrollView {
        id: boundedScroll
        x: 0; y: 220
        width: 200; height: 120

        Column {
            id: boundedContent
            width: boundedScroll.width
            Repeater {
                model: 20
                Rectangle { width: parent.width; height: 30; color: "transparent" }
            }
        }
    }

    // Use case 4: wrapping text — content height should grow when width is
    // narrow enough to force wrapping.
    LogosScrollView {
        id: textScroll
        x: 220; y: 220
        width: 150; height: 80

        Text {
            width: textScroll.availableWidth
            wrapMode: Text.WordWrap
            text: "The quick brown fox jumps over the lazy dog. " +
                  "The quick brown fox jumps over the lazy dog. " +
                  "The quick brown fox jumps over the lazy dog."
        }
    }

    function test_scrollbars_attached() {
        verify(ScrollBar.horizontal !== undefined)
        verify(ScrollBar.vertical !== undefined)
    }

    function test_content_larger_than_view() {
        verify(scroll.contentWidth > scroll.width || scroll.contentHeight > scroll.height)
    }

    function test_short_content_does_not_overflow_vertically() {
        tryVerify(function() { return shortScroll.contentHeight <= shortScroll.height })
    }

    function test_bounded_box_overflows_and_scrolls() {
        tryVerify(function() { return boundedScroll.contentHeight > boundedScroll.height })

        const flickable = boundedScroll.contentItem
        verify(flickable)
        compare(flickable.contentY, 0)
        flickable.contentY = 80
        compare(flickable.contentY, 80)
    }

    function test_wrapping_text_grows_content_height() {
        // Wrapped paragraph in a narrow viewport should be at least two lines
        // tall — well above the unwrapped single-line ~16px.
        tryVerify(function() { return textScroll.contentHeight > 30 })
    }
}
