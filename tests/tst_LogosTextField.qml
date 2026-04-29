import QtQuick
import QtTest

import Logos.Controls

TestCase {
    id: root
    name: "LogosTextField"
    width: 400
    height: 200
    when: windowShown

    LogosTextField {
        id: field
        placeholderText: "Enter text"
        anchors.centerIn: parent
        width: 200
    }

    function init() {
        field.text = ""
        field.placeholderText = "Enter text"
        field.echoMode = TextInput.Normal
    }

    function test_text_alias_get_set() {
        field.text = "hello"
        compare(field.text, "hello")
        compare(field.textInput.text, "hello")
    }

    function test_input_empty_when_text_cleared() {
        field.text = ""
        compare(field.textInput.text, "")
        compare(field.textInput.text.length, 0)
    }

    function test_input_holds_value_when_text_set() {
        field.text = "x"
        compare(field.textInput.text, "x")
        compare(field.textInput.text.length, 1)
    }

    function test_echo_mode_propagates_to_text_input() {
        field.echoMode = TextInput.Password
        compare(field.textInput.echoMode, TextInput.Password)
    }
}
