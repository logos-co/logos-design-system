import QtQuick
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls
import Logos.Icons

// LogosStatCard — a labelled metric: a small label, a prominent value, and an
// optional caption underneath.
//
// For a single number that a user reads at a glance — a count, a balance, a
// height, a percentage. Not a general-purpose container: if you want a themed
// surface to put arbitrary content in, that is LogosFrame.
//
// Extends LogosAbstractButton, so `interactive` / `hovered` / `pressed` /
// `clicked()` behave exactly as they do on LogosButton and LogosTile. Unlike
// those, it defaults to `interactive: false` — a stat card is display-first,
// and a non-interactive one stays out of the tab chain and reports itself as
// static text.
//
// Public API:
//     label        small caption above the value
//     value        the figure itself. Pre-formatted by the caller — the card
//                  does no rounding, unit conversion or thousands separation,
//                  all of which are locale-dependent
//     caption      optional third line under the value, for the sentence that
//                  explains the number ("12 slots behind")
//     labelTrailing    slot beside the label, top-right
//     captionTrailing  slot beside the caption, for an affordance that belongs
//                      to the value rather than to the card — a copy button
//                      next to a hash, say
//
//                  Both take any Items — an icon, a badge, a spinner, a menu.
//                  The card does not type their content, it only gives it a
//                  home. For content that does not fit three rows at all,
//                  override `contentItem`: the surface, padding and radius
//                  stay, the layout is yours.
//     severity     LogosStatCard.None (default) / Info / Success / Warning /
//                  Error. Colors the value and reveals a severity icon
//     interactive  hover chrome + clicked(). Default false
//     flashOnChange  pulse the value when it changes. Default false
//     flashColor   the pulse color. Default = primary, i.e. "look here" with
//                  no verdict attached. Set it to success/error when the
//                  direction of the change carries meaning
//     flashDuration  length of the whole pulse in ms. Set 0 in tests
//     backgroundColor / borderColor / radius  surface hooks
//     minimumHeight  height floor so a grid of cards shares one rhythm
//                    whether or not each has a caption (default 108, the
//                    design's tile height). 0 = size purely to content
//
// Read-only inspection aliases (for tests):
//     labelItem, valueItem, captionItem, severityIconItem, backgroundItem,
//     flashAnimationItem

