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
import Ubuntu.Components 1.1

Page {
    id: root

    property bool isCat: false
    property var model
    property int currentIndex: -1
    property alias currentItem: listView.currentItem

    anchors.fill: parent
    title: currentItem ? currentItem.title : ""
    flickable: currentItem ? currentItem.flickable : null

    head.actions: [
        Action {
            iconSource: "../resources/ic_star_"+(currentItem.marked?"enabled":"disabled")+".png"
            onTriggered: {
                feedItems.toggleStar()
            }
        },
        Action {
            iconSource: "../resources/ic_"+(currentItem.unread?"unread":"read")+".png"
            onTriggered: {
                feedItems.toggleRead()
            }
        }
    ]

    ListView {
        id: listView
        anchors.fill: parent
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        highlightFollowsCurrentItem: true
        highlightRangeMode: ListView.StrictlyEnforceRange
        cacheBuffer: 0

        delegate: FeedItem {
            title: model.title
            url: model.url
            date: model.date
            labels: model.labels
            marked: model.marked
            unread: model.unread
            rss: model.rss
            attachments: model.attachments
            content: model.content

            width: listView.width
            height: listView.height
        }

        onCurrentIndexChanged: {
            feedItems.selectedIndex = currentIndex
            if (currentItem && settings.autoMarkRead && currentItem.unread) {
                console.log("marking item as read")
                feedItems.toggleRead()
            }
        }
    }

    Component.onCompleted: {
        listView.model = root.model
        listView.currentIndex = root.currentIndex
    }
}
