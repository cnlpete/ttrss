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

import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "../models/tinytinyrss.js" as TTRss
import "../models" 1.0

ApplicationWindow
{
    id: rootWindow
    initialPage: Component { MainPage { } }
    cover: Qt.resolvedUrl("cover/SimpleCover.qml")

    function getTTRSS() {
        return TTRss;
    }

    property bool showAll: false

    Constants{ id: constant }

    Notification {
        id: notification
    }

    CategoryModel {
        id: categories
    }
    FeedModel {
        id: feeds

        onFeedUnreadChanged: {
            var op = function(x) { return x - oldAmount + feed.unreadcount }
            categories.updateUnreadCountForId(feed.categoryId, op)
            //console.log("updating category with id: " + feed.categoryId + " op is " + op(0))

            // update the 'All Feeds' Category
            categories.updateUnreadCountForId(TTRss.constants['categories']['ALL'], op)
            //console.log("updating special cat with id: " + TTRss.constants['categories']['ALL'] + " op is " + op(0))

            // if there is an 'all feed items' update that aswell
            if (feeds.count > 1) {
                var m = feeds.get(0)

                if (m.isCat) { // just check to be sure

                    if (feed.isCat && m.feedId == feed.feedId && feed.unreadcount == 0) {
                        // we can not determine where to substract, but when all is 0, we can update accordingly
                        for (var i = 1; i < feeds.count; i++) {
                            feeds.setProperty(i, "unreadcount", 0)
                        }
                    }
                    else {
                        feeds.setProperty(0, "unreadcount", op(m.unreadcount))
                    }
                }
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
            //console.log("updating feed with id: " + item.feedId + " op is " + op(0))

            // update special for all feeditems category
            categories.updateUnreadCountForId(
                        TTRss.constants['categories']['SPECIAL'],
                        op)
            //console.log("updating special cat with id: " + TTRss.constants['categories']['SPECIAL'] + " op is " + op(0))

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
}


