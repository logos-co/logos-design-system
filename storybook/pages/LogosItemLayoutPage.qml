import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Icons
import Logos.Controls
import Logos.Layouts

// Catalog page for LogosItemLayout: one line of an item that may become two,
// by what fits.
Rectangle {
    id: page

    property string figmaUrl: ""
    property bool designed: false

    color: Theme.palette.background
    implicitHeight: column.implicitHeight + 2 * Theme.spacing.xxlarge

    component Section: ColumnLayout {
        property alias title: sectionTitle.text
        Layout.fillWidth: true
        spacing: Theme.spacing.medium
        LogosText {
            id: sectionTitle
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            font.pixelSize: Theme.typography.primaryText
            font.weight: Theme.typography.weightBold
        }
        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.palette.borderHairline }
    }

    // A part of the anatomy: a box in its role's colour, named after the role.
    component Part: Rectangle {
        id: part
        property alias label: partLabel.text
        property color tint: Theme.palette.primary
        implicitWidth: partLabel.implicitWidth + 2 * Theme.spacing.medium
        implicitHeight: Theme.size.controlLarge
        radius: Theme.spacing.radiusMedium
        color: Theme.colors.getColor(tint, 0.15)
        border.color: tint
        border.width: Theme.size.borderWidth
        LogosText {
            id: partLabel
            anchors.fill: parent
            anchors.leftMargin: Theme.spacing.small
            anchors.rightMargin: Theme.spacing.small
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            font.pixelSize: Theme.typography.secondaryText
            font.weight: Theme.typography.weightMedium
            color: part.tint
        }
    }

    // One line of the legend: a part, and what it does.
    component Role: LogosItemLayout {
        property alias name: rolePart.label
        property alias tint: rolePart.tint
        property alias text: roleText.text
        leading: Part { id: rolePart; implicitWidth: Theme.layouts.itemLayout.minimumContentWidth }
        LogosText {
            id: roleText
            wrapMode: Text.Wrap
            font.pixelSize: Theme.typography.secondaryText
            color: Theme.palette.textSecondary
        }
    }

    // A publisher: its key under its name when they don't fit side by side.
    component Publisher: LogosItemLayout {
        leading: LogosTile { label: "Other publisher"; tileSize: 32; interactive: false }
        ColumnLayout {
            spacing: 0
            LogosText {
                Layout.fillWidth: true
                text: "Other publisher"
                font.weight: Theme.typography.weightMedium
                elide: Text.ElideRight
            }
            LogosText {
                Layout.fillWidth: true
                text: "https://other.example · trusted since 2 Nov 2026"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
                elide: Text.ElideRight
            }
        }
        meta: [
            LogosText {
                Layout.fillWidth: true
                text: "AE21 6C2E F524 7A37"
                font.family: Theme.typography.mono
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
                wrapMode: Text.Wrap
            },
            LogosCopyButton { value: "did:jwk:other" }
        ]
        trailing: LogosIconButton { iconSource: LogosIcons.trash; flat: true }
    }

    // A header: its button under the title when they don't fit side by side.
    component Header: LogosItemLayout {
        ColumnLayout {
            spacing: Theme.spacing.tiny
            LogosText {
                Layout.fillWidth: true
                text: "Package Repositories"
                font.pixelSize: Theme.typography.panelTitleText
                wrapMode: Text.Wrap
            }
            LogosText {
                Layout.fillWidth: true
                text: "The catalog merges the built-in repository with any you add here."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
                wrapMode: Text.Wrap
            }
        }
        meta: LogosButton { text: "Refresh" }
    }

    // A field and its button: under it, the button takes the whole line.
    component FieldAndButton: LogosItemLayout {
        minimumContentWidth: 200
        LogosTextField { placeholderText: "https://example.com/logos-repo.json" }
        meta: LogosButton { Layout.fillWidth: true; text: "Add" }
    }

    // Badges wrap onto as many lines as they need.
    component Badges: LogosItemLayout {
        LogosText {
            text: "Community"
            font.weight: Theme.typography.weightMedium
            elide: Text.ElideRight
        }
        meta: [
            LogosBadge { text: "Default" },
            LogosBadge { text: "Disabled" },
            LogosBadge { text: "Name reused" },
            LogosBadge { text: "Unreachable" }
        ]
        trailing: LogosSwitch { checked: true }
    }

    component Examples: ColumnLayout {
        spacing: Theme.spacing.xlarge
        Publisher { Layout.fillWidth: true }
        Header { Layout.fillWidth: true }
        FieldAndButton { Layout.fillWidth: true }
        Badges { Layout.fillWidth: true }
    }

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xxlarge

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.tiny
            LogosText {
                text: "LogosItemLayout"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
            }
            LogosText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: "One line of an item, such as a list row, a header or a field and its button, that may become two. Public API: leading, content (default), meta, trailing, minimumContentWidth, spacing, wrapped. It arranges only and measures what fits, never the width class: meta sits beside the content while the content keeps minimumContentWidth (120), otherwise under it to the end of the item, where one with Layout.fillWidth takes the room left and those that don't fit wrap. Leading and trailing stay at the ends. Drag the slider."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
            }
        }

        Section {
            title: "Anatomy: " + (anatomy.wrapped ? "meta under the content" : "one line") + " at "
                   + Math.round(anatomy.width) + " px, content keeping " + Math.round(anatomy.minimumContentWidth)

            LogosItemLayout {
                Layout.fillWidth: true
                Layout.maximumWidth: 480
                leading: LogosText {
                    Layout.preferredWidth: Theme.layouts.itemLayout.minimumContentWidth
                    text: "Width"
                    font.pixelSize: Theme.typography.secondaryText
                }
                LogosSlider {
                    id: anatomyWidth
                    from: 200
                    to: 900
                    value: 640
                }
            }
            LogosItemLayout {
                Layout.fillWidth: true
                Layout.maximumWidth: 480
                leading: LogosText {
                    Layout.preferredWidth: Theme.layouts.itemLayout.minimumContentWidth
                    text: "minimumContentWidth"
                    font.pixelSize: Theme.typography.secondaryText
                    elide: Text.ElideRight
                }
                LogosSlider {
                    id: anatomyMinimum
                    from: 40
                    to: 400
                    value: Theme.layouts.itemLayout.minimumContentWidth
                }
            }

            LogosItemLayout {
                id: anatomy
                Layout.fillWidth: true
                Layout.maximumWidth: anatomyWidth.value
                minimumContentWidth: anatomyMinimum.value
                leading: Part { label: "leading"; tint: Theme.palette.info }
                Part { label: "content"; tint: Theme.palette.primary }
                meta: [
                    Part { label: "meta"; tint: Theme.palette.warning },
                    // Fills, but starts a line of its own sooner than it squeezes.
                    Part {
                        Layout.fillWidth: true
                        Layout.minimumWidth: implicitWidth
                        label: "meta, fills"
                        tint: Theme.palette.warning
                    }
                ]
                trailing: Part { label: "trailing"; tint: Theme.palette.success }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacing.medium
                spacing: Theme.spacing.small
                Role {
                    Layout.fillWidth: true
                    name: "leading"
                    tint: Theme.palette.info
                    text: "At the start, at its own size: an icon, a tile, a radio. Once meta is under the content, at the top."
                }
                Role {
                    Layout.fillWidth: true
                    name: "content"
                    tint: Theme.palette.primary
                    text: "What the line is about, the default property. It takes the room left, so its text can elide or wrap there."
                }
                Role {
                    Layout.fillWidth: true
                    name: "meta"
                    tint: Theme.palette.warning
                    text: "Beside the content while the content keeps minimumContentWidth; otherwise on a line under it that runs to the end, under trailing too. There, one with Layout.fillWidth takes the room left, and those that don't fit start another line."
                }
                Role {
                    Layout.fillWidth: true
                    name: "trailing"
                    tint: Theme.palette.success
                    text: "At the end, at its own size, always on the first line: actions such as delete, a switch."
                }
            }
        }

        Section {
            title: "Try it: " + Math.round(tryIt.width) + " px"
            LogosSlider {
                id: widthSlider
                Layout.fillWidth: true
                Layout.maximumWidth: 400
                from: 200
                to: 900
                value: 420
            }
            Examples {
                id: tryIt
                Layout.fillWidth: true
                Layout.maximumWidth: widthSlider.value
            }
        }

        Section {
            title: "A phone, " + Math.round(phone.width) + " px"
            Examples { id: phone; Layout.fillWidth: true; Layout.maximumWidth: 360 }
        }

        Section {
            title: "A desktop, " + Math.round(desktop.width) + " px"
            Examples { id: desktop; Layout.fillWidth: true; Layout.maximumWidth: 900 }
        }

        Item { Layout.fillHeight: true }
    }
}
