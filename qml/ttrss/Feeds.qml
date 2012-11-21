//Copyright Hauke Schade, 2012
//
//This file is part of TTRss.
//
//TTRss is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the
//Free Software Foundation, either version 2 of the License, or (at your option) any later version.
//TTRss is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with TTRss (on a Maemo/Meego system there is a copy
//in /usr/share/common-licenses. If not, see http://www.gnu.org/licenses/.

import QtQuick 1.1
import com.nokia.meego 1.0

Page {
    id: feedsPage
    tools: feedsTools
    property int categoryId: 0
    property int numStatusUpdates
    property bool loading: false
    property string pageTitle: ""

    ListModel {
        id: feedsModel
    }

    ListView {
        id: listView
        anchors.margins: constant.paddingLarge
        anchors{ top: pageHeader.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
        model: feedsModel

        delegate:  Item {
            id: listItem
            height: 88
            width: parent.width

            BorderImage {
                id: background
                anchors.fill: parent
                // Fill page borders
                anchors.leftMargin: -feedsPage.anchors.leftMargin
                anchors.rightMargin: -feedsPage.anchors.rightMargin
                visible: mouseArea.pressed
                source: "image://theme/meegotouch-list-background-pressed-center"
            }

            Row {
                anchors.left: parent.left
                anchors.right: drilldownarrow.left
                clip: true

                Column {
                    clip: true

                    Label {
                        id: mainText
                        text: model.title
                        font.weight: Font.Bold
                        font.pixelSize: constant.fontSizeLarge
                        color: (model.unreadcount > 0) ? "#000033" : "#888888";

                    }

                    Label {
                        id: subText
                        text: model.subtitle
                        font.weight: Font.Light
                        font.pixelSize: constant.fontSizeSmall
                        color: (model.unreadcount > 0) ? "#cc6633" : "#888888"

                        visible: text != ""
                    }
                }
            }

            Image {
                id: drilldownarrow
                source: "image://theme/icon-m-common-drilldown-arrow" + (theme.inverted ? "-inverse" : "")
                anchors.right: parent.right;
                anchors.verticalCenter: parent.verticalCenter
                visible: (model.feedId !== null)
            }

            MouseArea {
                id: mouseArea
                anchors.fill: background
                onClicked: {
                    showFeed(model.feedId);
                }
            }
        }
    }
    ScrollDecorator {
        flickableItem: listView
    }

    function updateFeeds() {
        loading = true;
        var ttrss = rootWindow.getTTRSS();
        numStatusUpdates = ttrss.getNumStatusUpdates();
        ttrss.updateFeeds(categoryId, showFeeds);
    }

    function showFeeds() {
        var ttrss = rootWindow.getTTRSS();
        var feeds = ttrss.getFeeds(categoryId);
        var showAll = ttrss.getShowAll();
        feedsModel.clear();

        loading = false;

        if(feeds) {
            var emptyList = feeds.length;
            var unreadcount;
            console.log("showing feeds for category: "+categoryId+"\n");

            //First add feed with unread items
            for(var feed in feeds) {
                unreadcount = feeds[feed].unread;
                if( unreadcount && (unreadcount > 0)) {
                    emptyList = false;

                    feedsModel.append({
                                          title:     ttrss.html_entity_decode(feeds[feed].title, 'ENT_QUOTES'),
                                          subtitle:  "Unread: " + unreadcount,
                                          unreadcount:  unreadcount,
                                          feedId:     feeds[feed].id,
                                      });
                }
            }
            //If we're showing all feeds, add the ones with no unread items
            if(showAll) {
                for(var feed in feeds) {
                    unreadcount = feeds[feed].unread;
                    if(unreadcount === 0) {
                        feedsModel.append({
                                              title:     ttrss.html_entity_decode(feeds[feed].title,'ENT_QUOTES'),
                                              subtitle:  "Unread: " + unreadcount,
                                              unreadcount:  unreadcount,
                                              feedId:     feeds[feed].id,
                                          });
                    }
                }
            }

            if(emptyList) {
                if(showAll ||(feeds.length === 0) ) {
                    feedsModel.append({
                                          title: qsTr("No feeds in category"),
                                          subtitle: "",
                                          feedId: null,
                                          unreadCount: 0,
                                      });
                } else {
                    feedsModel.append({
                                          title: qsTr("Category has no unread items"),
                                          subtitle: "",
                                          feedId: null,
                                          unreadCount: 0,
                                      });
                }
            }
        }
    }

    onCategoryIdChanged: {
        showFeeds();
        updateFeeds();
    }

    Component.onCompleted: {
        showFeeds();
        updateFeeds();
    }
    onStatusChanged: {
        var ttrss = rootWindow.getTTRSS();
        if(status === PageStatus.Deactivating)
            numStatusUpdates = ttrss.getNumStatusUpdates();
        else if (status === PageStatus.Activating) {
            if(ttrss.getNumStatusUpdates() > numStatusUpdates)
                updateFeeds();
        }
    }

    function showFeed(feedId) {
        if(feedId !== null) {
            console.log("Loading items for "+feedId+"\n");
            var component = Qt.createComponent("ItemList.qml");
            if (component.status === Component.Ready)
                pageStack.push(component, { feedId: feedId });
            else
                console.log("Error loading component:", component.errorString());
        }
    }

    PageHeader {
        id: pageHeader
        text: pageTitle
    }

    ToolBarLayout {
        id: feedsTools

        ToolIcon { iconId: "toolbar-back"; onClicked: { feedsMenu.close(); pageStack.pop(); } }
        ToolIcon {
            iconId: "toolbar-refresh";
            visible: !loading;
            onClicked: { updateFeeds(); }
        }
        BusyIndicator {
            visible: loading
            running: loading
            platformStyle: BusyIndicatorStyle { size: 'medium' }
        }
        ToolIcon { iconId: "toolbar-view-menu" ; onClicked: (feedsMenu.status === DialogStatus.Closed) ? feedsMenu.open() : feedsMenu.close() }
    }

    Menu {
        id: feedsMenu
        visualParent: pageStack

        MenuLayout {
            MenuItem {
                id: toggleUnread
                text: qsTr("Toggle Unread Only")
                onClicked: {
                    var ttrss = rootWindow.getTTRSS();
                    var oldval = ttrss.getShowAll();
                    var newval = !oldval;
                    ttrss.setShowAll(newval);

                    //console.log("Updating categories with showAll: "+newval+"\n");
                    ttrss.updateFeeds(categoryId, showFeeds);
                }
            }
            MenuItem {
                text: qsTr("About")
                onClicked: {
                    rootWindow.openFile("About.qml");
                }
            }
        }
    }
}
