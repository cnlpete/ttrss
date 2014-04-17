/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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


