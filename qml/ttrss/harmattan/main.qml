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
import com.nokia.extras 1.1
import "../models/tinytinyrss.js" as TTRss
import "../models" 1.0

PageStackWindow {
    id: rootWindow

    function openFile(file, params) {
        var component = Qt.createComponent(file)
        if (component.status === Component.Ready) {
            if (params !== undefined)
                pageStack.push(component, params);
            else
                pageStack.push(component);
        }
        else
            console.log("Error loading component:", component.errorString());
    }
    function getTTRSS() {
        return TTRss;
    }

    property bool showAll: false

    Binding {
        target: theme
        property: "inverted"
        value: !settings.whiteTheme
    }

    initialPage: mainPage

    Constants{ id: constant }

    InfoBanner {
        id: infoBanner
        topMargin: 50
    }

    MainPage {
        id: mainPage
    }

    CategoryModel {
        id: categories
    }
    FeedModel {
        id: feeds

        onFeedUnreadChanged: {
            var op = function(x) { return x - oldAmount + feed.unreadcount }
            categories.updateUnreadCountForId(feed.categoryId, op)

            // update the 'All Feeds' Category
            categories.updateUnreadCountForId(TTRss.constants['categories']['ALL'], op)

            // if there is an 'all feed items' update that aswell
            if (feeds.count > 1) {
                var m = feeds.get(0)
                if (m.isCat) // just check to be sure
                    feeds.setProperty(0, "unreadcount", op(m.unreadcount))
            }
        }
    }
    FeedItemModel {
        id: feedItems

        onItemUnreadChanged: {
            var op = item.unread ?
                        function(x) { return x + 1 } :
                        function(x) { return x - 1 }

            // update the feed's category
            feeds.updateUnreadCountForId(item.feedId, op)

            // update special for all feeditems category
            categories.updateUnreadCountForId(
                        TTRss.constants['categories']['SPECIAL'],
                        op)

            // if the item is new, update 'special feeds' for 'fresh articles'
            // TODO
            if (item.unread && false)
                categories.updateUnreadCountForId(
                            TTRss.constants['categories']['SPECIAL'],
                            op)

            // if item was is starred/published, update special feeds aswell
            if (item.rss)
                categories.updateUnreadCountForId(
                            TTRss.constants['categories']['SPECIAL'],
                            op)
            if (item.marked)
                categories.updateUnreadCountForId(
                            TTRss.constants['categories']['SPECIAL'],
                            op)

            // maybe check if currently viewing special feeds and update published
            // not nesseccary because this is updated by mark unread
        }
        onItemPublishedChanged: {
            var op = item.rss ?
                        function(x) { return x + 1 } :
                        function(x) { return x - 1 }

            // if the item is unread, update 'special feeds'
            if (item.unread)
                categories.updateUnreadCountForId(
                            TTRss.constants['categories']['SPECIAL'],
                            op)

            // maybe check if currently viewing special feeds and update published
            // not nesseccary because this is updated by mark unread
        }
        onItemStarChanged: {
            var op = item.marked ?
                        function(x) { return x + 1 } :
                        function(x) { return x - 1 }

            // if the item is unread, update 'special feeds'
            if (item.unread)
                categories.updateUnreadCountForId(
                            TTRss.constants['categories']['SPECIAL'],
                            op)

            // maybe check if currently viewing special feeds and update starred
            // not nesseccary because this is updated by mark unread
        }
    }

    Component.onCompleted: {
        theme.inverted = !settings.whiteTheme
    }
}
