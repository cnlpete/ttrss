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
import "../components" 1.0

Page {
    id: itemListPage
    tools: feedItemsTools
    property variant feed
    property int numStatusUpdates
    property bool loading: false

    ListModel {
        id: itemListModel
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
            anchors.margins: constant.paddingLarge

            model: itemListModel

            section.delegate: SectionHeader {}
            section.property: "date"

            delegate: FeedItemDelegate {
                onClicked: { showFeedItem(model.id, model.title) }
                onPressAndHold: {
                    feeditemMenu.feedItem = model
                    feeditemMenu.open()
                }
            }
        }
        FastScroll {
            listView: listView
            visible: !!itemListModel && itemListModel.count > 10
        }
        EmptyListInfoLabel {
            text: rootWindow.showAll ? qsTr("No items in feed") : qsTr("No unread items in feed")
            anchors.fill: parent
            anchors.margins: constant.paddingLarge
            visible: itemListModel.count == 0
        }
    }

    function showFeedItem(articleId, title) {
        if(articleId != null) {
            rootWindow.openFile("FeedItem.qml", {
                                    articleId: articleId,
                                    feedId: feed.feedId,
                                    pageTitle: title
                                })
        }
    }

    function updateFeedItems() {
        loading = true;
        var ttrss = rootWindow.getTTRSS();
        numStatusUpdates = ttrss.getNumStatusUpdates();
        ttrss.updateFeedItems(feed.feedId, showFeedItemsCallback);
    }

    function showFeedItemsCallback() {
        loading = false;
        showFeedItems();
    }

    function showFeedItems() {
        var ttrss = rootWindow.getTTRSS();
        var feeditems = ttrss.getFeedItems(feed.feedId, settings.feeditemsOrder === 1);
        var showAll = ttrss.getShowAll();
        rootWindow.showAll = showAll;
        itemListModel.clear();
        var now = new Date();

        if (feeditems && feeditems.length) {
            for(var feeditem = 0; feeditem < feeditems.length; feeditem++) {
                var subtitle = feeditems[feeditem].content || ""
                subtitle = subtitle.replace(/\n/gi, " ")
                subtitle = subtitle.replace(/<[\/]?[a-zA-Z][^>]*>/gi, "")
                subtitle = unescape(subtitle.replace(/<!--.*-->/gi, ""))
                if (subtitle.length > 102)
                    subtitle = subtitle.substring(0,100) + "..."
                subtitle = "<body>" + subtitle + "</body>"

                var title = feeditems[feeditem].title
                title = title.replace(/<br.*>/gi, "")
                title = "<body>" + unescape(title.replace(/\n/gi, "")) + "</body>"

                var d = new Date(feeditems[feeditem].updated * 1000)
                var formatedDate = Qt.formatDate(d, Qt.DefaultLocaleShortDate)
                if (d.getDate() === now.getDate() && d.getMonth() === now.getMonth() && d.getFullYear() === now.getFullYear())
                    formatedDate = qsTr('Today')
                itemListModel.append({
                                         title:     ttrss.html_entity_decode(title, 'ENT_QUOTES'),
                                         subtitle:  ttrss.html_entity_decode(subtitle, 'ENT_QUOTES'),
                                         id:        feeditems[feeditem].id,
                                         unread:    !!feeditems[feeditem].unread,
                                         marked:    !!feeditems[feeditem].marked,
                                         rss:       feeditems[feeditem].published,
                                         url:       feeditems[feeditem].link,
                                         date:      formatedDate
                                     });
            }
        }
    }

    function getMoreItems() {
        updateFeedItems();
    }


//    onFeedChanged: {
//        showFeedItems();
//        updateFeedItems();
//    }

    Component.onCompleted: {
        showFeedItems();
        updateFeedItems();
    }

    onVisibleChanged: {
        if (visible)
            showFeedItems();
    }

    onStatusChanged: {
        var ttrss = rootWindow.getTTRSS();
        if(status === PageStatus.Deactivating)
            numStatusUpdates = ttrss.getNumStatusUpdates();
        else if (status === PageStatus.Activating) {
            if(ttrss.getNumStatusUpdates() > numStatusUpdates)
                updateFeedItems();
        }
    }

    PageHeader {
        id: pageHeader
        text: feed.title
        logourl: feed.icon
    }

    ToolBarLayout {
        id: feedItemsTools

        ToolIcon { iconId: "toolbar-back"; onClicked: { feedItemsMenu.close(); pageStack.pop();} }
        ToolIcon {
            iconId: "toolbar-refresh";
            visible: !loading;
            onClicked: { updateFeedItems(); }
        }
        BusyIndicator {
            visible: loading
            running: loading
            platformStyle: BusyIndicatorStyle { size: 'medium' }
        }
        ToolIcon { iconId: "toolbar-view-menu" ; onClicked: (feedItemsMenu.status === DialogStatus.Closed) ? feedItemsMenu.open() : feedItemsMenu.close() }
    }

    Menu {
        id: feedItemsMenu
        visualParent: pageStack

        MenuLayout {
            ToggleShowAllItem {
                onUpdateView: {
                    updateFeedItems()
                }
            }
            MenuItem {
                text: qsTr('Mark all read')
                onClicked: {
                    var ttrss = rootWindow.getTTRSS()
                    loading = true
                    ttrss.catchUp(feed.feedId, showFeedItemsCallback)
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
                    var ttrss = rootWindow.getTTRSS()
                    loading = true
                    ttrss.updateFeedStar(feeditemMenu.feedItem.id,
                                         !feeditemMenu.feedItem.marked,
                                         showFeedItemsCallback)
                } }
            MenuItem {
                text: (feeditemMenu.feedItem !== undefined && feeditemMenu.feedItem.rss?qsTr("Unpublish"):qsTr("Publish"))
                onClicked: {
                    var ttrss = rootWindow.getTTRSS()
                    loading = true
                    ttrss.updateFeedRSS(feeditemMenu.feedItem.id,
                                         !feeditemMenu.feedItem.rss,
                                        showFeedItemsCallback)
                } }
            MenuItem {
                text: (feeditemMenu.feedItem !== undefined && feeditemMenu.feedItem.unread?qsTr("Mark read"):qsTr("Mark Unread"))
                onClicked: {
                    var ttrss = rootWindow.getTTRSS()
                    loading = true
                    ttrss.updateFeedUnread(feeditemMenu.feedItem.id,
                                           !feeditemMenu.feedItem.unread,
                                           showFeedItemsCallback)
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
