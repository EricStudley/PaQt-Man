import QtQuick 2.13

import "qrc:///js/paQtmanJS.js" as Logic

Item {
    id: ghost

    Column {
        width: parent.width
        height: ghostTop.height + ghostBottom.height
        anchors { centerIn: parent }

        Image {
            id: ghostTop
            width: parent.width - 10
            anchors { horizontalCenter: parent.horizontalCenter }
            source: "qrc:///images/ghost" + role_style + "top" + role_direction
            fillMode: Image.PreserveAspectFit
        }

        Image {
            id: ghostBottom
            width: parent.width - 10
            anchors { horizontalCenter: parent.horizontalCenter }
            source: "qrc:///images/ghost" + role_style + "bottom" + (flip ? "1" : "0")
            fillMode: Image.PreserveAspectFit

            property bool flip: false

            Timer {
                running: role_moving
                repeat: true
                interval: object.speed / 4
                onTriggered: parent.flip = !parent.flip
            }
        }
    }
}
