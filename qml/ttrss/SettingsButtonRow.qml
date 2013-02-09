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

import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: root

    property string text: ""
    property variant buttonsText: []
    property int checkedButtonIndex: 0

    signal buttonClicked(int index)

    width: parent.width
    height: settingText.paintedHeight + buttonRow.height + buttonRow.anchors.topMargin

    Label {
        id: settingText
        anchors {
            left: parent.left
            top: parent.top
            leftMargin: constant.paddingMedium
        }
        font.pixelSize: constant.fontSizeMedium
        text: root.text
    }

    ButtonRow {
        id: buttonRow
        anchors {
            top: settingText.bottom
            left: parent.left
            right: parent.right
            margins: constant.paddingMedium
        }
        checkedButton: buttonRepeater.itemAt(root.checkedButtonIndex)
        onVisibleChanged: checkedButton = buttonRepeater.itemAt(root.checkedButtonIndex)

        Repeater {
            id: buttonRepeater
            model: root.buttonsText

            Button {
                text: modelData
                onClicked: root.buttonClicked(index)
            }
        }
    }
}
