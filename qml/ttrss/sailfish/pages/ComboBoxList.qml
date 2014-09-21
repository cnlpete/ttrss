import QtQuick 2.0
import Sailfish.Silica 1.0


ComboBox {
    property int initialValue
    property alias model: repeater.model
    property bool withTimer: true

    function getInitialValue() {
        for (var i = 0; i < model.count; i++) {
            if (repeater.model.get(i).value == initialValue) {
                box.currentIndex = i
                break
            }
        }
    }

    function startTimer() {
        timer.start()
    }

    Component.onCompleted: {
        if (withTimer)
            timer.start()
    }

    id: box
    menu: ContextMenu {
          Repeater {
               id: repeater
               MenuItem {
                   text: model.name
               }
          }
    }

    Timer {
        id: timer
        interval: 500
        repeat: false
        triggeredOnStart: false
        onTriggered: getInitialValue()
    }
}
