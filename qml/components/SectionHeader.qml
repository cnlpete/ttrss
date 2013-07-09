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

    height: sectionLabel.height
    width: parent.width

    Image {
        anchors.left: parent.left
        anchors.right: sectionLabel.left
        anchors.rightMargin: constant.listItemSpacing
        anchors.verticalCenter: parent.verticalCenter

        source: "image://theme/meegotouch-groupheader"+(theme.inverted?"-inverted":"")+"-background"
    }

    Label {
        id: sectionLabel
        anchors.right: parent.right

        color: constant.sectionLabel
        font.pixelSize: constant.fontSizeXSmall
        font.weight: Font.Bold

        text: section
    }
}
