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
import Sailfish.Silica 1.0
import "../items"

ListItem {
    id: listItem

    contentHeight: categories.count > 8 ? Theme.itemSizeSmall : Theme.itemSizeMedium
    width: parent.width

    Label {
        text: model.title
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.margins: Theme.paddingMedium
        width: parent.width - bubble.width - Theme.paddingMedium
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        textFormat: Text.RichText // todo: check for performance issues, was StyledText before, which might be better
        font.weight: Font.Bold
        font.pixelSize: Theme.fontSizeLarge
        color: model.unreadcount > 0 ?
                   (listItem.highlighted ? Theme.highlightColor : Theme.primaryColor) :
                   (listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor)
    }
    Bubble {
        id: bubble
        value: model.unreadcount
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.margins: Theme.paddingMedium
        color: model.unreadcount > 0 ?
                   (listItem.highlighted ? Theme.highlightColor : Theme.primaryColor) :
                   (listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor)
    }
}
