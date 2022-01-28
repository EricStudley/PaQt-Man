import QtQuick 2.13
import QtWebSockets 1.0
import QtGraphicalEffects 1.0

import "qrc:///js/paQtmanJS.js" as Logic

import Enums 1.0

Item {
    focus: true

    Keys.onUpPressed: socket.sendTextMessage("{\"command\":\"0\"}")
    Keys.onRightPressed: socket.sendTextMessage("{\"command\":\"1\"}")
    Keys.onDownPressed: socket.sendTextMessage("{\"command\":\"2\"}")
    Keys.onLeftPressed: socket.sendTextMessage("{\"command\":\"3\"}")

    Component.onCompleted: forceActiveFocus()

    MouseArea {
        z: 10000
        anchors { fill: parent }

        onClicked: forceActiveFocus()
    }

    WebSocket {
        id: socket
        url: "ws://localhost:9001"
        active: true

        onStatusChanged: {
            if (socket.status === WebSocket.Open) {
                console.log("Client connected.")
                socket.sendTextMessage("{\"command\":\"join\"}")
            }
        }

        onTextMessageReceived: appManager.processMessage(JSON.parse(message))
    }

    Item {
        id: root
        width: gameHeightWidth
        height: gameHeightWidth
        anchors { centerIn: parent }

        Map {
            anchors { fill: parent }
            model: mapModel
        }

        Repeater {
            model: displayModel

            Object { }
        }
    }
}
