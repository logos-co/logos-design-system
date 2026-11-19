import QtQuick
import QtTest
import Qt.labs.folderlistmodel

import Logos.Theme
import "qrc:/PhoneChecks.js" as PhoneChecks

// Every storybook page at a phone's width, as the storybook's Preview window
// shows it: nothing reaches past the sides. The pieces themselves are in
// tst_PhoneFit.qml.
TestCase {
    id: root
    name: "StorybookPhoneFit"
    width: 390
    height: 844
    // Effective visibility needs a visible TestCase.
    visible: true
    when: windowShown

    FolderListModel {
        id: pages
        folder: Qt.resolvedUrl("../storybook/pages")
        nameFilters: ["*Page.qml"]
        showDirs: false
    }

    Loader {
        id: loader
        width: root.width
    }

    function initTestCase() {
        Theme.viewWidth = root.width
        tryCompare(pages, "status", FolderListModel.Ready)
    }

    function cleanupTestCase() {
        Theme.viewWidth = 0
    }

    function cleanup() {
        loader.source = ""
    }

    function test_page_data() {
        const rows = []
        for (let i = 0; i < pages.count; ++i)
            rows.push({ tag: pages.get(i, "fileBaseName"), url: pages.get(i, "fileUrl") })
        // An installed test binary has no storybook beside it.
        return rows.length > 0 ? rows : [{ tag: "no pages", url: "" }]
    }

    function test_page(data) {
        if (data.url === "")
            skip("no storybook pages beside the tests")
        loader.source = data.url
        verify(loader.item, "loads")
        // The Preview window's page: as tall as its content, at least the window.
        loader.height = Math.max(loader.item.implicitHeight || 0, root.height - Theme.size.touchTarget)
        waitForRendering(loader.item)
        const found = PhoneChecks.find(loader.item, Theme.size.touchTarget)
        compare(found.overflow.map(item => PhoneChecks.describe(item, loader.item)).join("; "), "",
                "past the sides")
    }
}
