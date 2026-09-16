import QtQuick

// One stage in a LogosStageLane.
//
// Public API:
//     label       the stage name, shown when it is pending, active or done
//     busyLabel   shown instead of `label` while this stage is the busy one,
//                 for the in-progress verb ("Online" becoming "Syncing…").
//                 Empty falls back to `label`
//     enabled     if false, the stage is never clickable even when the lane is
//                 interactive. Has no effect on how it is drawn
//
// Declared as a child of the lane, the same way LogosTableColumn is declared
// inside LogosTable:
//
//     LogosStageLane {
//         currentIndex: 1
//         busy: true
//         stages: [
//             LogosStage { label: qsTr("Started") },
//             LogosStage { label: qsTr("Online"); busyLabel: qsTr("Syncing…") }
//         ]
//     }
QtObject {
    id: stage

    property string label: ""
    property string busyLabel: ""
    property bool enabled: true
}
