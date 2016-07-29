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
    id: feedsPage
    property var category

    Component.onCompleted: {
        feedModel.category = feedsPage.category
        feedModel.clear()
        var ttrss = rootWindow.getTTRSS()
        ttrss.setShowAll(settings.showAll)
        feedModel.update()
    }

    header: PageHeader {
        title: category.title
        flickable: listView
        trailingActionBar.actions: [
            Action {
                iconName: "settings"
                onTriggered: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            }
        ]

        extension: Sections {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            model: [ qsTr("Unread"), qsTr("All") ]
            selectedIndex: settings.showAll ? 1 : 0
            onSelectedIndexChanged: {
                var ttrss = rootWindow.getTTRSS()
                var showAll = (selectedIndex == 1)
                if (showAll != settings.showAll) {
                    ttrss.setShowAll(showAll)
                    settings.showAll = showAll
                    feedModel.update()
                }
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        model: feedModel

        MyPullToRefresh {
            id: pullToRefresh
            onRefresh: feedModel.update()
            updating: network.loading
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
                                                feedModel.update()
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
                    feedModel.update()
                }
            }
            ToggleShowAllItem {
                onUpdateView: {
                    feedModel.update()
                }
            }
        }
        */

        delegate: FeedDelegate {
            onClicked: {
                feedModel.selectedIndex = index
                showFeed(model)
            }
        }

        Label {
            visible: listView.count == 0
            text: network.loading ?
                      qsTr("Loading") :
                      rootWindow.showAll ? qsTr("No feeds in category") : qsTr("Category has no unread items")
        }
        ActivityIndicator {
            running: network.loading && !pullToRefresh.refreshing
            anchors.centerIn: parent
        }
        Scrollbar {
            flickableItem: listView
        }
    }

    function showFeed(feedModel) {
        if (feedModel != null) {
            feedItemModel.clear()
            pageStack.push(Qt.resolvedUrl("FeedItems.qml"), {
                feed: feedModel
            })
        }
    }
}
