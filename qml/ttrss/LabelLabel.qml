//Copyright Hauke Schade, 2012-2013
//
//This file is part of TTRss.
//
//TTRss is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the
//Free Software Foundation, either version 2 of the License, or (at your option) any later version.
//TTRss is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with TTRss (on a Maemo/Meego system there is a copy
//in /usr/share/common-licenses. If not, see http://www.gnu.org/licenses/.

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
