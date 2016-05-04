/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2016  Hauke Schade
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

import QtQuick 1.1
import com.nokia.meego 1.1

Item {
    id: root

    property bool large: false
    property int amount: 0

    property Style platformStyle: BubbleStyle { large: large }

    implicitWidth: internal.getBubbleWidth()
    implicitHeight: root.platformStyle.fontSize + root.platformStyle.padding + root.platformStyle.padding

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
        font.pixelSize: root.platformStyle.fontSize
        color: root.platformStyle.textColor

        text: root.amount
    }

    QtObject {
        id: internal

        function getBubbleWidth() {
            return text.paintedWidth + root.platformStyle.padding + root.platformStyle.padding
        }
    }
}
