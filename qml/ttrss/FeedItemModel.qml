// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

ListModel {
    id: root

    property int selectedIndex: -1
    property variant feed
    property int continuation: 0
    property bool hasMoreItems: true

    signal itemUnreadChanged(variant item)
    signal itemPublishedChanged(variant item)
    signal itemStarChanged(variant item)

    function update() {
        var ttrss = rootWindow.getTTRSS();
        ttrss.updateFeedItems(feed.feedId, feed.isCat, continuation, function() {
                                  root.load();
                              })
    }

    function load() {
        var ttrss = rootWindow.getTTRSS();
        var feeditems = ttrss.getFeedItems(feed.feedId);
        var showAll = ttrss.getShowAll();
        rootWindow.showAll = showAll;
//        root.clear(); clearing is done by caller instead, so this is more like an 'append' and can be used by loadMore aswell
        var now = new Date();

        if (feeditems && feeditems.length) {
            root.continuation += feeditems.length
            for(var feeditem = 0; feeditem < feeditems.length; feeditem++) {
                var subtitle = feeditems[feeditem].content || ""
                subtitle = subtitle.replace(/\n/gi, " ")
                subtitle = subtitle.replace(/<[\/]?[a-zA-Z][^>]*>/gi, "")
                subtitle = unescape(subtitle.replace(/<!--.*-->/gi, ""))
                if (subtitle.length > 102)
                    subtitle = subtitle.substring(0,100) + "..."
                subtitle = "<body>" + subtitle + "</body>"

                var title = feeditems[feeditem].title
                title = title.replace(/<br.*>/gi, "")
                title = "<body>" + unescape(title.replace(/\n/gi, "")) + "</body>"

                var d = new Date(feeditems[feeditem].updated * 1000)
                var formatedDate = Qt.formatDate(d, Qt.DefaultLocaleShortDate)
                if (d.getDate() === now.getDate() && d.getMonth() === now.getMonth() && d.getFullYear() === now.getFullYear())
                    formatedDate = qsTr('Today')

                var url = feeditems[feeditem].link
                url = url.replace(/^\s\s*/, '').replace(/\s\s*$/, '')

                var labels = []
                var labelcount = feeditems[feeditem].labels ? feeditems[feeditem].labels.length : 0
                for (var l = 0; l < labelcount; l++) {
                    labels[l] = {
                        'id': feeditems[feeditem].labels[l][0],
                        'fgcolor': (feeditems[feeditem].labels[l][2] == "" ? "black" : feeditems[feeditem].labels[l][2]),
                        'bgcolor': (feeditems[feeditem].labels[l][3] == "" ? "white" : feeditems[feeditem].labels[l][3]),
                        'text': feeditems[feeditem].labels[l][1]
                    }
                }

                var modelEntry = {
                    title:      ttrss.html_entity_decode(title, 'ENT_QUOTES'),
                    content:    feeditems[feeditem].content,
                    subtitle:   ttrss.html_entity_decode(subtitle, 'ENT_QUOTES'),
                    id:         feeditems[feeditem].id,
                    unread:     !!feeditems[feeditem].unread,
                    marked:     !!feeditems[feeditem].marked,
                    rss:        feeditems[feeditem].published,
                    url:        url,
                    date:       formatedDate,
                    attachments:feeditems[feeditem].attachments,
                    feedId:     feeditems[feeditem].feed_id,
                    labels:     labels
                }

                if (settings.feeditemsOrder === 0)
                    root.append(modelEntry)
                else
                    root.insert(0, modelEntry)
            }
        }
        else
            hasMoreItems = false
    }

    function getSelectedItem() {
        if (root.selectedIndex === -1)
            return null;

        return root.get(root.selectedIndex)
    }

    function toggleRead() {
        var ttrss = rootWindow.getTTRSS()
        var m = root.get(root.selectedIndex)
        ttrss.updateFeedUnread(m.id,
                               !m.unread,
                               function() {
                                   var newState = !m.unread
                                   root.setProperty(root.selectedIndex, "unread", newState)
                                   if (!rootWindow.showAll)
                                       root.continuation += newState ? +1 : -1
                                   root.itemUnreadChanged(m)
                               })
    }

    function toggleStar() {
        var ttrss = rootWindow.getTTRSS()
        var m = root.get(root.selectedIndex)
        ttrss.updateFeedStar(m.id,
                             !m.marked,
                             function() {
                                 root.setProperty(root.selectedIndex, "marked", !m.marked)
                                 root.itemStarChanged(m)
                             })
    }

    function togglePublished() {
        var ttrss = rootWindow.getTTRSS()
        var m = root.get(root.selectedIndex)
        ttrss.updateFeedRSS(m.id,
                            !m.rss,
                            function() {
                                root.setProperty(root.selectedIndex, "rss", !m.rss)
                                root.itemPublishedChanged(m)
                            })
    }

    function catchUp() {
        var ttrss = rootWindow.getTTRSS()
        ttrss.catchUp(feed.feedId, function() {
                          for(var feeditem = 0; feeditem < root.count; feeditem++) {
                              var item = root.get(feeditem)
                              if (item.unread) {
                                  root.setProperty(feeditem, "unread", false)
                                  root.itemUnreadChanged(item)
                              }
                          }
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
}
