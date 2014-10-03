/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2014  Hauke Schade
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

    contentHeight: Theme.itemSizeSmall
    width: parent.width
    menu: contextMenu

    Image {
        id: icon
        sourceSize.height: 80
        sourceSize.width: 80
        asynchronous: true
        width: 60
        height:60
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: Theme.paddingMedium

        source: model.icon
        onStatusChanged: {
            if (status === Image.Error)
                feeds.unsetIcon(index)
        }

        visible: settings.displayIcons && model.icon !== ''
        BusyIndicator {
            visible: parent.status == Image.Loading
            running: visible
            anchors.centerIn: parent
        }

        Rectangle {
            color: "white"
            anchors.fill: parent
            visible: settings.whiteBackgroundOnIcons && parent.status == Image.Ready
            z: parent.z - 1
        }
    }

    Label {
        text: model.title
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: icon.visible ? icon.right : parent.left
        anchors.margins: Theme.paddingMedium
        width: parent.width - (icon.visible ? icon.width : 0) - bubble.width - Theme.paddingMedium
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        // todo: check for performance issues,
        // was StyledText before, which might be better
        textFormat: Text.RichText
        font.weight: Font.Bold
        font.pixelSize: Theme.fontSizeMedium
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

    Component {
        id: contextMenu
        ContextMenu {
            MenuItem {
                text: qsTr("Mark all read")
                onClicked: {
                    feeds.catchUp()
                } }
            MenuItem {
                text: qsTr("Unsubscribe")
                visible: model.feedId >= 0 && !model.isCat
                onClicked: {
                    var ttrss = rootWindow.getTTRSS()
                    ttrss.unsubscribe(model.feedId, function() { feeds.update() })
                } }
            Component.onCompleted: {
                feeds.selectedIndex = index
            }
        }
    }
}
