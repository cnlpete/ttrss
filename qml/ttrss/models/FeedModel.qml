/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2016  Hauke Schade
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

//import QtQuick 1.1 // harmattan
import QtQuick 2.0 // sailfish

ListModel {
    id: root

    property int selectedIndex: -1
    property variant category
    property var categories

    signal feedUnreadChanged(variant feed, int oldAmount)

    function update() {
        var ttrss = rootWindow.getTTRSS();
        var catId = root.category.categoryId;

        ttrss.updateFeeds(catId, function(successful, errorMessage) {
            if (successful) {
                root.load()
            }

            // TODO Add a callback to update() which can be used to display
            // errorMessage.
        });
    }

    /** @private */
    function load() {
        var ttrss = rootWindow.getTTRSS()
        var feeds = ttrss.getFeeds(category.categoryId)
        settings.showAll = ttrss.getShowAll()
        root.clear()

        if(feeds && feeds.length) {
            //First add feed with unread items
            var totalUnreadCount = 0

            var now = new Date()
            var secsUnix = now.getTime() / 1000
            var lessThanAnHourAgo = secsUnix - 3600
            var today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
            var todayUnix = today.getTime() / 1000

            for(var feed = 0; feed < feeds.length; feed++) {
                if (feeds[feed]) {
                    var title = ttrss.html_entity_decode(feeds[feed].title, 'ENT_QUOTES')

                    if (feeds[feed].id == ttrss.constants['feeds']['archived']) {
                        title = constant.archivedArticles
                    } else if (feeds[feed].id == ttrss.constants['feeds']['starred']) {
                        title = constant.starredArticles
                    } else if (feeds[feed].id == ttrss.constants['feeds']['published']) {
                        title = constant.publishedArticles
                    } else if (feeds[feed].id == ttrss.constants['feeds']['fresh']) {
                        title = constant.freshArticles
                    } else if (feeds[feed].id == ttrss.constants['feeds']['all']) {
                        title = constant.allArticles
                    } else if (feeds[feed].id == ttrss.constants['feeds']['recently']) {
                        title = constant.recentlyArticles
                    }

                    var formatedDate = ''
                    if (feeds[feed].last_updated !== undefined) {
                        var lastUpdated = feeds[feed].last_updated
                        if (lastUpdated > lessThanAnHourAgo) {
                            formatedDate = qsTr('Less than an hour ago')
                        }
                        else if (lastUpdated > todayUnix) {
                            formatedDate = qsTr('Today')
                        }
                        else {
                            var d = new Date(feeds[feed].last_updated * 1000)
                            formatedDate = Qt.formatDate(d, Qt.DefaultLocaleShortDate)
                        }
                    }

                    // Note: cat_id is infact the id the feed originally was in,
                    // not the special id of All Feeds or similar
                    root.append({
                                    title:       title,
                                    unreadcount: parseInt(feeds[feed].unread),
                                    feedId:      parseInt(feeds[feed].id),
                                    categoryId:  parseInt(feeds[feed].cat_id),
                                    isCat:       false,
                                    icon:        settings.displayIcons ? feeds[feed].icon_url : '',
                                    lastUpdated: formatedDate
                                })
                    totalUnreadCount += parseInt(feeds[feed].unread)
                }
            }
            if (root.count >= 2 && root.category.categoryId !== ttrss.constants['categories']['SPECIAL']) {
                root.insert(0, {
                                title:       constant.allArticles,
                                unreadcount: totalUnreadCount,
                                feedId:      parseInt(root.category.categoryId),
                                categoryId:  parseInt(root.category.categoryId),
                                isCat:       true,
                                icon:        '',
                                lastUpdated: ''
                            })
            }
        }
    }

    function getTotalUnreadItems() {
        if (root.count <= 0) {
            return 0
        } else {
            var m = root.get(0)
            return m.unreadcount
        }
    }

    function getSelectedItem() {
        if (root.selectedIndex === -1) {
            return null;
        }

        return root.get(root.selectedIndex)
    }

    function catchUp() {
        var ttrss = rootWindow.getTTRSS()
        var m = root.getSelectedItem()
        ttrss.catchUp(m.feedId, m.isCat, function(successful, errorMessage) {
            if (successful) {
                var oldAmount = m.unreadcount
                root.setProperty(selectedIndex, "unreadcount", 0)
                root.feedUnreadChanged(m, oldAmount)
            }

            // TODO Add a callback to catchUp() which can be used to display
            // errorMessage.
        })
    }

    function unsetIcon(index) {
        root.setProperty(index, "icon", '')
    }

    function updateSelectedUnreadCount(op) {
        var sel = root.selectedIndex
        var m = root.getSelectedItem()
        var newUnreadCount = m.unreadcount
        root.setProperty(sel, "unreadcount", op(m.unreadcount))
        root.feedUnreadChanged(m, newUnreadCount)
    }

    function updateUnreadCountForId(id, op) {
        for(var feed = 0; feed < root.count; feed++) {
            var m = root.get(feed)
            if (m.feedId == id) {
                var newUnreadCount = m.unreadcount
                root.setProperty(feed, "unreadcount", op(m.unreadcount))
                root.feedUnreadChanged(m, newUnreadCount)
                break
            }
        }
    }

    onFeedUnreadChanged: {
        var ttrss = rootWindow.getTTRSS()
        var op = function(x) {
            return x - oldAmount + feed.unreadcount
        }
        categories.updateUnreadCountForId(feed.categoryId, op)

        // update the 'All Feeds' Category
        categories.updateUnreadCountForId(ttrss.constants['categories']['ALL'], op)

        // if there is an 'all feed items' update that aswell
        if (root.count > 1) {
            var m = root.get(0)

            if (m.isCat) { // just check to be sure

                if (feed.isCat && m.feedId === feed.feedId && feed.unreadcount === 0) {
                    // we can not determine where to substract,
                    // but when all is 0, we can update accordingly
                    for (var i = 1; i < root.count; i++) {
                        root.setProperty(i, "unreadcount", 0)
                    }
                } else {
                    root.setProperty(0, "unreadcount", op(m.unreadcount))
                }
            }
        }
    }
}
