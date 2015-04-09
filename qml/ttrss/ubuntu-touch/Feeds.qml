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
    id: feedsPage
    property variant category

    title: category.title

    Component.onCompleted: {
        feeds.category = feedsPage.category
        feeds.clear()
        var ttrss = rootWindow.getTTRSS()
        ttrss.setShowAll(settings.showAll)
        feeds.update()
        // FIXME workaround for https://bugs.launchpad.net/bugs/1404884
        pullToRefresh.enabled = true
    }

    head {
        actions: [
            Action {
                iconName: "settings"
                onTriggered: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            }
        ]

        sections {
            model: [ qsTr("Unread"), qsTr("All") ]
            selectedIndex: settings.showAll ? 1 : 0
            onSelectedIndexChanged: {
                var ttrss = rootWindow.getTTRSS()
                var showAll = (feedsPage.head.sections.selectedIndex == 1)
                if (showAll != settings.showAll) {
                    ttrss.setShowAll(showAll)
                    settings.showAll = showAll
                    feeds.update()
                }
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        model: feeds

        PullToRefresh {
            id: pullToRefresh
            enabled: false
            onRefresh: feeds.update()
            refreshing: network.loading
        }

        /* TODO
        PullDownMenu {
            //AboutItem {}
            SettingsItem {}
            MenuItem {
                text: qsTr("Add subscription")
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("AddSubscription.qml"), {
                                                    categoryId: feedsPage.category.categoryId
                                                })
                    dialog.accepted.connect(function(){
                        var ttrss = rootWindow.getTTRSS()
                        ttrss.subscribe(dialog.selectedId,
                                        dialog.src,
                                        function(result) {
                                            switch (result) {
                                            case 0:
                                                notification.show(qsTr('Already subscribed to Feed'))
                                                break
                                            case 1:
                                                //notification.show(qsTr('Feed added'))
                                                feeds.update()
                                                categories.update()
                                                break
                                            case 2:
                                                notification.show(qsTr('Invalid URL'))
                                                break
                                            case 3:
                                                notification.show(qsTr('URL content is HTML, no feeds available'))
                                                break
                                            case 4:
                                                notification.show(qsTr('URL content is HTML which contains multiple feeds'))
                                                break
                                            case 5:
                                                notification.show(qsTr('Couldn\'t download the URL content'))
                                                break
                                            case 5:
                                                notification.show(qsTr('Content is an invalid XML'))
                                                break
                                            default:
                                                notification.show(qsTr('An error occured while subscribing to the feed'))
                                            }
                                        })
                    })
                }
            }
            MenuItem {
                text: qsTr("Logout")
                visible: pageStack.depth == 1
                onClicked: {
                    pageStack.replace(Qt.resolvedUrl("MainPage.qml"), { doAutoLogin: false })
                }
            }
            MenuItem {
                text: qsTr("Update")
                enabled: !network.loading
                onClicked: {
                    feeds.update()
                }
            }
            ToggleShowAllItem {
                onUpdateView: {
                    feeds.update()
                }
            }
        }
        */

        delegate: FeedDelegate {
            onClicked: {
                feeds.selectedIndex = index
                showFeed(model)
            }
        }

        Label {
            visible: listView.count == 0
            text: network.loading ?
                      qsTr("Loading") :
                      rootWindow.showAll ? qsTr("No feeds in category") : qsTr("Category has no unread items")
        }
        Scrollbar {
            flickableItem: listView
        }
    }

    function showFeed(feedModel) {
        if (feedModel != null) {
            feedItems.clear()
            pageStack.push(Qt.resolvedUrl("FeedItems.qml"), {
                feed: feedModel
            })
        }
    }
}
