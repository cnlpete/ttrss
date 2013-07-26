// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

ListModel {
    id: root

    property int selectedIndex: -1
    property variant category

    signal feedUnreadChanged(variant feed, int oldAmount)

    function update() {
        var ttrss = rootWindow.getTTRSS();
        ttrss.updateFeeds(root.category.categoryId, function() {
                              root.load();
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
                                    unreadcount:  feeds[feed].unread,
                                    feedId:       feeds[feed].id,
                                    categoryId:   feeds[feed].cat_id,
                                    isCat:        false,
                                    icon:         settings.displayIcons ? ttrss.getIconUrl(feeds[feed].id) : ''
                                })
                    totalUnreadCount += feeds[feed].unread
                }
            }
            if (root.count >= 2 && root.category.categoryId !== ttrss.constants['categories']['SPECIAL'])
                root.insert(0, {
                                title:        constant.allArticles,
                                unreadcount:  totalUnreadCount,
                                feedId:       root.category.categoryId,
                                categoryId:   root.category.categoryId,
                                isCat:        true,
                                icon:         ''
                            })
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
                          root.setProperty(m, "unreadcount", 0)
                          root.feedUnreadChanged(m, oldAmount)
                      })
    }

    function unsetIcon(index) {
        root.setProperty(index, "icon", '')
    }
    function updateSelectedUnreadCount(op) {
        var m = root.getSelectedItem()
        var newUnreadCount = m.unreadcount
        root.setProperty(root.selectedIndex, "unreadcount", op(m.unreadcount))
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
