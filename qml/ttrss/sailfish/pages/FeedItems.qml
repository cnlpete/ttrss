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

Page {
    id: feeditemsPage
    property var feed
    property bool needsUpdate: false

    property int remorseCounter: 0
    onRemorseCounterChanged: {
        // Disallow model changes while a RemorseItem is running.
        pullmenu.visible = remorseCounter === 0
        pushmenu.visible = remorseCounter === 0
    }

    Component.onCompleted: {
        feedItemModel.feed = feeditemsPage.feed
        feeditemsPage.update()
    }

    RemorsePopup { id: remorse }

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: feedItemModel

        PullDownMenu {
            id: pullmenu
            MenuItem {
                text: qsTr("Update")
                enabled: !network.loading
                onClicked: {
                    feeditemsPage.update()
                }
            }
            ToggleShowAllItem {
                onUpdateView: {
                    if (feeditemsPage.visible) {
                        feeditemsPage.update()
                    } else {
                        feeditemsPage.needsUpdate = true
                    }
                }
            }
            MenuItem {
                text: qsTr('Mark all loaded read')
                onClicked: markAllLoadedAsRead()
            }
        }

        PushUpMenu {
            id: pushmenu
            MenuItem {
                text: qsTr('Mark all loaded read')
                onClicked: markAllLoadedAsRead()
            }
            ToggleShowAllItem {
                onUpdateView: {
                    if (feeditemsPage.visible) {
                        feeditemsPage.update()
                    } else {
                        feeditemsPage.needsUpdate = true
                    }
                }
            }
        }

        section {
            property: 'date'

            delegate: SectionHeader {
                text: section
                height: Theme.itemSizeExtraSmall
            }
        }

        delegate: FeedItemDelegate {
            onClicked: {
                feedItemModel.selectedIndex = index
                pageStack.push(Qt.resolvedUrl("FeedItem.qml"),
                               { isCat: feed.isCat })
            }
            onRemorseRunning: {
                if (running) {
                    ++feeditemsPage.remorseCounter
                } else {
                    --feeditemsPage.remorseCounter
                }
            }
        }

        footer: Button {
            text: qsTr("Load more")
            visible: settings.feeditemsOrder === 0 && feedItemModel.hasMoreItems
            height: settings.feeditemsOrder === 0 && feedItemModel.hasMoreItems ? 51 : 0
            width: parent.width
            onClicked: feedItemModel.update()
        }

        header: Column {
            width: listView.width
            height: header.height + info.height + lastUpdated.height
            PageHeader {
                id: header
                title: feed.title
            }
            Button {
                id: info
                text: qsTr("Load more")
                visible: settings.feeditemsOrder === 1 && feedItemModel.hasMoreItems
                height: settings.feeditemsOrder === 1 && feedItemModel.hasMoreItems ? 51 : 0
                width: parent.width
                onClicked: feedItemModel.update()
            }
            SectionHeader {
                id: lastUpdated
                text: feed.lastUpdated !== "" ? qsTr("Last updated: %1").arg(feed.lastUpdated) : ""
                visible: text !== ""
                height: Theme.itemSizeExtraSmall
            }
        }

        ViewPlaceholder {
            enabled: listView.count == 0
            text: network.loading ?
                      qsTr("Loading") :
                      settings.showAll ? qsTr("No items in feed") : qsTr("No unread items in feed")
        }
        BusyIndicator {
            visible: listView.count != 0 && network.loading
            running: visible
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
        }
        VerticalScrollDecorator { }
    }

    function showFeed(feedModel) {
        if(feedModel !== null) {
            pageStack.push(Qt.resolvedUrl("FeedItems.qml"),
                           { feed: feedModel })
        }
    }

    onVisibleChanged: {
        if (visible) {
            cover = Qt.resolvedUrl("../cover/FeedItemsCover.qml")
            if (feeditemsPage.needsUpdate) {
                feeditemsPage.needsUpdate = false
                feeditemsPage.update()
            }
        }
    }

    function markAllLoadedAsRead() {
        remorse.execute(qsTr("Marking all loaded as read"),
                        function() {
                            feedItemModel.markAllLoadedAsRead()
                        })
    }

    function update() {
        feedItemModel.continuation = 0
        feedItemModel.hasMoreItems = false
        feedItemModel.clear()
        feedItemModel.update()
    }
}
