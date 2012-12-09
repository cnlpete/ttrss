//Copyright Hauke Schade, 2012
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
    property bool   starloading:    false
    property bool   unreadloading:  false
    property bool   marked:         false
    property bool   unread:         true

    anchors.margins: 0

    Flickable {
        id: flick
        width: parent.width;
        height: parent.height
        contentWidth: itemView.width
        contentHeight: itemView.height
        interactive: true
        clip: true
        anchors{ top: pageHeader.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }

//        signal newWindowRequested(string url)

        WebView {
            id: itemView
            transformOrigin: Item.TopLeft
            settings.standardFontFamily: "Arial"
            settings.defaultFontSize: constant.fontSizeSmall
            settings.linksIncludedInFocusChain: true
            settings.localContentCanAccessRemoteUrls: true
            preferredWidth: flick.width
            preferredHeight: flick.height
        }
    }

    ScrollDecorator {
        flickableItem: flick
    }

    function showFeedItem() {
        var ttrss = rootWindow.getTTRSS();
        numStatusUpdates = ttrss.getNumStatusUpdates();
        var data = ttrss.getFeedItem(feedId, articleId);

        if (data) {
            itemView.html = data.content;
            url         = data.link
            pageTitle   = data.title
            marked      = data.marked
            unread      = data.unread
        }
    }

    onArticleIdChanged: {
        showFeedItem();
    }

    Component.onCompleted: {
        showFeedItem();
    }

    function markedCallback() {
        var ttrss = rootWindow.getTTRSS()
        var data = ttrss.getFeedItem(feedId, articleId);

        starloading = false

        if (data)
            marked = data.marked
    }

    function unreadCallback() {
        var ttrss = rootWindow.getTTRSS()
        var data = ttrss.getFeedItem(feedId, articleId);

        unreadloading = false

        if (data)
            unread = data.unread
    }

    PageHeader {
        id: pageHeader
        text: pageTitle
    }

    ToolBarLayout {
        id: itemTools

        ToolIcon { iconId: "toolbar-back"; onClicked: { itemMenu.close(); pageStack.pop(); }  }
        ToolIcon {
            iconId: "toolbar-previous";
            onClicked: {
                var ttrss = rootWindow.getTTRSS()
                var tmpArticleId = ttrss.getPreviousFeedId(feedId, articleId)
                if (tmpArticleId !== false)
                    articleId = tmpArticleId
                else
                    console.log("no next articleid found")
            } }
        BusyIndicator {
            visible: starloading
            running: starloading
            platformStyle: BusyIndicatorStyle { size: 'medium' }
        }
        ToolIcon {
            iconId: "toolbar-favorite-"+(marked?"":"un")+"mark";
            visible: !starloading
            onClicked: {
                starloading = true
                var ttrss = rootWindow.getTTRSS()
                ttrss.updateFeedStar(articleId, !marked, markedCallback)
            } }
        BusyIndicator {
            visible: unreadloading
            running: unreadloading
            platformStyle: BusyIndicatorStyle { size: 'medium' }
        }
        ToolIcon {
            iconId: "toolbar-"+(unread?"share":"add");
            visible: !unreadloading
            onClicked: {
                unreadloading = true
                var ttrss = rootWindow.getTTRSS()
                ttrss.updateFeedUnread(articleId, !unread, unreadCallback)
            } }
        ToolIcon {
            iconId: "toolbar-next";
            onClicked: {
                var ttrss = rootWindow.getTTRSS()
                var tmpArticleId = ttrss.getNextFeedId(feedId, articleId)
                if (tmpArticleId !== false)
                    articleId = tmpArticleId
                else
                    console.log("no next articleid found")
            } }
        ToolIcon { iconId: "toolbar-view-menu" ; onClicked: (itemMenu.status === DialogStatus.Closed) ? itemMenu.open() : itemMenu.close() }
    }

    Menu {
        id: itemMenu
        visualParent: pageStack

        MenuLayout {
            MenuItem {
                id: openInBrowser
                text: qsTr("Open in Web Browser")
                enabled: url && (url != "")
                onClicked: {
                    Qt.openUrlExternally(url);
                }
            }
            MenuItem {
                text: qsTr("About")
                onClicked: {
                    rootWindow.openFile("About.qml");
                }
            }
        }
    }
}
