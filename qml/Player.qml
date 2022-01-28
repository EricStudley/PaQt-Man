import QtQuick 2.13

import "qrc:///js/paQtmanJS.js" as Logic

Item {
    id: player

    property bool openImage: false

    Image {
        id: playerImage
        height: parent.height * .75
        source: "qrc:///images/player" + (openImage ? "1" : "0") + "type" + role_style
        anchors { centerIn: parent }
        fillMode: Image.PreserveAspectFit

        Timer {
            running: role_moving
            repeat: true
            interval: Logic.playerSpeedDefault / 2

            onTriggered: openImage = !openImage

            onRunningChanged: {
                if (!running) {
                    openImage = false
                }
            }
        }
    }
}
