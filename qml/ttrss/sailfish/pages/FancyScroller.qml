/* Copyright 2013-2014 by Mike7b4 <mike@7b4.se>
*
* This file was apapted from Jolla2Gether
* Copyright 2013-2014 by Mike7b4 <mike@7b4.se>
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    // TODO make this work with SilicaFlickable aswell
    property SilicaListView flickable: parent
    property int threshold: 1500
    property bool _activeUp
    property bool _activeDown

    BackgroundItem {
        visible: opacity > 0
        y: 0
        width: flickable.width
        height: Theme.itemSizeLarge
        highlighted: pressed
        opacity: _activeUp ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
        }

        Rectangle {
            width: 64
            height: 64
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingSmall
            anchors.verticalCenter: parent.verticalCenter
            radius: 75
            color: "transparent"
            opacity: 1
            border.width: 1
            border.color: Theme.primaryColor
            Image {
                id: upImg
                anchors.centerIn: parent
                source: "image://theme/icon-l-up"
            }
        }

        onPressed: {
            flickable.cancelFlick();
            flickable.scrollToTop();
        }
    }

    BackgroundItem {
        visible: opacity > 0
        y: flickable.height - height
        width: flickable.width
        height: Theme.itemSizeLarge
        highlighted: pressed
        opacity: _activeDown ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
        }

        Rectangle {
            width: 64
            height: 64
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingSmall
            anchors.verticalCenter: parent.verticalCenter
            radius: 75
            color: "transparent"
            opacity: 1
            border.width: 1
            border.color: Theme.primaryColor
            Image {
                anchors.centerIn: parent
                source: "image://theme/icon-l-down"
            }
        }

        onPressed: {
            flickable.cancelFlick();
            flickable.scrollToBottom();
        }
    }

    Connections {
        target: flickable

        onVerticalVelocityChanged: {
            //console.log("velocity: " + target.verticalVelocity);

            if (target.verticalVelocity < 0) {
                _activeDown = false;
            }
            else {
                _activeUp = false;
            }

            if (target.verticalVelocity < -threshold &&
                target.contentHeight > 3 * target.height) {
                _activeUp = true;
                _activeDown = false;
            }
            else if (target.verticalVelocity > threshold &&
                     target.contentHeight > 3 * target.height) {
                _activeUp = false;
                _activeDown = true;
            }
            else if (Math.abs(target.verticalVelocity) < 10) {
                _activeUp = false;
                _activeDown = false;
            }
        }
    }
}
