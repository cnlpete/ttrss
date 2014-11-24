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

    /**
     * Mark all items above an index as read, i.e. item with an index less than
     * the given index.
     * @param {int} The index above which items should be marked read.
     */
    function markAllAboveAsRead(index) {
        var ttrss = rootWindow.getTTRSS()

        var ids = ""
        for (var i = 0; i < index; i++) {
            var item = root.get(i)
            // Only include items that are unread.
            if (item.unread) {
                ids += item.id + ","
            }
        }

        if (ids === "") {
            // All regarding items are already marked as read.
            return
        }

        // trim of last ,
        ids = ids.slice(0,-1)

        ttrss.updateFeedUnread(ids, false, function(successful, errorMessage) {
            if (successful) {
                for (var i = 0; i < index; i++) {
                    var item = root.get(i)
                    if (item.unread) {
                        root.setProperty(i, "unread", false)
                        if (!rootWindow.showAll) {
                            root.continuation -= 1
                        }
                        root.itemUnreadChanged(item)
                    }
                }
            }

            // TODO Add a callback to markAllAboveAsRead() which can be used to
            // display errorMessage.
        })
    }

    function markAllLoadedAsRead() {
        markAllAboveAsRead(root.count)
    }

    /**
     * Toggle unread/read of currently selected item.
     * @param {function} A callback function with parameters boolean (indicating
     *     success), string (an optional error message) and boolean (true if
     *     unread; false if read).
     */
    function toggleRead(callback) {
        var ttrss = rootWindow.getTTRSS()
        var index = root.selectedIndex
        var item = getSelectedItem()
        var newState = !item.unread

        ttrss.updateFeedUnread(item.id, newState, function(successful,
                                                           errorMessage) {
            if (successful) {
                if (!rootWindow.showAll) {
                    root.continuation += newState ? +1 : -1
                }

                root.setProperty(index, "unread", newState)
                root.itemUnreadChanged(item)
            }

            callback(successful, errorMessage, item.unread)
        })
    }

    /**
     * Toggle starred/unstarred of currently selected item.
     * @param {function} A callback function with parameters boolean (indicating
     *     success), string (an optional error message) and boolean (true if
     *     starred; false if unstarred).
     */
    function toggleStar(callback) {
        var ttrss = rootWindow.getTTRSS()
        var index = root.selectedIndex
        var item = getSelectedItem()
        var newState = !item.marked

        ttrss.updateFeedStar(item.id, newState, function(successful,
                                                         errorMessage) {
            if (successful) {
                root.setProperty(index, "marked", newState)
                root.itemStarChanged(item)
            }

            callback(successful, errorMessage, item.marked)
        })
    }

    /**
     * Toggle published/unpublished of currently selected item.
     * @param {function} A callback function with parameters boolean (indicating
     *     success), string (an optional error message) and boolean (true if
     *     published; false if unpublished).
     */
    function togglePublished(callback) {
        var ttrss = rootWindow.getTTRSS()
        var index = root.selectedIndex
        var item = getSelectedItem()
        var newState = !item.rss

        ttrss.updateFeedRSS(item.id, newState, function(successful,
                                                         errorMessage) {
            if (successful) {
                root.setProperty(index, "rss", newState)
                root.itemPublishedChanged(item)
            }

            callback(successful, errorMessage, item.rss)
        })
    }

    function updateNote(note, callback) {
        var ttrss = rootWindow.getTTRSS()
        var index = root.selectedIndex
        var item = getSelectedItem()

        ttrss.updateFeedNote(item.id, note, function(successful, errorMessage) {
            if (successful) {
                root.setProperty(index, "note", note)
            }

            callback(successful, errorMessage)
        })
    }

    function getLabels(callback) {
        var ttrss = rootWindow.getTTRSS()
        var item = getSelectedItem()

        ttrss.getLabels(item.id, function(successful, errorMessage, labels) {
            if (!successful) {
                callback(false, errorMessage)
                return
            }
            if (!labels || labels.length === 0) {
                callback(true, "", [])
                return
            }

            var i
            var j

            // This is in O(nm) where n is the number of labels defined and
            // m the number of labels checked. It's unefficient, but it should
            // be fast enough for us.
            for (i = 0; i < labels.length; ++i) {
                labels[i].checked = false

                for (j = 0; j < item.labels.count; ++j) {
                    if(labels[i].id === item.labels.get(j).id) {
                        labels[i].checked = true
                        break
                    }
                }
            }

            callback(true, "", labels)
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

        ttrss.updateLabels(item.id, function(successful, errorMessage, labels) {
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
