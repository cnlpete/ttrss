//Copyright Hauke Schade, 2012-2014
//
//This file is part of TTRss.
//
//TTRss is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the
//Free Software Foundation, either version 2 of the License, or (at your option) any later version.
//TTRss is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with TTRss (on a Maemo/Meego system there is a copy
//in /usr/share/common-licenses. If not, see http://www.gnu.org/licenses/.

//import QtQuick 1.1 // harmattan
import QtQuick 2.0 // sailfish

ListModel {
    id: root

    property int selectedIndex: -1
    property variant category

    signal feedUnreadChanged(variant feed, int oldAmount)

    function update() {
        var ttrss = rootWindow.getTTRSS();
        ttrss.updateFeeds(root.category.categoryId, function() {
            root.load()
        })
    }

    function load() {
        var ttrss = rootWindow.getTTRSS()
        var feeds = ttrss.getFeeds(category.categoryId)
        rootWindow.showAll = ttrss.getShowAll()
        root.clear()

        if(feeds && feeds.length) {
            //First add feed with unread items
            var totalUnreadCount = 0
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

                    // note: cat_id is infact the id the feed originally was in, not the special id of All Feeds or similar
                    root.append({
                                    title:        title,
                                    unreadcount:  parseInt(feeds[feed].unread),
                                    feedId:       parseInt(feeds[feed].id),
                                    categoryId:   parseInt(feeds[feed].cat_id),
                                    isCat:        false,
                                    icon:         settings.displayIcons ? ttrss.getIconUrl(feeds[feed].id) : ''
                                })
                    totalUnreadCount += parseInt(feeds[feed].unread)
                }
            }
            if (root.count >= 2 && root.category.categoryId !== ttrss.constants['categories']['SPECIAL'])
                root.insert(0, {
                                title:        constant.allArticles,
                                unreadcount:  totalUnreadCount,
                                feedId:       parseInt(root.category.categoryId),
                                categoryId:   parseInt(root.category.categoryId),
                                isCat:        true,
                                icon:         ''
                            })
        }
    }

    function getTotalUnreadItems() {
        if (root.count <= 0)
            return 0
        else {
            var m = root.get(0)
            return m.unreadcount
        }
    }

    function getSelectedItem() {
        if (root.selectedIndex === -1)
            return null;

        return root.get(root.selectedIndex)
    }

    function catchUp() {
        var ttrss = rootWindow.getTTRSS()
        var m = root.getSelectedItem()
        ttrss.catchUp(m.feedId, function() {
                          var oldAmount = m.unreadcount
                          root.setProperty(selectedIndex, "unreadcount", 0)
                          root.feedUnreadChanged(m, oldAmount)
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
}
