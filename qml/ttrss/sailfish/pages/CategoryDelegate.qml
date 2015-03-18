/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2015  Hauke Schade
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
import "../items"

ListItem {
    id: listItem

    contentHeight: categoryModel.count > 8 ? Theme.itemSizeSmall : Theme.itemSizeMedium
    width: parent.width

    Label {
        text: model.title
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.margins: Theme.paddingMedium
        width: parent.width - anchors.margins // left margin
               - Theme.paddingMedium // spacing between label and bubble
               - bubble.width - bubble.anchors.margins // right margin
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        // todo: check for performance issues,
        // was StyledText before, which might be better
        textFormat: Text.RichText
        font.weight: Font.Bold
        font.pixelSize: Theme.fontSizeLarge
        color: model.unreadcount > 0 ?
                   (listItem.highlighted ? Theme.highlightColor : Theme.primaryColor) :
                   (listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor)
    }
    Bubble {
        id: bubble
        text: model.unreadcount
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.margins: Theme.paddingMedium
        color: model.unreadcount > 0 ?
                   (listItem.highlighted ? Theme.highlightColor : Theme.primaryColor) :
                   (listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor)
    }
}
