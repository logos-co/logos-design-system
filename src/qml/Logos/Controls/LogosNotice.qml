import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Icons

// LogosNotice — a severity-coloured message surface.
//
// Public API:
//     severity         LogosNotice.Info | .Success | .Warning | .Error
//                      (default .Info). Drives text, border and background from
//                      Theme.palette; never hardcode a hex.
//     title            Optional bold heading. Hidden when empty.
//     message          Body text. Wraps.
//     shown            Whether the notice is displayed (default true); `visible`
//                      follows it.
//     closable         Show a dismiss button (default false). Emits dismissed().
//     actions          Items laid out under the message, supplied by the caller
//                      and reparented
//     hide()           Imperative close; emits dismissed().
//     dismissed()      Emitted when closed.
//
// Read-only inspection aliases (for tests):
//     titleItem, messageItem, backgroundItem, closeButtonItem
//
// Inline form error — bind visibility to your error string, no dismiss button,
// because retrying is what clears it:
//
//     LogosNotice {
//         Layout.fillWidth: true
//         severity: LogosNotice.Error
//         message: root.openError
//         shown: message.length > 0
//     }
//
// Standing notice the user may need to read back — dismissible, never timed.
// Note `shown` is left unbound here, so the dismiss button can drive it:
//
//     LogosNotice {
//         severity: LogosNotice.Warning
//         message: backend.startupNotice
//         closable: true
//         actions: [
//             LogosButton { text: qsTr("Retry"); onClicked: backend.retry() }
//         ]
//     }
//
// For a message that arrives, says its piece and leaves, use LogosToast.
Control {
    id: root

    enum Severity {
        Info,
        Success,
        Warning,
        Error
    }

    property int severity: LogosNotice.Info
    property string title: ""
    property string message: ""
    property bool closable: false
    property list<Item> actions
    property bool shown: true

    signal dismissed()

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias titleItem: titleLabel
    readonly property alias messageItem: messageLabel
    readonly property alias backgroundItem: bg
    readonly property alias closeButtonItem: closeButton
    readonly property alias iconItem: severityIcon

    function hide() {
        if (!root.shown)
            return
        root.shown = false
        root.dismissed()
    }

    QtObject {
        id: d

        readonly property color accent: {
            switch (root.severity) {
            case LogosNotice.Success: return Theme.palette.success
            case LogosNotice.Warning: return Theme.palette.warning
            case LogosNotice.Error:   return Theme.palette.error
            default:                  return Theme.palette.primary
            }
        }

        readonly property color borderColor: {
            switch (root.severity) {
            case LogosNotice.Success: return Theme.palette.successBorder
            case LogosNotice.Warning: return Theme.palette.warningBorder
            case LogosNotice.Error:   return Theme.palette.errorBorder
            default:                  return Theme.palette.primaryBorder
            }
        }
        readonly property url iconSource: {
            switch (root.severity) {
            case LogosNotice.Success: return LogosIcons.check
            case LogosNotice.Warning: return LogosIcons.warning
            case LogosNotice.Error:   return LogosIcons.warning
            default:                  return LogosIcons.info
            }
        }
        readonly property bool hasTitle: root.title.length > 0
        readonly property bool hasActions: root.actions && root.actions.length > 0
    }

    visible: root.shown
    padding: Theme.spacing.medium

    background: Rectangle {
        id: bg
        color: Theme.palette.backgroundElevated
        border.color: d.borderColor
        border.width: 1
        radius: Theme.spacing.radiusSmall
    }

    contentItem: RowLayout {
        spacing: Theme.spacing.medium

        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            radius: width / 2
            color: Theme.palette.surface

            LogosIcon {
                id: severityIcon
                anchors.centerIn: parent
                width: 16
                height: 16
                source: d.iconSource
                color: d.accent
                brightness: 1.0
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.tiny

            LogosText {
                id: titleLabel
                Layout.fillWidth: true
                visible: d.hasTitle
                text: root.title
                color: Theme.palette.text
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                wrapMode: Text.WordWrap
            }

            LogosText {
                id: messageLabel
                Layout.fillWidth: true
                text: root.message
                color: d.hasTitle ? Theme.palette.textSecondary : Theme.palette.text
                font.pixelSize: Theme.typography.secondaryText
                wrapMode: Text.WordWrap
            }

            Row {
                Layout.topMargin: Theme.spacing.tiny
                visible: d.hasActions
                spacing: Theme.spacing.small
                children: root.actions
            }
        }

        LogosIconButton {
            id: closeButton
            Layout.alignment: Qt.AlignTop
            visible: root.closable
            flat: true
            size: 20
            iconSize: 12
            iconSource: LogosIcons.close
            iconColor: Theme.palette.textTertiary
            onClicked: root.hide()
        }
    }
}
