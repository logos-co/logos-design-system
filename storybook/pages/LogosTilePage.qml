import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

Rectangle {
    id: page

    property string figmaUrl: ""

    color: Theme.palette.background

    // Same fixtures the LogosArtwork page uses — see that page for why they
    // exist. Qt.resolvedUrl() is required: a bare relative string stays
    // unresolved through the property and is only resolved once it reaches
    // Image.source inside the control, i.e. against the control's own qrc
    // location, where these files do not exist.
    readonly property url opaqueSample: Qt.resolvedUrl("sample-app-icon.png")
    readonly property url transparentSample: Qt.resolvedUrl("sample-app-icon-transparent.png")

    property int clickCount: 0

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xxlarge
        spacing: Theme.spacing.xxlarge

        ColumnLayout {
            spacing: Theme.spacing.tiny

            LogosText {
                text: "LogosTile"
                font.pixelSize: Theme.typography.titleText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            LogosText {
                text: "Public API: label, source, fallbackColor, tileSize, radius, "
                    + "dimOpacity — signal clicked(), inherited from LogosAbstractButton"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textSecondary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            LogosText {
                text: "A square, clickable application tile. Self-contained: it owns "
                    + "hover/press tracking and keyboard activation, like LogosButton. "
                    + "Pressed wins over hovered. The plate is only visible where the "
                    + "icon is transparent and on the monogram tile, so the ring, icon "
                    + "brightness and scale carry the feedback for opaque artwork."
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        // ── States ───────────────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "States — hover and press these"
                font.pixelSize: Theme.typography.primaryText
                font.weight: Theme.typography.weightBold
                color: Theme.palette.text
            }
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.palette.borderHairline
            }
            LogosText {
                text: "idle → surfaceRaised / borderSubtle · hover → surfaceContrast / "
                    + "border, icon +0.08 · pressed → surfaceRecessed / borderStrong, "
                    + "icon −0.06, scale 0.96"
                font.pixelSize: Theme.typography.secondaryText
                color: Theme.palette.textTertiary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: Theme.spacing.xxlarge

                Repeater {
                    model: [
                        { label: "opaque artwork",      src: page.opaqueSample,      fb: Theme.palette.surfaceRaised },
                        { label: "transparent artwork", src: page.transparentSample, fb: Theme.palette.surfaceRaised },
                        { label: "monogram, theme grey", src: "",                    fb: Theme.palette.surfaceRaised },
                        { label: "monogram, caller colour", src: "",                 fb: "#3A4A6B" }
                    ]
                    delegate: ColumnLayout {
                        spacing: Theme.spacing.tiny
                        LogosTile {
                            Layout.alignment: Qt.AlignHCenter
                            label: "wallet_ui"
                            source: modelData.src
                            fallbackColor: modelData.fb
                            tileSize: 80
                            radius: Theme.spacing.radiusXlarge
                            onClicked: page.clickCount++
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

        // ── Disabled ─────────────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            LogosText {
                text: "Disabled and dimmed"
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

                LogosTile {
                    label: "wallet_ui"
                    source: page.opaqueSample
                    tileSize: 80
                    radius: Theme.spacing.radiusXlarge
                    enabled: false
                }
                LogosTile {
                    label: "wallet_ui"
                    source: page.opaqueSample
                    tileSize: 80
                    radius: Theme.spacing.radiusXlarge
                    dimOpacity: 0.55
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

                LogosTile {
                    id: liveTile
                    label: monogramField.text
                    source: artworkSwitch.checked ? page.opaqueSample : ""
                    fallbackColor: "#3A4A6B"
                    tileSize: sizeSlider.value
                    radius: radiusSlider.value
                    onClicked: page.clickCount++
                }

                ColumnLayout {
                    spacing: Theme.spacing.medium

                    RowLayout {
                        spacing: Theme.spacing.medium
                        LogosText {
                            text: "tileSize"; Layout.preferredWidth: 90
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textSecondary
                        }
                        LogosSlider {
                            id: sizeSlider
                            from: 32; to: 140; value: 80
                            Layout.preferredWidth: 200
                        }
                        LogosText {
                            text: sizeSlider.value.toFixed(0)
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textTertiary
                        }
                    }

                    RowLayout {
                        spacing: Theme.spacing.medium
                        LogosText {
                            text: "radius"; Layout.preferredWidth: 90
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textSecondary
                        }
                        LogosSlider {
                            id: radiusSlider
                            from: 0; to: 60; value: Theme.spacing.radiusXlarge
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
                            text: "has artwork"; Layout.preferredWidth: 90
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textSecondary
                        }
                        LogosSwitch { id: artworkSwitch; checked: true }
                    }


                    RowLayout {
                        spacing: Theme.spacing.medium
                        LogosText {
                            text: "monogram"; Layout.preferredWidth: 90
                            font.pixelSize: Theme.typography.secondaryText
                            color: Theme.palette.textSecondary
                        }
                        LogosTextField {
                            id: monogramField
                            text: "Storage"
                            Layout.preferredWidth: 200
                        }
                    }

                    LogosText {
                        text: "clicked() fired " + page.clickCount + " times — "
                            + "keyboard works too: Tab to focus, then Space or Enter."
                        font.pixelSize: Theme.typography.secondaryText
                        color: Theme.palette.textTertiary
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
