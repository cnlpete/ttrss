/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2016  Hauke Schade
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

import QtQuick 1.1
import com.nokia.meego 1.0
import "../components" 1.0

Page {
    id: itemListPage
    tools: feedItemsTools
    property variant feed
    property bool needsUpdate: false

    Component.onCompleted: {
        feedItems.feed = itemListPage.feed
        feedItems.hasMoreItems = false
        feedItems.continuation = 0
        feedItems.clear()
        feedItems.update()
    }

    onVisibleChanged: {
        if (visible && itemListPage.needsUpdate) {
            itemListPage.needsUpdate = false
            feedItems.continuation = 0
            feedItems.hasMoreItems = false
            feedItems.clear()
            feedItems.update()
        }
    }

    Item {
        anchors {
            top: pageHeader.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        ListView {
            id: listView
            anchors.fill: parent
            anchors.margins: MyTheme.paddingMedium

            model: feedItems

            section.delegate: SectionHeader {}
            section.property: "date"

            delegate: FeedItemDelegate {
                onClicked: {
                    feedItems.selectedIndex = index
                    rootWindow.openFile("FeedItem.qml", { isCat: feed.isCat })
                }
                onPressAndHold: {
                    feedItems.selectedIndex = index
                    feeditemMenu.feedItem = model
                    feeditemMenu.open()
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
            header: Button {
                text: qsTr("Load more")
                visible: settings.feeditemsOrder === 1 && feedItems.hasMoreItems
                height: settings.feeditemsOrder === 1 && feedItems.hasMoreItems ? 51 : 0
                width: parent.width
                onClicked: feedItems.update()
            }
        }
//        FastScroll {
//            listView: listView
//            visible: feedItems.count > 10

//        }
        EmptyListInfoLabel {
            text: network.loading ?
                      qsTr("Loading") :
                      settings.showAll ? qsTr("No items in feed") : qsTr("No unread items in feed")
            anchors.fill: parent
            anchors.margins: MyTheme.paddingLarge
            visible: feedItems.count == 0
        }
    }

    PageHeader {
        id: pageHeader
        text: feed.title
        logourl: feed.icon

        hasUpdateAction: true
        onUpdateActionActivated: {
            feedItems.update()
        }
    }

    ToolBarLayout {
        id: feedItemsTools

        ToolIcon { iconId: "toolbar-back"; onClicked: { feedItemsMenu.close(); pageStack.pop();} }
        ToolIcon { iconId: "toolbar-view-menu" ; onClicked: (feedItemsMenu.status === DialogStatus.Closed) ? feedItemsMenu.open() : feedItemsMenu.close() }
    }

    Menu {
        id: feedItemsMenu
        visualParent: pageStack

        MenuLayout {
            ToggleShowAllItem {
                onUpdateView: {
                    if (itemListPage.visible) {
                        feedItems.continuation = 0
                        feedItems.hasMoreItems = false
                        feedItems.clear()
                        feedItems.update()
                    } else {
                        itemListPage.needsUpdate = true
                    }
                }
            }
            MenuItem {
                text: qsTr('Mark all loaded read')
                onClicked: {
                    feedItems.markAllLoadedAsRead()
                }
            }
            SettingsItem {}
            AboutItem {}
        }
    }

    Menu {
        id: feeditemMenu
        visualParent: pageStack

        property variant feedItem

        MenuLayout {
            MenuItem {
                text: (feeditemMenu.feedItem !== undefined && feeditemMenu.feedItem.marked?qsTr("Unstar"):qsTr("Star"))
                onClicked: {
                    feedItems.toggleStar()
                } }
            MenuItem {
                text: (feeditemMenu.feedItem !== undefined && feeditemMenu.feedItem.rss?qsTr("Unpublish"):qsTr("Publish"))
                onClicked: {
                    feedItems.togglePublished()
                } }
            MenuItem {
                text: (feeditemMenu.feedItem !== undefined && feeditemMenu.feedItem.unread?qsTr("Mark read"):qsTr("Mark Unread"))
                onClicked: {
                    feedItems.toggleRead()
                } }
            MenuItem {
                text: qsTr("Mark all above read")
                enabled: feedItems.selectedIndex > 0
                onClicked: {
                    feedItems.markAllAboveAsRead(feedItems.selectedIndex)
                } }
            MenuItem {
                text: qsTr("Open in Web Browser")
                enabled: feeditemMenu.feedItem !== undefined &&
                         feeditemMenu.feedItem.url &&
                         (feeditemMenu.feedItem.url != "")
                onClicked: {
                    infoBanner.text = qsTr("Open in Web Browser")
                    infoBanner.show()
                    Qt.openUrlExternally(feeditemMenu.feedItem.url);
                } }
        }
    }
}
