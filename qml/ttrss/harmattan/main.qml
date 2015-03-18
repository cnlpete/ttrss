/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2015  Hauke Schade
 *
 * TTRss is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * TTRss is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with TTRss; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA or see
 * http://www.gnu.org/licenses/.
 */

import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import "../models/tinytinyrss.js" as TTRss
import "../models" 1.0

PageStackWindow {
    id: rootWindow
    initialPage: mainPage

    function openFile(file, params) {
        var component = Qt.createComponent(file)
        if (component.status === Component.Ready) {
            if (params !== undefined)
                pageStack.push(component, params);
            else
                pageStack.push(component);
        } else {
            console.log("Error loading component:", component.errorString());
        }
    }
    function pageStackReplace(file, params) {
        var component = Qt.createComponent(file)
        if (component.status === Component.Ready) {
            if (params !== undefined)
                pageStack.replace(component, params);
            else
                pageStack.replace(component);
        } else {
            console.log("Error loading component:", component.errorString());
        }
    }

    function getTTRSS() {
        return TTRss;
    }

    Binding {
        target: theme
        property: "inverted"
        value: !settings.whiteTheme
    }

    Constants {
        id: constant
    }

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
            var ttrss = rootWindow.getTTRSS()
            var op = function(x) {
                return x - oldAmount + feed.unreadcount
            }
            categories.updateUnreadCountForId(feed.categoryId, op)

            // update the 'All Feeds' Category
            categories.updateUnreadCountForId(ttrss.constants['categories']['ALL'], op)

            // if there is an 'all feed items' update that aswell
            if (feeds.count > 1) {
                var m = feeds.get(0)

                if (m.isCat) { // just check to be sure

                    if (feed.isCat && m.feedId === feed.feedId && feed.unreadcount === 0) {
                        // we can not determine where to substract,
                        // but when all is 0, we can update accordingly
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
            var ttrss = rootWindow.getTTRSS();
            var op = item.unread ?
                        function(x) { return x + 1 } :
                        function(x) { return x - 1 }

            // update the feed's category
            feeds.updateUnreadCountForId(item.feedId, op)

            // update special for all feeditems category
            categories.updateUnreadCountForId(
                        ttrss.constants['categories']['SPECIAL'],
                        op)

            // if the item is new, update 'special feeds' for 'fresh articles'
            // TODO
            if (item.unread && false) {
                categories.updateUnreadCountForId(
                            ttrss.constants['categories']['SPECIAL'],
                            op)
            }

            // if item was is starred/published, update special feeds aswell
            if (item.rss) {
                categories.updateUnreadCountForId(
                            ttrss.constants['categories']['SPECIAL'],
                            op)
            }

            if (item.marked) {
                categories.updateUnreadCountForId(
                            ttrss.constants['categories']['SPECIAL'],
                            op)
            }

            // maybe check if currently viewing special feeds and update published
            // not nesseccary because this is updated by mark unread
        }

        onItemPublishedChanged: {
            var ttrss = rootWindow.getTTRSS();
            var op = item.rss ?
                        function(x) { return x + 1 } :
                        function(x) { return x - 1 }

            // if the item is unread, update 'special feeds'
            if (item.unread) {
                categories.updateUnreadCountForId(
                            ttrss.constants['categories']['SPECIAL'],
                            op)
            }

            // maybe check if currently viewing special feeds and update published
            // not nesseccary because this is updated by mark unread
        }

        onItemStarChanged: {
            var ttrss = rootWindow.getTTRSS();
            var op = item.marked ?
                        function(x) { return x + 1 } :
                        function(x) { return x - 1 }

            // if the item is unread, update 'special feeds'
            if (item.unread) {
                categories.updateUnreadCountForId(
                            ttrss.constants['categories']['SPECIAL'],
                            op)
            }

            // maybe check if currently viewing special feeds and update starred
            // not nesseccary because this is updated by mark unread
        }
    }

    Component.onCompleted: {
        theme.inverted = !settings.whiteTheme
    }
}
