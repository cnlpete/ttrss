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
import Ubuntu.Components 1.3

Page {
    id: root

    property bool isCat: false
    property alias model: listView.model
    property int currentIndex: -1
    property alias currentItem: listView.currentItem

    anchors.fill: parent

    header: PageHeader {
        title: currentItem ? currentItem.title : ""
        trailingActionBar.actions: [
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
    }

    ListView {
        id: listView
        anchors.fill: parent
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        highlightFollowsCurrentItem: true
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
            if (settings.autoMarkRead) {
                readTimer.restart()
            }
            panel.close()
        }
    }

    Component.onCompleted: {
        /* We don't use an alias on the current index, in order to perform the
         * autoread action when the index changes. */
        listView.currentIndex = root.currentIndex
    }

    Timer {
        id: readTimer
        interval: 500
        repeat: false
        onTriggered: if (currentItem && currentItem.unread) {
            console.log("marking item as read")
            model.toggleRead()
        }
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
            color: theme.palette.normal.overlay
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
