import QtQuick 2.0
import Sailfish.Silica 1.0


ComboBox {
    property string initialValue
    property alias model: repeater.model

    function getInitialValue() {
        var found = false;
        var i = 0;
        while ((!found) && (i < model.count)) {
            if (repeater.model.get(i).value == initialValue) {
                box.currentIndex = i;
                found = true;
            }
            i++;
        }
    }

    Component.onCompleted: timer.start()

    id: box
    menu: ContextMenu {
          Repeater {
               id: repeater
               MenuItem { text: model.name }
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
