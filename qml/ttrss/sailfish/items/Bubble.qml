//Copyright Hauke Schade, 2012-2013
//
// Originally made by Buschtrommel
//
//This file is part of TTRss.
//
//TTRss is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the
//Free Software Foundation, either version 2 of the License, or (at your option) any later version.
//TTRss is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with TTRss (on a Maemo/Meego system there is a copy
//in /usr/share/common-licenses. If not, see http://www.gnu.org/licenses/.

import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: bubble

    property int value: 0
    property alias color: bubbleValue.color

    function getBubbleWidth() {
        var absVal = Math.abs(bubble.value)
        if (absVal < 10)
            return 26
        else if (absVal < 100)
            return 35
        else if (absVal < 1000)
            return 48
        else
            return 58
    }

    width: bubble.getBubbleWidth()
    height: 32

    onValueChanged: {
        bubble.width = bubble.getBubbleWidth()
    }

    Rectangle {
        id: backgroundRect
        width: parent.width
        height: parent.height
        color: Theme.secondaryColor
        border.color: Theme.primaryColor
        border.width: 1
        radius: 10
        opacity: 0.3
    }

    Text {
        id: bubbleValue
        anchors.centerIn: backgroundRect
        text: bubble.value
        font.pixelSize: Theme.fontSizeExtraSmall
        opacity: 1
        color: Theme.primaryColor
    }
}
