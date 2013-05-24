//Copyright Hauke Schade, 2012-2013
//
//This file is part of TTRss.
//
//TTRss is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the
//Free Software Foundation, either version 2 of the License, or (at your option) any later version.
//TTRss is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with TTRss (on a Maemo/Meego system there is a copy
//in /usr/share/common-licenses. If not, see http://www.gnu.org/licenses/.

import QtQuick 1.1
import com.nokia.meego 1.0
import QtWebKit 1.0

Page {
    id: itemPage
    tools: itemTools
    property string feedId:         ""
    property string articleId:      ""
    property string pageTitle:      ""
    property string url:            ""
    property bool   loading:        false
    property bool   marked:         false
    property bool   unread:         true
    property bool   rss:            false
    property bool   previousId:     false
    property bool   nextId:         false

    anchors.margins: 0

    Flickable {
        id: flick
        width: parent.width;
        height: parent.height
        contentWidth: itemView.width
        contentHeight: itemView.height
        interactive: true
        clip: true
        anchors {
            top: pageHeader.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }


//        signal newWindowRequested(string url)

        WebView {
            id: itemView
            transformOrigin: Item.TopLeft
            settings.standardFontFamily: "Arial"
            preferredWidth: flick.width
            preferredHeight: flick.height
            scale: 1
            onLoadFinished: {
                evaluateJavaScript("\
                    document.body.style.backgroundColor='" + constant.colorWebviewBG + "';\
                    document.body.style.color='" + constant.colorWebviewText + "';\
                ");
            }


            onUrlChanged: {
                if (url != "") {
                    Qt.openUrlExternally(url)
                    // BUGFIX: the url is still changed, so i need to change it back to the original content...
                    showFeedItem()
                }
            }
        }
    }

    ScrollDecorator {
        flickableItem: flick
    }

    BusyIndicator {
        id: busyindicator1
        visible: loading
        running: loading
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        platformStyle: BusyIndicatorStyle { size: 'large' }
    }

    function showFeedItem() {
        var ttrss = rootWindow.getTTRSS()
        numStatusUpdates = ttrss.getNumStatusUpdates()
        var data = ttrss.getFeedItem(feedId, articleId)

        if (data) {
            var content = data.content.replace('target="_blank"', '')
            if (!content.match(/<body>/gi)) {
                // not yet html, detect urls
                console.log('doing link detection on ' + content)
                var regex = /(([a-z]+:\/\/)?(([a-z0-9\-]+\.)+([a-z]{2}|aero|arpa|biz|com|coop|edu|gov|info|int|jobs|mil|museum|name|nato|net|org|pro|travel|local|internal))(:[0-9]{1,5})?(\/[a-z0-9_\-\.~]+)*(\/([a-z0-9_\-\.]*)(\?[a-z0-9+_\-\.%=&amp;]*)?)?(#[a-zA-Z0-9!$&'()*+.=-_~:@/?]*)?)(\s+|$)/gi;
                content = content.replace(regex, "<a href='$1'>$1</a> ")
            }

            itemView.html = content
            url         = data.link
            pageTitle   = data.title
            pageTitle   = pageTitle.replace(/<br.*>/gi, "")
            pageTitle   = pageTitle.replace(/\n/gi, "")

            marked      = data.marked
            unread      = data.unread
            rss         = data.published

            previousId  = ttrss.getPreviousFeedId(feedId, articleId)
            nextId      = ttrss.getNextFeedId(feedId, articleId)

            if (settings.autoMarkRead && unread) {
                loading = true
                ttrss.updateFeedUnread(articleId, false, callback)
            }
        }
    }

    function callback() {
        var ttrss = rootWindow.getTTRSS();
        var data = ttrss.getFeedItem(feedId, articleId);
        loading = false
        if (data) {
            marked      = data.marked
            unread      = data.unread
            rss         = data.published
        }
    }

    onArticleIdChanged: {
        showFeedItem();
    }

    onVisibleChanged: {
        if (visible)
            showFeedItem();
    }

    Binding {
        target: itemView
        property: "settings.defaultFontSize"
        value: settings.webviewFontSize
    }

    Component.onCompleted: {
        itemView.settings.defaultFontSize = settings.webviewFontSize
        showFeedItem();
    }

    onLoadingChanged: {
        if (loading && itemMenu.status !== DialogStatus.Closed)
             itemMenu.close()
    }

    PageHeader {
        id: pageHeader
        text: pageTitle
    }

    ToolBarLayout {
        id: itemTools

        ToolIcon { iconId: "toolbar-back"; onClicked: { itemMenu.close(); pageStack.pop(); }  }
        ToolIcon {
            iconId: "toolbar-previous"
            visible: previousId !== false
            onClicked: {
                var ttrss = rootWindow.getTTRSS()
                var tmpArticleId = ttrss.getPreviousFeedId(feedId, articleId)
                if (tmpArticleId !== false)
                    articleId = tmpArticleId
                else
                    console.log("no next articleid found")
            } }
        ToolIcon {
            iconSource: "resources/ic_star_"+(marked?"enabled":"disabled")+".png"
            enabled: !loading
            onClicked: {
                loading = true
                var ttrss = rootWindow.getTTRSS()
                ttrss.updateFeedStar(articleId, !marked, callback)
            } }
        ToolIcon {
            iconSource: "resources/ic_rss_"+(rss?"enabled":"disabled")+".png"
            enabled: !loading
            onClicked: {
                loading = true
                var ttrss = rootWindow.getTTRSS()
                ttrss.updateFeedRSS(articleId, !rss, callback)
            } }
        ToolIcon {
            iconSource: "resources/ic_"+(unread?"unread":"read")+".png"
            enabled: !loading
            onClicked: {
                loading = true
                var ttrss = rootWindow.getTTRSS()
                ttrss.updateFeedUnread(articleId, !unread, callback)
            } }
        ToolIcon {
            iconId: "toolbar-next"
            visible: nextId !== false
            onClicked: {
                var ttrss = rootWindow.getTTRSS()
                var tmpArticleId = ttrss.getNextFeedId(feedId, articleId)
                if (tmpArticleId !== false)
                    articleId = tmpArticleId
                else
                    console.log("no next articleid found")
            } }
        ToolIcon {
            iconId: "toolbar-view-menu" ;
            onClicked: (itemMenu.status === DialogStatus.Closed) ? itemMenu.open() : itemMenu.close()
            enabled: !loading
        }
    }

    Menu {
        id: itemMenu
        visualParent: pageStack

        MenuLayout {
            MenuItem {
                text: qsTr("Open in Web Browser")
                enabled: url && (url != "")
                onClicked: {
                    Qt.openUrlExternally(url);
                }
            }
            SettingsItem {}
            AboutItem {}
        }
    }
}
