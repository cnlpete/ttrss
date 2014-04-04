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
import com.nokia.meego 1.1

Item {
    id: root

    property bool large: false
    property int amount: 0
    property color color: constant.colorListItemActive

    implicitWidth: internal.getBubbleWidth()
    implicitHeight: root.large ? constant.fontSizeSmall + constant.paddingMedium + constant.paddingMedium :
                                 constant.fontSizeXSmall + constant.paddingMedium + constant.paddingMedium

    BorderImage {
        source: "image://theme/meegotouch-countbubble-background"
        anchors.fill: parent
        border {
            left: 10
            top: 10
            right: 10
            bottom: 10
        }
    }

    Label {
        id: text
        height: parent.height
        y: 1
        opacity: 0.8
        anchors.horizontalCenter: parent.horizontalCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: root.large ? constant.fontSizeMedium : constant.fontSizeXSmall
        color: root.color

        text: root.amount
    }

    QtObject {
        id: internal

        function getBubbleWidth() {
            if (large)
                return text.paintedWidth + constant.paddingLarge + constant.paddingLarge
            else
                return text.paintedWidth + constant.paddingSmall + constant.paddingSmall
        }
    }
}
