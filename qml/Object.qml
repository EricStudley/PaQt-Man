import QtQuick 2.13

import "qrc:///js/paQtmanJS.js" as Logic

import Enums 1.0

Item {
    id: object
    x: width * role_position.x
    y: height * role_position.y
    width: root.width / Logic.mapSize
    height: root.height / Logic.mapSize
    rotation: role_type === DisplayType.Player ? role_direction * 90 : 0

    property int speed: role_type === DisplayType.Player ? Logic.playerSpeedDefault : Logic.ghostSpeedDefault

    Behavior on x { enabled: object.speed; PropertyAnimation { duration: object.speed } }

    Behavior on y { enabled: object.speed; PropertyAnimation { duration: object.speed } }

    Loader {
        id: loader
        active: index > -1 && role_type !== DisplayType.Unknown
        anchors { fill: parent }

        states: [
            State {
                when: role_type === DisplayType.Item
                PropertyChanges { target: loader; source: "Item.qml" }
            },
            State {
                when: role_type === DisplayType.Player
                PropertyChanges { target: loader; source: "Player.qml" }
            },
            State {
                when: role_type === DisplayType.Ghost
                PropertyChanges { target: loader; source: "Ghost.qml" }
            }
        ]
    }
}
