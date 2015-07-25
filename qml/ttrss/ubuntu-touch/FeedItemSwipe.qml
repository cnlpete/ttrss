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
                model.toggleStar()
            }
        },
        Action {
            iconSource: "../resources/ic_"+(currentItem.unread?"unread":"read")+".png"
            onTriggered: {
                model.toggleRead()
            }
        }
    ]

    ListView {
        id: listView
        anchors.fill: parent
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        highlightFollowsCurrentItem: false
        highlightRangeMode: ListView.StrictlyEnforceRange

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

            width: ListView.view.width
            height: ListView.view.height
        }

        onCurrentIndexChanged: {
            model.selectedIndex = currentIndex
            if (currentItem && settings.autoMarkRead && currentItem.unread) {
                console.log("marking item as read")
                model.toggleRead()
            }
            panel.close()
        }
    }

    Component.onCompleted: {
        /* For some reason, unless this is done here, the ListView would
         * instantiate all the delegates when the page is first shown. */
        listView.model = root.model
        listView.currentIndex = root.currentIndex
        listView.highlightFollowsCurrentItem = true
    }

    Panel {
        id: panel
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: units.gu(8)

        Rectangle {
            anchors.fill: parent
            color: Theme.palette.normal.overlay
            ToolbarItems {
                anchors.fill: parent
                ToolbarButton {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    iconName: "external-link"
                    text: qsTr("Open in Browser")
                    onTriggered: Qt.openUrlExternally(currentItem.url)
                }
            }
        }
    }
}
