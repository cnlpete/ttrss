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

    contentHeight: Math.max(Theme.itemSizeSmall, titleLabel.height)
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
                feedModel.unsetIcon(index)
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
        id: titleLabel
        text: model.title
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: icon.visible ? icon.right : parent.left
        anchors.margins: Theme.paddingMedium
        anchors.right: bubble.left
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        textFormat: Text.StyledText
        font.weight: Font.Bold
        font.pixelSize: Theme.fontSizeMedium
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

    Component {
        id: contextMenu
        ContextMenu {
            MenuItem {
                text: qsTr("Mark all read")
                onClicked: listItem.markAllRead()
            }
            MenuItem {
                text: qsTr("Unsubscribe")
                visible: model.feedId >= 0 && !model.isCat
                onClicked: listItem.unsubcribe()
            }
            Component.onCompleted: {
                feedModel.selectedIndex = index
            }
        }
    }

    RemorseItem { id: remorse }

    function markAllRead() {
        remorse.execute(listItem,
                        qsTr("Marking all read"),
                        function() {
                            feedModel.catchUp()
                        })
    }

    function unsubcribe() {
        remorse.execute(listItem,
                        qsTr("Unsubcribing"),
                        function() {
                            var ttrss = rootWindow.getTTRSS()
                            ttrss.unsubscribe(model.feedId,
                                              function(successful, errorMessage) {
                                                  feedModel.update()
                                                  // TODO make use of parameters
                                              })
                        })
    }
}
