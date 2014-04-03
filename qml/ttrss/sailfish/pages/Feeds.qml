//Copyright Hauke Schade, 2012-2013
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
import Sailfish.Silica 1.0

Page {
    id: feedsPage
    property variant category

    Component.onCompleted: {
        feeds.category = feedsPage.category
        feeds.clear()
        feeds.update()
    }

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: feeds

        PullDownMenu {
            AboutItem {}
            SettingsItem {}
            ToggleShowAllItem {
                onUpdateView: {
                    feeds.update()
                }
            }
        }

        delegate: FeedDelegate {
            onClicked: {
                feeds.selectedIndex = index
                showFeed(model)
            }
        }

        header: PageHeader {
           title: category.title
        }
        ViewPlaceholder {
            enabled: listView.count == 0
            text: network.loading ?
                      qsTr("Loading") :
                      rootWindow.showAll ? qsTr("No feeds in category") : qsTr("Category has no unread items")
        }
        BusyIndicator {
            visible: listView.count != 0 && network.loading
            running: visible
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
        }
        ScrollDecorator {
            flickable: listView
        }
    }

    function showFeed(feedModel) {
        if(feedModel != null) {
            pageStack.push("FeedItems.qml", {
                                    feed: feedModel
                                })
        }
    }
}
