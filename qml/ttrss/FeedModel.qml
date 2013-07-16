// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

ListModel {
    id: root

    property int selectedIndex: -1
    property bool loading: false
    property int numStatusUpdates
    property variant category

    function update() {
        loading = true;
        var ttrss = rootWindow.getTTRSS();
        console.log(ttrss.dump(category))
        numStatusUpdates = ttrss.getNumStatusUpdates();
        ttrss.updateFeeds(root.category.categoryId, function() {
                              loading = false;
                              root.load();
                          })
    }

    function load() {
        var ttrss = rootWindow.getTTRSS();
        var feeds = ttrss.getFeeds(category.categoryId);
        var showAll = ttrss.getShowAll();
        rootWindow.showAll = showAll;
        root.clear();

        if(feeds && feeds.length) {
            //First add feed with unread items
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
                                    icon:         settings.displayIcons ? ttrss.getIconUrl(feeds[feed].id) : ''
                                });
                }
            }
        }
    }

    function getSelectedItem() {
        if (root.selectedIndex === -1)
            return null;

        return root.get(root.selectedIndex)
    }

    function setRead() {
        var m = root.getSelectedItem()
        root.setProperty(root.selectedIndex, "unreadcount", op(m.unreadcount))
    }
}
