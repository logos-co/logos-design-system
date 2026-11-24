import QtQuick

import Logos.Theme

import "reference"

// The reference app, a wallet, filling the page as it would an app's tab.
// Preview shows it at a phone's and a tablet's width.
Rectangle {
    property string figmaUrl: ""
    property bool designed: false

    color: Theme.palette.background

    WalletApp { anchors.fill: parent }
}
