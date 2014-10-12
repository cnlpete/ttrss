/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2014  Hauke Schade
 *
 * This file was adapted from Tidings
 * (https://github.com/pycage/tidings).
 * Copyright (C) 2013–2014 Martin Grimme <martin.grimme _AT_ gmail.com>
 *
 * TTRss is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * TTRss is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with TTRss; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA or see
 * http://www.gnu.org/licenses/.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    width: parent.width
    height: Theme.itemSizeSmall
    clip: true
    visible: box.y > -height

    function show(message)
    {
        label.text = message;
        box.y = 0;
        notificationTimer.restart();
    }

    Rectangle {
        id: box
        y: -width
        width: parent.width
        height: parent.height
        color: Theme.highlightBackgroundColor
        clip: true

        Behavior on y {
            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
        }

        Image {
            id: icon
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: Theme.paddingSmall
            width: height

            source: "image://theme/icon-lock-warning"
        }

        Label {
            id: label
            anchors.top: parent.top
            anchors.left: icon.right
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Theme.paddingSmall

            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.family: Theme.fontFamilyHeading
            font.pixelSize: Theme.fontSizeSmall
            color: "#000000"
            opacity: 0.7
        }
    }

    Timer {
        id: notificationTimer
        interval: 3000

        onTriggered: {
            box.y = -height;
        }
    }

    onClicked: {
        box.y = -height;
        notificationTimer.stop();
    }
}
