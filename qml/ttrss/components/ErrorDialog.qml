//Copyright Hauke Schade, 2012-2014
//
//This file is part of TTRss.
//
//TTRss is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the
//Free Software Foundation, either version 2 of the License, or (at your option) any later version.
//TTRss is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with TTRss (on a Maemo/Meego system there is a copy
//in /usr/share/common-licenses. If not, see http://www.gnu.org/licenses/.

import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1

Dialog {
    id: errorDialog

    property string text

    title: Rectangle {
        id: titleField
        height: 2
        width: parent.width
        color: "red"
    }

    content:Item {
        id: errorDialogContents
        height: 50
        width: parent.width
        Text {
            id: errorDialogText
            font.pixelSize: MyTheme.fontSizeSmall
            anchors.centerIn: parent
            color: "white"
            text: errorDialog.text
        }
    }

    buttons: ButtonRow {
        style: ButtonStyle { }
        anchors.horizontalCenter: parent.horizontalCenter
        Button { text: qsTr("OK"); onClicked: errorDialog.accept() }
    }
}
