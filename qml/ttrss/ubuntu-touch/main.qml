import QtQuick 2.0
import Ubuntu.Components 0.1
import "../models/tinytinyrss.js" as TTRss
import "../models" 1.0
 
/*!
    brief MainView with a Label and Button elements.
*/
 
MainView {
    id: rootWindow
    applicationName: Qt.application.name
    /* Disabled until QTBUG-43555 is fixed
    automaticOrientation: true
    */
 
    width: units.gu(45)
    height: units.gu(75)
    useDeprecatedToolbar: false
 
    PageStack {
        id: pageStack
        Component.onCompleted: push(mainPage)

        MainPage {
            id: mainPage
        }
    }

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
