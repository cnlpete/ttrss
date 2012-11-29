//Copyright Hauke Schade, 2012
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

Item{
    id: root

    property string text

    height: constant.headerHeight
    width: parent.width
    visible: text !== ""

    Image{
        id: background
        anchors.fill: parent
        source: "image://theme/color15-meegotouch-view-header-fixed"
        sourceSize.width: parent.width
        sourceSize.height: parent.height
    }

    Text{
        id: mainText
        anchors{
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
            margins: constant.paddingXLarge
        }
        font.pixelSize: constant.fontSizeXLarge
        color: "white"
        elide: Text.ElideRight
        text: root.text
    }
}
