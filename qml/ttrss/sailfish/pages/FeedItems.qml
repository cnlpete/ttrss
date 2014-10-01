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

Page {
    id: feeditemsPage
    property variant feed

    Component.onCompleted: {
        feedItems.feed = feeditemsPage.feed
        feedItems.hasMoreItems = false
        feedItems.continuation = 0
        feedItems.clear()
        feedItems.update()
    }

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: feedItems

        PullDownMenu {
//            AboutItem {}
//            SettingsItem {}
            MenuItem {
                text: qsTr("Update")
                enabled: !network.loading
                onClicked: {
                    feedItems.continuation = 0
                    feedItems.hasMoreItems = false
                    feedItems.clear()
                    feedItems.update()
                }
            }
            ToggleShowAllItem {
                onUpdateView: {
                    feedItems.continuation = 0
                    feedItems.hasMoreItems = false
                    feedItems.clear()
                    feedItems.update()
                }
            }
            MenuItem {
                text: qsTr('Mark all read')
                onClicked: {
                    feedItems.catchUp()
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
                feedItems.selectedIndex = index
                pageStack.push("FeedItem.qml", { isCat: feed.isCat })
            }
        }

        footer: Button {
            id: foot
            text: qsTr("Load more")
            visible: settings.feeditemsOrder === 0 && feedItems.hasMoreItems
            height: settings.feeditemsOrder === 0 && feedItems.hasMoreItems ? 51 : 0
            width: parent.width
            onClicked: feedItems.update()
        }

        header: PageHeader {
           title: feed.title
        }
        ViewPlaceholder {
            enabled: listView.count == 0
            text: network.loading ?
                      qsTr("Loading") :
                      rootWindow.showAll ? qsTr("No items in feed") : qsTr("No unread items in feed")
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
        if(feedModel != null) {
            pageStack.push("FeedItems.qml", {
                                    feed: feedModel
                                })
        }
    }

    onVisibleChanged: {
        if (visible) {
            cover = Qt.resolvedUrl("../cover/FeedItemsCover.qml")
        }
    }
}
