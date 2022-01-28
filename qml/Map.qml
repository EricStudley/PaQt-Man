import QtQuick 2.13
import QtQuick.Particles 2.0

import "qrc:///js/paQtmanJS.js" as Logic

Repeater {

    Rectangle {
        id: mapTile
        x: width * (index % Logic.mapSize)
        y: height * Math.floor(index / Logic.mapSize)
        width: root.width / Logic.mapSize
        height: root.height / Logic.mapSize
        color: "transparent"

        property int wallSize: width * .1

        Item {
            id: coin
            visible: coinTile
            anchors { fill: parent }

            property bool coinTile: !role_type

            Rectangle {
                width: parent.width * .1
                height: parent.height * .1
                anchors { centerIn: parent }
                color: "yellow"
            }
        }

        Item {
            id: doubleOutsideWallTile
            visible: role_type > 0 && role_type < 5
            enabled: visible
            width: parent.width
            height: parent.height
            rotation: 90 * (role_type - 1)
            anchors { centerIn: parent }

            Rectangle {
                width: mapTile.wallSize
                height: mapTile.wallSize
                anchors { right: parent.right; bottom: parent.bottom }
                color: "#0080f8"
            }

            Rectangle {
                width: mapTile.wallSize * 2
                height: mapTile.wallSize
                anchors { right: parent.right; bottom: parent.bottom; bottomMargin: mapTile.wallSize * 2 }
                color: "#0080f8"
            }

            Rectangle {
                width: mapTile.wallSize
                height: mapTile.wallSize * 2
                anchors { right: parent.right; rightMargin: mapTile.wallSize * 2; bottom: parent.bottom }
                color: "#0080f8"
            }
        }

        Item {
            id: doubleWallTile
            visible: role_type > 4 && role_type < 9
            enabled: visible
            width: parent.width
            height: parent.height
            rotation: 90 * (role_type - 5)
            anchors { centerIn: parent }

            Rectangle {
                width: parent.width
                height: mapTile.wallSize
                anchors { horizontalCenter: parent.horizontalCenter; top: parent.top }
                color: "#0080f8"
            }

            Rectangle {
                width: parent.width
                height: mapTile.wallSize
                anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: mapTile.wallSize * 2 }
                color: "#0080f8"
            }
        }

        Item {
            id: doubleInsideCornerTile
            visible: role_type > 8 && role_type < 13
            enabled: visible
            width: parent.width
            height: parent.height
            rotation: 90 * (role_type - 9)
            anchors { centerIn: parent }

            Rectangle {
                color: "#0080f8"
                width: parent.width - mapTile.wallSize
                height: mapTile.wallSize
                anchors { right: parent.right; top: parent.top }
            }

            Rectangle {
                color: "#0080f8"
                height: parent.height - mapTile.wallSize
                width: mapTile.wallSize
                anchors { left: parent.left; bottom: parent.bottom }
            }

            Rectangle {
                color: "#0080f8"
                width: parent.width - (mapTile.wallSize * 2)
                height: mapTile.wallSize
                anchors { right: parent.right; top: parent.top; topMargin: (mapTile.wallSize * 2) }
            }

            Rectangle {
                color: "#0080f8"
                height: parent.height - (mapTile.wallSize * 2)
                width: mapTile.wallSize
                anchors { left: parent.left; leftMargin: (mapTile.wallSize * 2); bottom: parent.bottom }
            }
        }

        Item {
            id: singleSidesTile
            visible: role_type > 12 && role_type < 15
            enabled: visible
            width: parent.width
            height: parent.height
            rotation: 90 * (role_type - 13)
            anchors { centerIn: parent }

            Rectangle {
                color: "#0080f8"
                width: mapTile.wallSize
                height: mapTile.height
                anchors { left: parent.left; top: parent.top }
            }

            Rectangle {
                color: "#0080f8"
                width: mapTile.wallSize
                height: mapTile.height
                anchors { right: parent.right; top: parent.top }
            }
        }

        Item {
            id: singleInsideCornerTile
            visible: role_type > 14 && role_type < 19
            enabled: visible
            width: parent.width
            height: parent.height
            rotation: 90 * (role_type - 15)
            anchors { centerIn: parent }

            Rectangle {
                color: "#0080f8"
                width: parent.width - mapTile.wallSize
                height: mapTile.wallSize
                anchors { right: parent.right; top: parent.top }
            }

            Rectangle {
                color: "#0080f8"
                width: mapTile.wallSize
                height: parent.height - mapTile.wallSize
                anchors { left: parent.left; bottom: parent.bottom }
            }
        }

        Item {
            id: tripleCornerTile
            visible: role_type > 18 && role_type < 23
            enabled: visible
            width: parent.width
            height: parent.height
            rotation: 90 * (role_type - 19)
            anchors { centerIn: parent }

            Rectangle {
                color: "#0080f8"
                width: parent.width - (mapTile.wallSize * 2 )
                height: mapTile.wallSize
                anchors { horizontalCenter: parent.horizontalCenter; top: parent.top }
            }

            Rectangle {
                color: "#0080f8"
                width: mapTile.wallSize
                height: parent.height - mapTile.wallSize
                anchors { left: parent.left; bottom: parent.bottom }
            }

            Rectangle {
                color: "#0080f8"
                width: mapTile.wallSize
                height: parent.height - mapTile.wallSize
                anchors { right: parent.right; bottom: parent.bottom }
            }
        }

        Item {
            id: squareTile
            visible: role_type === 23
            enabled: visible
            width: parent.width
            height: parent.height
            rotation: 90 * (role_type - 19)
            anchors { centerIn: parent }

            Rectangle {
                color: "transparent"
                anchors { fill: parent; margins: mapTile.wallSize * 2 }
                border { color: "#0080f8"; width: mapTile.wallSize }
            }

            Rectangle {
                color: "#0080f8"
                width: parent.width - (mapTile.wallSize * 2 )
                height: mapTile.wallSize
                anchors { horizontalCenter: parent.horizontalCenter; top: parent.top }
            }

            Rectangle {
                color: "#0080f8"
                width: parent.width - (mapTile.wallSize * 2 )
                height: mapTile.wallSize
                anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom }
            }

            Rectangle {
                color: "#0080f8"
                height: parent.height - (mapTile.wallSize * 2 )
                width: mapTile.wallSize
                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            }

            Rectangle {
                color: "#0080f8"
                height: parent.height - (mapTile.wallSize * 2 )
                width: mapTile.wallSize
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            }
        }
    }
}
