import QtQuick 2.13

Item {
    enabled: visible
    visible: opacity > 0.01
    opacity: 0
    anchors { fill: parent }
    implicitHeight: loader.item ? loader.item.implicitHeight : 0
    implicitWidth:  loader.item ? loader.item.implicitWidth : 0

    property variant source
    property var sourceSplit: source.toString().split('/')
    property string sourceFile: sourceSplit[sourceSplit.length - 1]
    property string startTime

    onVisibleChanged: {
        if (visible && loader.item === null) {
            console.log("Loading window:",sourceFile)
            timer.start()
            startTime = new Date().valueOf()
            loader.source = source
            loader.asynchronous = false
        }
        else {
            if(loader.source != "") {
                console.log("Unloading window:", sourceFile)
                loader.source = ""
            }
        }
    }

    Behavior on opacity { NumberAnimation { duration: 500 } }

    Loader {
        id: loader
        anchors { fill: parent }

        onLoaded: {
            timer.stop()
            var stopTime = new Date().valueOf()
            console.log("Finished loading:", sourceFile + ". Time:", (stopTime - startTime), "ms.")
        }

        Timer {
            id: timer
            interval: 5000
            running: false

            onTriggered: {
                if (loader.item === null) {
                    loader.source = source
                    loader.asynchronous = true
                }
            }
        }
    }
}
