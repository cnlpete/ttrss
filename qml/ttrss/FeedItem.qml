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
import "../components" 1.0

Page {
    id: itemPage
    tools: itemTools
    property string feedId:         ""
    property string articleId:      ""
    property string pageTitle:      ""
    property string url:            ""
    property bool   updating:       false
    property bool   loading: updating || itemView.progress < 1
    property bool   marked:         false
    property bool   unread:         true
    property bool   rss:            false
    property bool   previousId:     false
    property bool   nextId:         false
    property int    numStatusUpdates

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
                    infoBanner.text = qsTr("Open in Web Browser")
                    infoBanner.show()
                    Qt.openUrlExternally(url);
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

    function computeAttachmentsCode(data) {
        var attachments = data.attachments
        if (!attachments) return ""

        var attachmentsCode = ""

        for (var i = 0; i < attachments.length; i++) {
            var url = attachments[i].content_url
            var isImage = (attachments[i].content_type.indexOf("image") === 0 ||
                           /jpe?g$/i.test(url) ||
                           /png$/i.test(url))

            console.log("URL: " + url + " isImage: " + isImage)
            var attachmentLabel = ""
            if (isImage) {
                attachmentLabel = "<img src=\"" + url + "\" style=\"max-width: 100%; height: auto\"/>"
            } else {
                attachmentLabel = attachments[i].title ? attachments[i].title : url.replace(/^.*[\/]/g, '')
            }
            attachmentsCode += "<a href=\"" + url + "\">" + attachmentLabel + "</a>"
        }

        return attachmentsCode
    }

    function showFeedItem() {
        var data = feedItems.getSelectedItem()

        if (data) {
            var attachmentsCode = undefined;//computeAttachmentsCode(data)

            var content = data.content.replace('target="_blank"', '')
            if (!content.match(/<body>/gi)) {
                // not yet html, detect urls
                console.log('doing link detection on ' + content)
                var regex = /(([a-z]+:\/\/)?(([a-z0-9\-]+\.)+([a-z]{2}|aero|arpa|biz|com|coop|edu|gov|info|int|jobs|mil|museum|name|nato|net|org|pro|travel|local|internal))(:[0-9]{1,5})?(\/[a-z0-9_\-\.~]+)*(\/([a-z0-9_\-\.]*)(\?[a-z0-9+_\-\.%=&amp;]*)?)?(#[a-zA-Z0-9!$&'()*+.=-_~:@/?]*)?)(\s+|$)/gi;
                content = content.replace(regex, "<a href='$1'>$1</a> ")
                if (attachmentsCode) {
                    content += attachmentsCode
                }
            } else {
                if (attachmentsCode) {
                    var regex =/(<\/body>)/gi
                    content = content.replace(regex, attachmentsCode + "$1")
                }
            }

            itemView.html = content
            url         = data.url
            pageTitle   = data.title

            marked      = data.marked
            unread      = data.unread
            rss         = data.rss

            previousId  = feedItems.hasPrevious()
            nextId      = feedItems.hasNext()

            articleId   = data.id

            if (settings.autoMarkRead && unread) {
                updating = true
                feedItems.toggleRead()
            }
        }
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
                feedItems.selectPrevious()
                showFeedItem()
            } }
        ToolIcon {
            iconSource: "resources/ic_star_"+(marked?"enabled":"disabled")+".png"
            enabled: !updating
            onClicked: {
                updating = true
                feedItems.toggleStar()
                marked = !marked
            } }
        ToolIcon {
            iconSource: "resources/ic_rss_"+(rss?"enabled":"disabled")+".png"
            enabled: !updating
            onClicked: {
                updating = true
                feedItems.togglePublished()
                rss = !rss
            } }
        ToolIcon {
            iconSource: "resources/ic_"+(unread?"unread":"read")+".png"
            enabled: !updating
            onClicked: {
                updating = true
                feedItems.toggleRead()
                unread = !unread
            } }
        ToolIcon {
            iconId: "toolbar-next"
            visible: nextId !== false
            onClicked: {
                feedItems.selectNext()
                showFeedItem()
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
                    infoBanner.text = qsTr("Open in Web Browser")
                    infoBanner.show()
                    Qt.openUrlExternally(url);
                }
            }
            MenuItem {
                text: qsTr("Share")
                enabled: url && (url != "")
                onClicked: QMLUtils.share(url, pageTitle);
            }
            SettingsItem {}
            AboutItem {}
        }
    }
}
