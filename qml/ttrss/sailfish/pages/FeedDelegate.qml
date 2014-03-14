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

import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: listItem

    signal clicked
    property alias pressed: mouseArea.pressed

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

        visible: settings.displayIcons && model.icon != ''
    }

    Label {
        text: model.title
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: icon.visible ? icon.right : parent.left
        anchors.margins: Theme.paddingMedium
        anchors.right: bubble.left
        truncationMode: TruncationMode.Elide
        font.weight: Font.Bold
        font.pixelSize: Theme.fontSizeMedium
        color: listItem.highlighted ? Theme.highlightColor : ((model.unreadcount > 0) ? Theme.primaryColor : Theme.secondaryColor)
    }
    Label {
        id: bubble
        text: model.unreadcount
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.margins: Theme.paddingMedium
        font.pixelSize: Theme.fontSizeMedium
        color: listItem.highlighted ? Theme.highlightColor : ((model.unreadcount > 0) ? Theme.primaryColor : Theme.secondaryColor)
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: listItem.clicked()
    }

    Component {
        id: contextMenu
        ContextMenu {
            MenuItem {
                text: qsTr("Mark all read")
                onClicked: {
                    feeds.catchUp()
                } }
//            MenuItem {
//                text: qsTr("Unsubscribe")
//                enabled: feedMenu.feedId >= 0
//                onClicked: {
//                    var ttrss = rootWindow.getTTRSS()
//                    ttrss.unsubscribe(feedMenu.feedId, function() { feeds.update() })
//                } }
        }
    }
}
