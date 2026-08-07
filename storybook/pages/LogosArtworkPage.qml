import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

Rectangle {
    id: page

    property string figmaUrl: ""

    color: Theme.palette.background

    // Stand-ins for real package artwork — the storybook has no .lgx to pull
    // icons from. Both are 256x256 RGBA PNGs matching the packaging contract:
    // one fully opaque, one with a transparent background, so the backplate
    // behaviour below is demonstrable rather than described.
    // Qt.resolvedUrl() is required, not decoration. A bare relative string
    // survives as a relative URL through the property indirection and is only
    // resolved when it reaches Image.source *inside* LogosArtwork.qml — i.e.
    // against qrc:/qt/qml/Logos/Controls/, where these files do not exist.
    // Resolving here pins it to this page's own on-disk location.
    readonly property url opaqueSample: Qt.resolvedUrl("sample-app-icon.png")
    readonly property url transparentSample: Qt.resolvedUrl("sample-app-icon-transparent.png")

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xxlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny

            LogosText {
                text: "LogosArtwork"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: source, radius, brightness"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            LogosText {
                text: "A package's own artwork, rendered full-bleed and in full colour. "
                    + "Unlike LogosIcon — which colorizes its source to a single-colour "
                    + "silhouette for chrome glyphs — this preserves the source's colours. "
                    + "Packages ship an exactly 256x256 PNG; PreserveAspectCrop guarantees "
                    + "the tile is filled even if an off-spec image slips through."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        // ── Sizes ────────────────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Sizes"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.palette.borderHairline
            }
            RowLayout {
                spacing: Theme.spacing.large

                Repeater {
                    model: [24, 40, 64, 96]
                    delegate: ColumnLayout {
                        spacing: Theme.spacing.tiny
                        Rectangle {
                            width: modelData; height: modelData
                            radius: Theme.spacing.radiusMedium
                            color: Theme.palette.surfaceRaised
                            LogosArtwork {
                                anchors.fill: parent
                                radius: Theme.spacing.radiusMedium
                                source: page.opaqueSample
                            }
                        }
                        LogosText {
                            text: modelData + "px"
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textTertiary
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }

        // ── Backplate behaviour ──────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Backplate"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.palette.borderHairline
            }
            LogosText {
                text: "Transparency is never detected. The caller always paints a grey "
                    + "plate underneath; an opaque icon covers it, a transparent one "
                    + "shows it through. No metadata, no branch."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            RowLayout {
                spacing: Theme.spacing.large

                Repeater {
                    model: [
                        { src: page.opaqueSample,      label: "opaque — plate hidden" },
                        { src: page.transparentSample, label: "transparent — plate shows" }
                    ]
                    delegate: ColumnLayout {
                        spacing: Theme.spacing.tiny
                        Rectangle {
                            width: 64; height: 64
                            radius: Theme.spacing.radiusMedium
                            color: Theme.palette.surfaceRaised
                            LogosArtwork {
                                anchors.fill: parent
                                radius: Theme.spacing.radiusMedium
                                source: modelData.src
                            }
                        }
                        LogosText {
                            text: modelData.label
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textTertiary
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }

        // ── Try it ───────────────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Try it"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.palette.borderHairline
            }

            RowLayout {
                spacing: Theme.spacing.xxlarge

                Rectangle {
                    width: 96; height: 96
                    radius: radiusSlider.value
                    color: Theme.palette.surfaceRaised
                    border.width: 1
                    border.color: Theme.palette.borderSubtle

                    LogosArtwork {
                        id: liveIcon
                        anchors.fill: parent
                        source: page.transparentSample
                        radius: radiusSlider.value
                        brightness: brightnessSlider.value
                    }
                }

                ColumnLayout {
                    spacing: Theme.spacing.medium

                    RowLayout {
                        spacing: Theme.spacing.medium
                        LogosText {
                            text: "radius"
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textSecondary
                            Layout.preferredWidth: 80
                        }
                        LogosSlider {
                            id: radiusSlider
                            from: 0; to: 48; value: Theme.spacing.radiusMedium
                            Layout.preferredWidth: 200
                        }
                        LogosText {
                            text: radiusSlider.value.toFixed(0)
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textTertiary
                        }
                    }

                    RowLayout {
                        spacing: Theme.spacing.medium
                        LogosText {
                            text: "brightness"
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textSecondary
                            Layout.preferredWidth: 80
                        }
                        LogosSlider {
                            id: brightnessSlider
                            from: 0; to: 0.4; value: 0
                            Layout.preferredWidth: 200
                        }
                        LogosText {
                            text: brightnessSlider.value.toFixed(2)
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textTertiary
                        }
                    }

                    LogosText {
                        text: "brightness ~0.08 is the hover lift used by AppTile."
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
