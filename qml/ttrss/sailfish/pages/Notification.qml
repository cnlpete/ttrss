/*
Copyright (C) 2013, 2014 Martin Grimme <martin.grimme _AT_ gmail.com>
Copyright (C) 2013 Jolla Ltd.
Contact: Thomas Perl <thomas.perl@jollamobile.com>
All rights reserved.
You may use this file under the terms of BSD license as follows:
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of the Jolla Ltd nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
//Copyright Hauke Schade, 2012-2014
//
// Originally from the Tidings-project: https://github.com/pycage/tidings
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
