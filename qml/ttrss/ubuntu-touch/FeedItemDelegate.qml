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
import Ubuntu.Components.ListItems 0.1 as ListItem

ListItem.Empty {
    id: listItem


    onClicked: root.clicked()

    SubtitledLabel {
        anchors { leftMargin: units.gu(1); rightMargin: units.gu(1) }
        text: model.title
        subText: model.subtitle
        iconSource: (settings.displayIcons && feed.isCat) ? model.icon : ''
        bold: model.unread
    }
    /*
    Row {
        spacing: Theme.paddingMedium
        anchors.fill: parent
        anchors.leftMargin: (icon.visible ? icon.width : 0) + Theme.paddingMedium
        Image {
            source: "../../resources/ic_star_enabled.png"
            visible: model.marked
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.5
        }
        Image {
            source: "../../resources/ic_rss_enabled.png"
            visible: model.rss
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.5
        }
    }
    */

   /* TODO
    Component {
        id: contextMenu
        ContextMenu {
            MenuItem {
                id: toggleStarMenuItem
                text: model.marked ? qsTr("Unstar") : qsTr("Star")
                onClicked: {
                    feedItems.toggleStar()
                } }
            MenuItem {
                id: togglePublishedMenuItem
                text: model.rss ? qsTr("Unpublish") : qsTr("Publish")
                onClicked: {
                    feedItems.togglePublished()
                } }
            MenuItem {
                id: toggleReadMenuItem
                text: model.unread ? qsTr("Mark read") : qsTr("Mark Unread")
                onClicked: {
                    feedItems.toggleRead()
                } }
            MenuItem {
                id: openInBrowserMenuItem
                text: qsTr("Open in Web Browser")
                visible: model.url && model.url != ""
                onClicked: {
                    var item = feedItems.getSelectedItem()
                    Qt.openUrlExternally(item.url)
                }

            }
            Component.onCompleted: {
                feedItems.selectedIndex = index
            }
        }
    }
    */
}
