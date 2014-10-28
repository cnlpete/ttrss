/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2014  Hauke Schade
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
    property variant feed
    property int continuation: 0
    property bool hasMoreItems: false

    property var categories

    signal itemUnreadChanged(variant item)
    signal itemPublishedChanged(variant item)
    signal itemStarChanged(variant item)

    function update() {
        var ttrss = rootWindow.getTTRSS();
        ttrss.updateFeedItems(feed.feedId, feed.isCat, continuation,
                              function(successful, errorMessage) {
                                  if (successful) {
                                      root.load()
                                  }

                                  // TODO Add a callback to update() which can
                                  // be used to display errorMessage.
                              });
    }

    /** @private */
    function load() {
        var ttrss = rootWindow.getTTRSS();
        var feeditems = ttrss.getFeedItems(feed.feedId);

        var showAll = ttrss.getShowAll();
        rootWindow.showAll = showAll;

        //root.clear(); clearing is done by caller instead, so this is more like an 'append' and can be used by loadMore aswell

        var now = new Date();

        if (feeditems && feeditems.length) {
            root.continuation += feeditems.length

            for(var feeditem = 0; feeditem < feeditems.length; feeditem++) {

                var subtitle = feeditems[feeditem].content || ""
                subtitle = subtitle.replace(/\n/gi, " ")
                subtitle = subtitle.replace(/<[\/]?[a-zA-Z][^>]*>/gi, "")
                subtitle = unescape(subtitle.replace(/<!--.*-->/gi, ""))
                subtitle = "<body>" + subtitle + "</body>"

                var title = feeditems[feeditem].title
                title = title.replace(/<br.*>/gi, "")
                title = "<body>" + unescape(title.replace(/\n/gi, "")) + "</body>"

                var d = new Date(feeditems[feeditem].updated * 1000)
                var formatedDate = Qt.formatDate(d, Qt.DefaultLocaleShortDate)
                if (d.getDate() === now.getDate()
                        && d.getMonth() === now.getMonth()
                        && d.getFullYear() === now.getFullYear()) {
                    formatedDate = qsTr('Today')
                }

                var url = feeditems[feeditem].link
                url = url.replace(/^\s\s*/, '').replace(/\s\s*$/, '')

                var labels = []
                var labelcount = feeditems[feeditem].labels ? feeditems[feeditem].labels.length : 0
                for (var l = 0; l < labelcount; l++) {
                    labels[l] = {
                        'id': parseInt(feeditems[feeditem].labels[l][0]),
                        'caption': feeditems[feeditem].labels[l][1],
                        'fg_color': (feeditems[feeditem].labels[l][2] === "" ? "black" : feeditems[feeditem].labels[l][2]),
                        'bg_color': (feeditems[feeditem].labels[l][3] === "" ? "white" : feeditems[feeditem].labels[l][3])
                    }
                }

                var modelEntry = {
                    title:      ttrss.html_entity_decode(title, 'ENT_QUOTES'),
                    content:    feeditems[feeditem].content,
                    subtitle:   ttrss.html_entity_decode(subtitle, 'ENT_QUOTES'),
                    id:         parseInt(feeditems[feeditem].id),
                    unread:     !!feeditems[feeditem].unread,
                    marked:     !!feeditems[feeditem].marked,
                    rss:        feeditems[feeditem].published,
                    url:        url,
                    date:       formatedDate,
                    attachments:feeditems[feeditem].attachments,
                    note:       feeditems[feeditem].note,
                    feedId:     parseInt(feeditems[feeditem].feed_id),
                    feedTitle:  ttrss.html_entity_decode(feeditems[feeditem].feed_title, 'ENT_QUOTES'),
                    labels:     labels,
                    icon:       settings.displayIcons ? ttrss.getIconUrl(feeditems[feeditem].feed_id) : ''
                }

                if (settings.feeditemsOrder === 0) {
                    root.append(modelEntry)
                } else {
                    root.insert(0, modelEntry)
                }
            }

            // QUICKFIX FIXME the ttrss api will always query exactly 200 elements
            // so if we get a different amount there are none left
            // This holds for API level 6 or later; before the limit was 60
            if (feeditems.length === 200) {
                hasMoreItems = true
            }
        } else {
            hasMoreItems = false
        }
    }

    function getSelectedItem() {
        if (root.selectedIndex === -1) {
            return null;
        }

        return root.get(root.selectedIndex)
    }

    function toggleRead() {
        var ttrss = rootWindow.getTTRSS()
        var sel = root.selectedIndex
        var m = getSelectedItem()
        ttrss.updateFeedUnread(m.id, !m.unread, function(successful, errorMessage) {
            if (successful) {
                var newState = !m.unread
                root.setProperty(sel, "unread", newState)
                if (!rootWindow.showAll) {
                    root.continuation += newState ? +1 : -1
                }
                root.itemUnreadChanged(m)
            }

            // TODO Add a callback to toggleRead() which can be used to display
            // errorMessage.
        })
    }

    function toggleStar() {
        var ttrss = rootWindow.getTTRSS()
        var sel = root.selectedIndex
        var m = getSelectedItem()
        ttrss.updateFeedStar(m.id, !m.marked, function(successful, errorMessage) {
            if (successful) {
                root.setProperty(sel, "marked", !m.marked)
                root.itemStarChanged(m)
            }

            // TODO Add a callback to toggleStar() which can be used to display
            // errorMessage.
        })
    }

    function togglePublished() {
        var ttrss = rootWindow.getTTRSS()
        var sel = root.selectedIndex
        var m = getSelectedItem()
        ttrss.updateFeedRSS(m.id, !m.rss, function(successful, errorMessage) {
            if (successful) {
                root.setProperty(sel, "rss", !m.rss)
                root.itemPublishedChanged(m)
            }

            // TODO Add a callback to togglePublished() which can be used to
            // display errorMessage.
        })
    }

    function getLabels(callback) {
        var ttrss = rootWindow.getTTRSS()
        var item = getSelectedItem()

        ttrss.getLabels(item.id, function(successful, errorMessage, labels) {
            callback(successful, errorMessage, labels)
        })
    }

    function setLabel(labelId, assign, callback) {
        var ttrss = rootWindow.getTTRSS()
        var item = getSelectedItem()

        ttrss.setLabel(item.id, labelId, assign,
                       function(successful, errorMessage) {
                           callback(successful, errorMessage);
                       })
    }

    function updateLabels(callback) {
        var ttrss = rootWindow.getTTRSS()
        var item = getSelectedItem()

        ttrss.getLabels(item.id, function(successful, errorMessage, labels) {
            if (!successful) {
                callback(false, errorMessage)
                return
            }

            item.labels.clear()

            for (var i = 0; i < labels.length; ++i) {
                if (!labels[i].checked) {
                    continue
                }

                item.labels.append({
                    'id': parseInt(labels[i].id),
                    'caption': labels[i].caption,
                    'fg_color': (labels[i].fg_color === "" ? "black" : labels[i].fg_color),
                    'bg_color': (labels[i].bg_color === "" ? "white" : labels[i].bg_color)
                })
            }

            callback(true, "", item.labels)
        })
    }

    function catchUp() {
        var ttrss = rootWindow.getTTRSS()
        ttrss.catchUp(feed.feedId, feed.isCat, function(successful, errorMessage) {
            if (successful) {
                for(var index = 0; index < root.count; index++) {
                    var feedItem = root.get(index)
                    if (feedItem.unread) {
                        root.setProperty(index, "unread", false)
                        root.itemUnreadChanged(feedItem)
                    }
                }
            }

            // TODO Add a callback to catchUp() which can be used to display
            // errorMessage.
        })
    }

    function hasPrevious() {
        return root.selectedIndex > 0
    }

    function selectPrevious() {
        root.selectedIndex = Math.max(root.selectedIndex - 1, 0)
        return root.selectedIndex
    }

    function hasNext() {
        return root.selectedIndex < root.count - 1
    }

    function selectNext() {
        root.selectedIndex = Math.min(root.selectedIndex + 1, root.count - 1)
        return root.selectedIndex
    }

    onItemUnreadChanged: {
        var ttrss = rootWindow.getTTRSS();
        var op = item.unread ?
                    function(x) { return x + 1 } :
                    function(x) { return x - 1 }

        // update the feed's category
        feedModel.updateUnreadCountForId(item.feedId, op)

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
