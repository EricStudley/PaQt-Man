import QtQuick 2.13

BorderImage {
    horizontalTileMode: BorderImage.Repeat
    verticalTileMode: BorderImage.Repeat
    border { left: 9; right: 12; top: 16; bottom: 4 }
    source: "qrc:///images/interface_border_unlocked"

    property var root

    Image {
        id: closeIcon
        visible: false
        z: 150
        width: sourceSize.width
        height: sourceSize.height
        anchors { right: parent.right; top: parent.top }
        source: "qrc:///images/close_icon"
    }

    MouseArea {
        z: 150
        width: closeIcon.width
        height: closeIcon.height
        anchors { right: parent.right; top: parent.top }
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true

        onEntered: closeIcon.visible = true
        onExited: closeIcon.visible = false
        onClicked: Qt.quit()
    }

    MouseArea {
        z: 100
        width: parent.width
        height: parent.border.top
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
        acceptedButtons: Qt.LeftButton

        property real lastMouseX: 0
        property real lastMouseY: 0

        onMouseXChanged: root.x += (mouseX - lastMouseX)
        onMouseYChanged: root.y += (mouseY - lastMouseY)
        onPressed: {
            if (mouse.button === Qt.LeftButton) {
                parent.forceActiveFocus()
                lastMouseX = mouseX
                lastMouseY = mouseY
            }
        }
    }
}
