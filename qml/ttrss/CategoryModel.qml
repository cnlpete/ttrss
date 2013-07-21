// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

ListModel {
    id: root

    property int selectedIndex: -1

    function update() {
        rootWindow.loading++
        var ttrss = rootWindow.getTTRSS();
        ttrss.updateCategories(function() {
                                   rootWindow.loading--
                                   root.load();
                               });
    }

    function load() {
        var ttrss = rootWindow.getTTRSS()
        var showAll = ttrss.getShowAll()
        rootWindow.showAll = showAll
        var categories = ttrss.getCategories()
        root.clear()
        if(categories && categories.length) {
            var totalUnreadCount = 0

            //first add all the categories with unread itens
            for(var category = 0; category < categories.length; category++) {
                if (categories[category].id >= 0)
                    totalUnreadCount += categories[category].unread;

                var title = ttrss.html_entity_decode(categories[category].title,'ENT_QUOTES')
                if (categories[category].id == ttrss.constants['categories']['ALL'])
                    title = constant.allFeeds
                if (categories[category].id == ttrss.constants['categories']['LABELS'])
                    title = constant.labelsCategory
                if (categories[category].id == ttrss.constants['categories']['SPECIAL'])
                    title = constant.specialCategory
                if (categories[category].id == ttrss.constants['categories']['UNCATEGORIZED'])
                    title = constant.uncategorizedCategory

                root.append({
                                title:       title,
                                unreadcount: categories[category].unread,
                                categoryId:  categories[category].id
                            });
            }

            if(totalUnreadCount > 0 || showAll) {
                //Add the "All" category
                root.insert(0, {
                                title: constant.allFeeds,
                                categoryId: ttrss.constants['categories']['ALL'],
                                unreadcount: totalUnreadCount,
                            });
            }
        }
    }

    function getSelectedItem() {
        if (root.selectedIndex === -1)
            return null;

        return root.get(root.selectedIndex)
    }

    function updateSelectedUnreadCount(op) {
        var m = root.getSelectedItem()
        root.setProperty(root.selectedIndex, "unreadcount", op(m.unreadcount))
    }

    function updateUnreadCountForId(id, op) {
        for(var category = 0; category < root.count; category++) {
            var m = root.get(category)
            if (m.categoryId == id) {
                root.setProperty(category, "unreadcount", op(m.unreadcount))
                break
            }
        }
    }
}
