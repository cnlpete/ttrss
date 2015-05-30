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

import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    id: root

    property alias text: titleLabel.text
    property alias subText: subLabel.text
    property alias iconSource: icon.source
    property alias iconColor: backgroundShape.color
    property bool bold: false

    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right

    /* FIXME This duplicate UbuntuShape is a workaround for
     https://launchpad.net/bugs/1396104 */
    UbuntuShape {
        id: backgroundShape
        anchors.fill: iconShape
        visible: iconShape.visible
    }

    UbuntuShape {
        id: iconShape
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: visible ? roundBaseTwo(parent.height) : 0
        height: width
        visible: icon.source.toString()
        image: Image {
            id:icon
        }

        function roundBaseTwo(n) {
            var i = 2
            while (i * 2 <= n) i *= 2
            return i
        }
    }

    states: State {
        name: "noSub"
        when: !subLabel.text
        AnchorChanges {
            target: titleLabel
            anchors.top: undefined
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Label {
        id: titleLabel
        anchors.left: iconShape.right
        anchors.right: parent.right
        anchors.top: parent.top
        font.bold: root.bold
        elide: Text.ElideRight
    }

    Label {
        id: subLabel
        anchors.left: iconShape.right
        anchors.right: parent.right
        anchors.top: titleLabel.bottom
        fontSize: "x-small"
        elide: Text.ElideRight
        wrapMode: Text.Wrap
        maximumLineCount: 2
    }
}