// Example:
//     LogosStatCard {
//         label: qsTr("At Headslot")
//         value: "-12"
//         caption: qsTr("12 slots behind")
//         severity: LogosStatCard.Warning
//         flashOnChange: true
//         labelTrailing: [
//             LogosInfoButton { text: qsTr("How far the tip trails the clock.") }
//         ]
//     }
LogosAbstractButton {
    id: root

    // Mirrors LogosNotice.Severity, plus a None for the resting state — a
    // notice always has something to say, a stat card usually does not.
    enum Severity {
        None,
        Info,
        Success,
        Warning,
        Error
    }

    property string label: ""
    property string value: ""
    property string caption: ""
    // Same idiom as LogosNotice.actions: the caller builds the Items, the
    // control reparents them into the slot.
    property list<Item> labelTrailing
    property list<Item> captionTrailing
    property int severity: LogosStatCard.None

    property bool flashOnChange: false
    property color flashColor: Theme.palette.primary
    property int flashDuration: 1260

    property color backgroundColor: Theme.palette.surfaceRaised
    property color borderColor: "transparent"
    property real radius: Theme.spacing.radiusLarge
    property real minimumHeight: 108

    // Exposed for inspection (e.g., from tests). Read-only.
    readonly property alias labelItem: labelText
    readonly property alias valueItem: valueText
    readonly property alias captionItem: captionText
    readonly property alias severityIconItem: severityIcon
    readonly property alias backgroundItem: bg
    readonly property alias flashAnimationItem: flashAnimation

    QtObject {
        id: d

        // The value's colour at rest. The flash animates away from this and
        // back to it — binding the restore target to a constant is what leaves
        // a warning value stuck on the flash colour, or silently demoted to
        // neutral, after an update.
        readonly property color accent: {
            switch (root.severity) {
            case LogosStatCard.Info:    return Theme.palette.info
            case LogosStatCard.Success: return Theme.palette.success
            case LogosStatCard.Warning: return Theme.palette.warning
            case LogosStatCard.Error:   return Theme.palette.error
            default:                    return Theme.palette.text
            }
        }

        readonly property url iconSource: {
            switch (root.severity) {
            case LogosStatCard.Info:    return LogosIcons.info
            case LogosStatCard.Success: return LogosIcons.check
            case LogosStatCard.Warning: return LogosIcons.warning
            case LogosStatCard.Error:   return LogosIcons.warning
            default:                    return ""
            }
        }

        readonly property bool hasSeverity: root.severity !== LogosStatCard.None

        readonly property color surfaceColor: {
            if (!root.interactive)
                return root.backgroundColor
            if (root.pressed)
                return Theme.palette.surfaceRaised
            if (root.hovered)
                return Theme.palette.surfaceInteractiveHover
            return root.backgroundColor
        }

        // Suppresses the flash on the first value assignment: arriving at a
        // number is not the number changing.
        property bool seenValue: false

        // The pulse rises fast and settles slowly — a symmetric fade reads as
        // a glitch rather than as attention being drawn.
        readonly property int riseMs: Math.round(root.flashDuration / 8)
        readonly property int settleMs: root.flashDuration - riseMs
    }

    interactive: false
    padding: Theme.spacing.medium
    implicitHeight: Math.max(root.minimumHeight,
                             implicitContentHeight + topPadding + bottomPadding)

    Accessible.role: root.interactive ? Accessible.Button : Accessible.StaticText
    Accessible.name: root.label
    Accessible.description: root.value + (root.caption.length > 0 ? ". " + root.caption : "")

    background: Rectangle {
        id: bg
        color: d.surfaceColor
        border.color: root.borderColor
        border.width: root.borderColor.a > 0 ? 1 : 0
        radius: root.radius
        Behavior on color {
            enabled: root.interactive
            ColorAnimation { duration: 120 }
        }
    }

    contentItem: ColumnLayout {
        z: 1
        spacing: Theme.spacing.small

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.small
            visible: root.label.length > 0 || root.labelTrailing.length > 0

            LogosText {
                id: labelText
                Layout.fillWidth: true
                text: root.label
                color: Theme.palette.textSecondary
                font.pixelSize: Theme.typography.secondaryText
                elide: Text.ElideRight
            }

            LogosIcon {
                id: severityIcon
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                visible: d.hasSeverity
                source: d.iconSource
                color: d.accent
                brightness: 1.0
            }

            Row {
                id: labelSlot
                Layout.alignment: Qt.AlignVCenter
                visible: root.labelTrailing.length > 0
                spacing: Theme.spacing.tiny
                children: root.labelTrailing
            }
        }

        LogosText {
            id: valueText
            Layout.fillWidth: true
            text: root.value
            color: d.accent
            font.pixelSize: Theme.typography.panelTitleText
            font.weight: Theme.typography.weightBold
            elide: Text.ElideRight
        }

        // The row is kept even when the caption is empty: collapsing it would
        // make a captionless card shorter and throw a grid of cards out of
        // rhythm. An empty LogosText still occupies its line box.
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.small

            LogosText {
                id: captionText
                // Grows to fit its text but no further, so the slot sits
                // directly beside the caption rather than being flung out to
                // the card's edge — and still shrinks and elides when the card
                // is too narrow for both.
                Layout.fillWidth: true
                Layout.maximumWidth: implicitWidth
                text: root.caption
                color: Theme.palette.textTertiary
                font.pixelSize: Theme.typography.secondaryText
                elide: Text.ElideRight
            }

            Row {
                id: captionSlot
                Layout.alignment: Qt.AlignVCenter
                visible: root.captionTrailing.length > 0
                spacing: Theme.spacing.tiny
                children: root.captionTrailing
            }

            Item { Layout.fillWidth: true }
        }
    }

    SequentialAnimation {
        id: flashAnimation
        ColorAnimation {
            target: valueText; property: "color"
            to: root.flashColor
            duration: d.riseMs; easing.type: Easing.OutQuad
        }
        ColorAnimation {
            target: valueText; property: "color"
            to: d.accent
            duration: d.settleMs; easing.type: Easing.InOutQuad
        }
    }

    Binding {
        target: valueText
        property: "color"
        value: d.accent
        when: !flashAnimation.running
        restoreMode: Binding.RestoreNone
    }

    onValueChanged: {
        if (!d.seenValue) {
            d.seenValue = true
            return
        }
        if (root.flashOnChange)
            flashAnimation.restart()
    }
}
