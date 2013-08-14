// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Rectangle {

    id: root
    property variant label

    width: text.width + constant.paddingSmall + constant.paddingSmall
    height: text.height + constant.paddingSmall
    color: root.label.bgcolor
    radius: constant.paddingSmall
    anchors.margins: constant.paddingSmall
    Text {
        anchors {
            verticalCenter: root.verticalCenter
            horizontalCenter: root.horizontalCenter
        }
        id: text
        text: root.label.text
        color: root.label.fgcolor
        font.pixelSize: constant.fontSizeXSmall
    }
    MouseArea {
        id: touchArea
        anchors.fill: parent
    }
}
