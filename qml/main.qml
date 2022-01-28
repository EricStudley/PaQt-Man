import QtQuick 2.13
import QtQuick.Window 2.2

import "qrc:///js/paQtmanJS.js" as Logic

Window {
    id: rootWindow
    visible: true
    color: "transparent"

    // Fullscreen mode
//    visibility: Window.FullScreen

    // Windowed mode
    width: gameHeightWidth + borderWidth
    height: gameHeightWidth + borderHeight
    flags: Qt.SplashScreen | Qt.WindowStaysOnTopHint

    property int borderHeight: interfaceBorder.border.top + interfaceBorder.border.bottom
    property int borderWidth: interfaceBorder.border.bottom * 2
    property int gameHeightWidth: 750
//    property int gameHeightWidth: Screen.width > Screen.height ? Screen.height - borderHeight
//                                                               : Screen.width - borderWidth

    Item {
        id: rootItem
        width: parent.width - borderWidth
        height: parent.height - borderHeight
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: interfaceBorder.border.bottom }

        state: "Gameplay"
        states: [
            State {
                name: "Welcome"
                PropertyChanges { target: welcomeWindow; opacity: 1 }
            },
            State {
                name: "Matchmaking"
                PropertyChanges { target: matchmakingWindow; opacity: 1 }
            },
            State {
                name: "Gameplay"
                PropertyChanges { target: gameplayWindow; opacity: 1 }
            },
            State {
                name: "Results"
                PropertyChanges { target: resultsWindow; opacity: 1 }
            },
            State {
                name: "Highscores"
                PropertyChanges { target: highscoresWindow; opacity: 1 }
            },
            State {
                name: "Settings"
                PropertyChanges { target: settingsWindow; opacity: 1 }
            }
        ]

        Image {
            id: background
            anchors { fill: parent }
            fillMode: Image.Tile
            source: "qrc:/images/interface_background"
        }

        WindowLoader {
            id: welcomeWindow
            source: "Welcome.qml"
        }

        WindowLoader {
            id: matchmakingWindow
            source: "Matchmaking.qml"
        }

        WindowLoader {
            id: gameplayWindow
            source: "Gameplay.qml"
        }

        WindowLoader {
            id: resultsWindow
            source: "Results.qml"
        }

        WindowLoader {
            id: highscoresWindow
            source: "Highscores.qml"
        }

        WindowLoader {
            id: settingsWindow
            source: "Settings.qml"
        }
    }

    Interface {
        id: interfaceBorder
        anchors { fill: parent }

        root: rootWindow
    }
}
