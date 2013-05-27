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
        anchors {
            top: pageHeader.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        model: feedsModel

        delegate: FeedDelegate {
                onClicked: showFeed(model.feedId, model.title, model.icon)
                onPressAndHold: {
                    feedMenu.feedId = model.feedId
                    feedMenu.open()
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
        ttrss.updateFeeds(categoryId, showFeedsCallback);
    }

    function showFeedsCallback() {
        loading = false;
        showFeeds();
    }

    function showFeeds() {
        var ttrss = rootWindow.getTTRSS();
        var feeds = ttrss.getFeeds(categoryId);
        var showAll = ttrss.getShowAll();
        feedsModel.clear();

        if(feeds && feeds.length) {
            //First add feed with unread items
            for(var feed = 0; feed < feeds.length; feed++) {
                if (feeds[feed]) {
                    var title = ttrss.html_entity_decode(feeds[feed].title, 'ENT_QUOTES')
                    if (feeds[feed].id == ttrss.constants['feeds']['archived'])
                        title = constant.archivedArticles
                    if (feeds[feed].id == ttrss.constants['feeds']['starred'])
                        title = constant.starredArticles
                    if (feeds[feed].id == ttrss.constants['feeds']['published'])
                        title = constant.publishedArticles
                    if (feeds[feed].id == ttrss.constants['feeds']['fresh'])
                        title = constant.freshArticles
                    if (feeds[feed].id == ttrss.constants['feeds']['all'])
                        title = constant.allArticles
                    if (feeds[feed].id == ttrss.constants['feeds']['recently'])
                        title = constant.recentlyArticles

                    feedsModel.append({
                                          title:        title,
                                          unreadcount:  feeds[feed].unread,
                                          feedId:       feeds[feed].id,
                                          icon:         settings.displayIcons ? ttrss.getIconUrl(feeds[feed].id) : ''
                                      });
                }
            }
        }
        else {
            var t = (showAll ? qsTr("No feeds in category") : qsTr("Category has no unread items"))
            feedsModel.append({
                                  title:        t,
                                  unreadcount:  0,
                                  feedId:       null,
                                  icon:         ''
                              });
        }
    }

    onCategoryIdChanged: {
        showFeeds();
        updateFeeds();
    }

    onVisibleChanged: {
        if (visible)
            showFeeds();
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

    function showFeed(feedId, title, pageLogo) {
        if(feedId != null) {
            var component = Qt.createComponent("FeedItems.qml");
            if (component.status === Component.Ready)
                pageStack.push(component, {
                                   feedId: feedId,
                                   pageTitle: title,
                                   pageLogo: pageLogo
                               });
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
                text: qsTr("Add subscription")
                enabled: feedsPage.categoryId >= 0
                onClicked: {
                    addsubsriptionsheet.open()
                } }
            ToggleShowAllItem {
                onUpdateView: {
                    feedsPage.updateFeeds()
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
            anchors.leftMargin: 10
            anchors.topMargin: 10
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
                    font.pixelSize: constant.fontSizeMedium
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
            loading = true
            ttrss.subscribe(feedsPage.categoryId, server.text, function(result) {
                                loading = false
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
                                    updateFeeds()
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
                    var ttrss = rootWindow.getTTRSS()
                    loading = true
                    ttrss.catchUp(feedMenu.feedId, showFeedsCallback)
                } }
            MenuItem {
                text: qsTr("Unsubscribe")
                enabled: feedMenu.feedId >= 0
                onClicked: {
                    var ttrss = rootWindow.getTTRSS()
                    loading = true
                    ttrss.unsubscribe(feedMenu.feedId, showFeedsCallback)
                } }
        }
    }
}
