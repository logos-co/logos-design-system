pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

// LogosWizard — a task done in steps, as the apps' onboarding does it: a title,
// a rail of the steps across the top, the step's page, and Back on the left
// with the main button on the right. The main button names what it does
// ("Start node"), and while it can't be pressed a hint beside it says why. An
// optional welcome screen comes first, and Back from the first step returns
// to it, as Esc and the phone's Back key do. On a phone the rail names only
// the current step and the buttons stack, the main one last, with the hint
// above them; they stay above the keyboard, and the field with focus scrolls
// into view. The page scrolls.
//
// Steps are what the user does. What the system does afterwards (starting,
// syncing) belongs in a LogosStageLane, not here.
//
// Public API:
//     title, subtitle     over the rail
//     steps               the steps' names, for the rail
//     currentIndex        the step shown
//     welcome             a Component shown before the first step, usually a
//                         LogosWelcome (default none); it calls begin() to start
//     atWelcome           read-only; the welcome screen shows
//     canGoNext           the step is complete (default true)
//     nextText            the main button (default "Continue"); name the outcome
//                         on the last step
//     nextHint            why the step isn't complete, beside the main button
//     secondaryText       a second way forward, e.g. "Retry"; hidden when empty
//     canGoBack           show Back (default: after the first step, or always
//                         with a welcome screen)
//     cancellable, cancelText   show a button that emits cancelled() (default
//                         false, "Exit")
//     begin(), next(), back()
//     finished(), cancelled(), secondaryClicked()
//     content (default)   one page per step, in order; it warns when the
//                         pages and the steps don't match
//
// Read-only inspection aliases: headerItem, railItem, railLabelItem, hintItem,
// backButtonItem, nextButtonItem, secondaryButtonItem, cancelButtonItem,
// welcomeItem.
//
// Example:
//     LogosWizard {
//         id: wizard
//         anchors.fill: parent
//         title: qsTr("Set up your node")
//         subtitle: qsTr("Advanced setup: configure and secure your node.")
//         steps: [qsTr("Setup"), qsTr("Network"), qsTr("Keys")]
//         welcome: Component {
//             LogosWelcome {
//                 title: qsTr("Blockchain Node")
//                 primaryText: qsTr("Quick start")
//                 secondaryText: qsTr("Advanced")
//                 onSecondaryClicked: wizard.begin()
//             }
//         }
//         canGoNext: currentIndex !== 2 || keysSaved.checked
//         nextHint: canGoNext ? "" : qsTr("Confirm you saved your keys to continue")
//         nextText: currentIndex === 2 ? qsTr("Start node") : qsTr("Continue")
//         onFinished: startNode()
//         SetupPage {}
//         NetworkPage {}
//         KeysPage {}
//     }
Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property var steps: []
    property int currentIndex: 0
    property Component welcome: null
    readonly property bool atWelcome: welcome !== null && !d.begun
    property bool canGoNext: true
    property string nextText: qsTr("Continue")
    property string nextHint: ""
    property string secondaryText: ""
    property bool canGoBack: currentIndex > 0 || welcome !== null
    property bool cancellable: false
    property string cancelText: qsTr("Exit")
    readonly property bool phone: Theme.windowClass(width) === "phone"
    default property alias content: pages.data

    signal finished()
    signal cancelled()
    signal secondaryClicked()

    readonly property alias headerItem: header
    readonly property alias railItem: rail
    readonly property alias railLabelItem: railLabel
    readonly property alias hintItem: d.hint
    readonly property alias backButtonItem: backButton
    readonly property alias nextButtonItem: nextButton
    readonly property alias secondaryButtonItem: secondaryButton
    readonly property alias cancelButtonItem: cancelButton
    readonly property alias welcomeItem: welcomeLoader

    Keys.onEscapePressed: event => d.goBack(event)
    Keys.onBackPressed: event => d.goBack(event)

    function begin() {
        currentIndex = 0
        d.begun = true
    }

    function next() {
        if (!canGoNext)
            return
        if (d.last)
            finished()
        else
            ++currentIndex
    }

    function back() {
        if (currentIndex > 0)
            --currentIndex
        else if (welcome)
            d.begun = false
    }

    QtObject {
        id: d
        property bool begun: false

        // Back, unless there is nowhere to go: then the key goes on.
        function goBack(event) {
            event.accepted = !root.atWelcome && root.canGoBack
            if (event.accepted)
                root.back()
        }

        readonly property real keyboard: Theme.keyboardInset(root)
        onKeyboardChanged: reveal()
        function reveal() {
            if (root.Window.window)
                Theme.scrollIntoView(root.Window.window.activeFocusItem, scroll)
        }
        property bool complete: false
        // One page per step; a step without one would show nothing. Checked
        // again once the change is through: a step and its page come and go
        // one after the other.
        readonly property bool mismatched: complete && pages.count !== count
        onMismatchedChanged: if (mismatched)
            Qt.callLater(warnIfMismatched)
        function warnIfMismatched() {
            if (mismatched)
                console.warn("LogosWizard: " + count + " steps but " + pages.count + " pages")
        }
        readonly property int count: root.steps.length
        readonly property bool last: root.currentIndex >= count - 1
        readonly property bool hintShown: !root.canGoNext && root.nextHint !== ""
        readonly property Item hint: buttons.stacked ? stackedHint : inlineHint
        readonly property real rightWidth: buttons.rightActions.length === 0 ? 0
            : nextButton.width + (root.secondaryText !== "" ? secondaryButton.width + Theme.spacing.small : 0)

        // Unparented until the button row shows them.
        readonly property LogosButton cancel: LogosButton {
            id: cancelButton
            text: root.cancelText
            onClicked: root.cancelled()
        }
        readonly property LogosButton back: LogosButton {
            id: backButton
            text: qsTr("Back")
            onClicked: root.back()
        }
        readonly property LogosButton secondary: LogosButton {
            id: secondaryButton
            text: root.secondaryText
            onClicked: root.secondaryClicked()
        }
        readonly property LogosButton next: LogosButton {
            id: nextButton
            implicitWidth: Math.max(Theme.layouts.wizard.nextMinWidth,
                                    implicitContentWidth + leftPadding + rightPadding)
            enabled: root.canGoNext
            variant: LogosButton.Variant.Primary
            text: root.nextText
            onClicked: root.next()
        }
    }

    Component.onCompleted: d.complete = true

    Loader {
        id: welcomeLoader
        anchors.fill: parent
        active: root.atWelcome
        visible: active
        sourceComponent: root.welcome
    }

    Connections {
        target: root.Window.window
        function onActiveFocusItemChanged() { d.reveal() }
    }

    ColumnLayout {
        visible: !root.atWelcome
        anchors.fill: parent
        anchors.margins: Theme.pageMargin(root.width)
        anchors.topMargin: Theme.pageMargin(root.width) + Theme.topInset(root)
        anchors.bottomMargin: Theme.pageMargin(root.width) + Theme.bottomInset(root)
        spacing: Theme.spacing.large

        ColumnLayout {
            id: header
            visible: root.title !== "" || root.subtitle !== ""
            Layout.fillWidth: true
            spacing: Theme.spacing.tiny

            LogosText {
                visible: root.title !== ""
                Layout.fillWidth: true
                text: root.title
                wrapMode: Text.Wrap
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
            }
            LogosText {
                visible: root.subtitle !== ""
                Layout.fillWidth: true
                text: root.subtitle
                wrapMode: Text.Wrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        ColumnLayout {
            id: rail
            visible: d.count > 1
            Layout.fillWidth: true
            spacing: Theme.spacing.tiny
            Accessible.role: Accessible.ProgressBar
            Accessible.name: d.count > 0 ? qsTr("Step %1 of %2: %3").arg(root.currentIndex + 1).arg(d.count)
                                                                   .arg(root.steps[root.currentIndex])
                                         : ""

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.small

                Repeater {
                    model: root.steps
                    delegate: ColumnLayout {
                        id: railStep
                        required property int index
                        required property string modelData
                        readonly property bool current: index === root.currentIndex
                        objectName: "railStep" + index
                        // Equal columns, whatever the names' lengths.
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        spacing: Theme.spacing.tiny

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: Theme.layouts.wizard.railHeight
                            radius: height / 2
                            color: railStep.index <= root.currentIndex ? Theme.palette.primary : Theme.palette.border
                        }
                        LogosText {
                            visible: !root.phone
                            Layout.fillWidth: true
                            text: (railStep.index + 1) + ". " + railStep.modelData
                            elide: Text.ElideRight
                            font.pixelSize: Theme.layouts.wizard.railLabelText
                            font.weight: railStep.current ? Theme.typography.weightBold : Theme.typography.weightRegular
                            color: railStep.current ? Theme.palette.text : Theme.palette.textTertiary
                        }
                    }
                }
            }

            // On a phone the columns are too narrow to name every step.
            LogosText {
                id: railLabel
                visible: root.phone
                Layout.fillWidth: true
                text: d.count > 0 ? (root.currentIndex + 1) + ". " + root.steps[root.currentIndex] : ""
                elide: Text.ElideRight
                font.pixelSize: Theme.layouts.wizard.railLabelText
                font.weight: Theme.typography.weightBold
            }
        }

        LogosScrollView {
            id: scroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth

            StackLayout {
                id: pages
                width: scroll.availableWidth
                height: Math.max(scroll.availableHeight, implicitHeight)
                currentIndex: root.currentIndex
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.small

            LogosText {
                id: stackedHint
                visible: d.hintShown && buttons.stacked
                Layout.fillWidth: true
                text: root.nextHint
                wrapMode: Text.Wrap
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
            }

            LogosButtonRow {
                id: buttons
                Layout.fillWidth: true
                leftActions: (root.cancellable ? [cancelButton] : []).concat(root.canGoBack ? [backButton] : [])
                rightActions: (root.secondaryText !== "" ? [secondaryButton] : []).concat([nextButton])

                // Beside the main button, in the room the left-hand ones leave.
                LogosText {
                    id: inlineHint
                    visible: d.hintShown && !buttons.stacked && width > 0
                    anchors.right: parent.right
                    anchors.rightMargin: d.rightWidth + Theme.spacing.medium
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(implicitWidth, parent.width - d.rightWidth - 2 * Theme.spacing.medium
                                    - (root.canGoBack ? backButton.width : 0)
                                    - (root.cancellable ? cancelButton.width + Theme.spacing.small : 0))
                    text: root.nextHint
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: Theme.typography.secondaryText
                    color: Theme.palette.textTertiary
                }
            }
        }
    }
}
