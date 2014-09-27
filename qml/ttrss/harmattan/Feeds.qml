/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2014  Hauke Schade
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

import QtQuick 1.1
import com.nokia.meego 1.0
import "../components" 1.0

Page {
    id: feedsPage
    tools: feedsTools
    property variant category

    Component.onCompleted: {
        feeds.category = feedsPage.category
        feeds.clear()
        feeds.update()
    }

    Item {
        anchors {
            top: pageHeader.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: MyTheme.paddingMedium
        }
        ListView {
            id: listView
            anchors.fill: parent
            model: feeds

            delegate: FeedDelegate {
                onClicked: {
                    feeds.selectedIndex = index
                    showFeed(model)
                }
                onPressAndHold: {
                    feeds.selectedIndex = index
                    feedMenu.feedId = model.feedId
                    feedMenu.open()
                }
            }
        }
        ScrollDecorator {
            flickableItem: listView
        }
        EmptyListInfoLabel {
            text: network.loading ?
                      qsTr("Loading") :
                      rootWindow.showAll ? qsTr("No feeds in category") : qsTr("Category has no unread items")
            anchors.fill: parent
            visible: feeds.count == 0
        }
    }

    function showFeed(feedModel) {
        if(feedModel != null) {
            rootWindow.openFile("FeedItems.qml", {
                                    feed: feedModel
                                })
        }
    }

    PageHeader {
        id: pageHeader
        text: category.title

        hasUpdateAction: true
        onUpdateActionActivated: {
            feeds.update()
        }
    }

    ToolBarLayout {
        id: feedsTools

        ToolIcon { iconId: "toolbar-back"; onClicked: { feedsMenu.close(); pageStack.pop(); } }
        ToolIcon { iconId: "toolbar-view-menu" ; onClicked: (feedsMenu.status === DialogStatus.Closed) ? feedsMenu.open() : feedsMenu.close() }
    }

    Menu {
        id: feedsMenu
        visualParent: pageStack

        MenuLayout {
            MenuItem {
                text: qsTr("Add subscription")
                enabled: feedsPage.category.categoryId >= 0
                onClicked: {
                    addsubsriptionsheet.open()
                } }
            ToggleShowAllItem {
                onUpdateView: {
                    feeds.update()
                }
            }
            SettingsItem {}
            AboutItem {}
        }
    }

    Sheet {
        id: addsubsriptionsheet

        acceptButtonText: qsTr("Add")
        rejectButtonText: qsTr("Cancel")

        content: Flickable {
            anchors.fill: parent
            anchors.leftMargin: MyTheme.paddingMedium
            anchors.topMargin: MyTheme.paddingMedium
            flickableDirection: Flickable.VerticalFlick
            Column {
                id: col2
                anchors.top: parent.top
                spacing: 10
                width: parent.width
                Label {
                    id: serverLabel
                    text: qsTr("Feed address:")
                    width: parent.width
                    font.pixelSize: MyTheme.fontSizeMedium
                }
                TextField {
                    id: server
                    text: ""
                    width: parent.width
                }
            }
        }
        onAccepted: {
            var ttrss = rootWindow.getTTRSS()
            ttrss.subscribe(feedsPage.category.categoryId, server.text, function(result) {
                                /**
                                * 0 - OK, Feed already exists
                                * 1 - OK, Feed added
                                * 2 - Invalid URL
                                * 3 - URL content is HTML, no feeds available
                                * 4 - URL content is HTML which contains multiple feeds.
                                * 5 - Couldn't download the URL content.
                                * 6 - Content is an invalid XML.
                                */
                                if (result === -1 || result >= 3) {
                                    infoBanner.text = qsTr('Error')
                                    infoBanner.show()
                                    addsubsriptionsheet.open()
                                }
                                else if (result === 2) {
                                    infoBanner.text = qsTr('Invalid URL')
                                    infoBanner.show()
                                    addsubsriptionsheet.open()
                                }
                                else if (result === 0) {
                                    infoBanner.text = qsTr('Already suscribed to Feed')
                                    infoBanner.show()
                                }
                                else {
                                    infoBanner.text = qsTr('Feed added')
                                    infoBanner.show()
                                    feeds.update()
                                }
                            })
        }
    }

    Menu {
        id: feedMenu
        visualParent: pageStack

        property int feedId: 0

        MenuLayout {
            MenuItem {
                text: qsTr("Mark all read")
                onClicked: {
                    feeds.catchUp()
                } }
            MenuItem {
                text: qsTr("Unsubscribe")
                enabled: feedMenu.feedId >= 0
                onClicked: {
                    var ttrss = rootWindow.getTTRSS()
                    ttrss.unsubscribe(feedMenu.feedId, function() { feeds.update() })
                } }
        }
    }
}
