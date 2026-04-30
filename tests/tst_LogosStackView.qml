import QtQuick
import QtQuick.Controls
import QtTest

import Logos.Controls

TestCase {
    name: "LogosStackView"
    width: 300
    height: 300
    when: windowShown

    Component { id: pageA; Rectangle { color: "red"; objectName: "A" } }
    Component { id: pageB; Rectangle { color: "blue"; objectName: "B" } }

    LogosStackView {
        id: stack
        anchors.fill: parent
        initialItem: pageA
    }

    function test_initial_item_present() {
        verify(stack.currentItem)
        compare(stack.depth, 1)
    }

    function test_push_pop() {
        stack.push(pageB)
        compare(stack.depth, 2)
        stack.pop()
        compare(stack.depth, 1)
    }
}
