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

import QtQuick 2.0
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Item {
    id: root
    property string title:          ""
    property string url:            ""
    property string date:           ""
    property bool   marked:         false
    property bool   unread:         true
    property bool   rss:            false
    property bool   isCat:          false
    property variant labels
    property var attachments
    property string content: ""
    property Item flickable: flick

    Flickable {
        id: flick
        anchors.fill: parent
        contentHeight: content.height
        interactive: true
        flickableDirection: Flickable.VerticalFlick
        topMargin: pageStack.currentPage.header.height
        clip: true

        /* TODO
        PullDownMenu {
//            AboutItem {}
//            SettingsItem {}
            MenuItem {
                text: qsTr("Open in Web Browser")
                enabled: url && (url != "")
                onClicked: Qt.openUrlExternally(url)
            }
            MenuItem {
                text: panel.open ? qsTr("Hide Dock") : qsTr("Open Dock")
                enabled: !panel.moving
                onClicked: panel.open ? panel.hide() : panel.show()
            }
        }
        */

//        PushUpMenu {
//            MenuItem {
//                text: qsTr("Scroll to top")
//                onClicked: flick.scrollToTop()
//                visible: flick.contentHeight >= flick.height
//            }
//            MenuItem {
//                text: qsTr("Open Dock")
//                visible: !panel.open
//                onClicked: panel.show()
//            }
//        }

        Column {
            id: content
            anchors { left: parent.left; right: parent.right; margins: units.gu(1) }
            spacing: 2

            Label {
                text: title
                fontSize: "large"
                font.bold: true
                wrapMode: Text.Wrap
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }
            Label {
                text: date
                fontSize: "small"
                textFormat: Text.PlainText
                anchors {
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }
            }

            RescalingRichText {
                id: itemView
                width: parent.width
                text: parseContent(root.content, root.attachments)
                fontSize: settings.webviewFontSize
                color: theme.palette.normal.foregroundText
                onLinkActivated: Qt.openUrlExternally(link)
                onPressAndHold: {
                    var url = link ? link : root.url
                    var isImage = (/jpe?g$/i.test(url) || /png$/i.test(url))
                    PopupUtils.open(Qt.resolvedUrl("ContextMenu.qml"), root, {
                        "isImage": isImage,
                        "url": url,
                        "target": itemView,
                    })
                }
            }
        }
    }

    Scrollbar {
        flickableItem: flick
    }

    ActivityIndicator {
        running: network.loading
        anchors.centerIn: parent
    }

    /* TODO
    DockedPanel {
        id: panel

        width: parent.width
        height: Theme.itemSizeMedium
        open: true

        dock: Dock.Bottom

        Row {
            anchors.centerIn: parent

            IconButton {
                icon.source: "image://theme/icon-m-previous"
                enabled: previousId !== false
                onClicked: {
                    feedItems.selectPrevious()
                    pageStack.replace("FeedItem.qml", { isCat: root.isCat })
                    //showFeedItem()
                }
            }
            IconButton {
                id: rssSwitch
                icon.source: "../../resources/ic_rss_"+(rss?"enabled":"disabled")+".png"
                //checked: rss
                onClicked: {
                    feedItems.togglePublished()
                    rss = !rss
                }
            }
            IconButton {
                id: markedSwitch
                icon.source: "../../resources/ic_star_"+(marked?"enabled":"disabled")+".png"
                //checked: marked
                onClicked: {
                    feedItems.toggleStar()
                    marked = !marked
                }
            }
            IconButton {
                id: unreadSwitch
                icon.source: "../../resources/ic_"+(unread?"unread":"read")+".png"
                //checked: unread
                onClicked: {
                    feedItems.toggleRead()
                    unread = !unread
                }
            }
            IconButton {
                icon.source: "image://theme/icon-m-next"
                enabled: nextId !== false
                onClicked: {
                    feedItems.selectNext()
                    pageStack.replace("FeedItem.qml", { isCat: root.isCat })
                    //showFeedItem()
                }
            }
        }
    }
    */

    function computeAttachmentsCode(attachments) {
        if (attachments.count === 0) return ""

        var attachmentsCode = ""

        for (var i = 0; i < attachments.count; i++) {
            var a = attachments.get(i)
            var url = a.content_url
            var isImage = (a.content_type.indexOf("image") === 0 ||
                           /jpe?g$/i.test(url) ||
                           /png$/i.test(url))

            console.log("URL: " + url + " isImage: " + isImage)
            var attachmentLabel = ""
            if (isImage) {
                if (!settings.displayImages) {
                    // Do not attach images if they should not be displayed.
                    continue
                }
                attachmentLabel = "<img src=\"" + url + "\" style=\"max-width: 100%; height: auto\"/>"
            } else {
                attachmentLabel = a.title ? a.title : url.replace(/^.*[\/]/g, '')
            }
            attachmentsCode += "<a href=\"" + url + "\">" + attachmentLabel + "</a><br/>"
        }

        return attachmentsCode
    }

    function parseContent(rawContent, attachments) {
        var attachmentsCode = computeAttachmentsCode(attachments)

        var content = rawContent.replace('target="_blank"', '')

        if (!settings.displayImages) {
            // remove images
            var image_regex = /<img\s[^>]*>/gi;
            content = content.replace(image_regex, "")
        } else if (settings.stripInvisibleImg) {
            // remove images with a height or width of 0 or 1
            var height_regex = /<img\s[^>]*height="[01]"[^>]*>/gi;
            content = content.replace(height_regex, "")

            var width_regex = /<img\s[^>]*width="[01]"[^>]*>/gi;
            content = content.replace(width_regex, "")
        }

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

        return content
    }

    Binding {
        target: itemView
        property: "fontSize"
        value: settings.webviewFontSize
    }

    Component.onCompleted: {
        itemView.fontSize = settings.webviewFontSize
    }


//            MenuItem {
//                text: qsTr("Share")
//                enabled: url && (url != "")
//                onClicked: QMLUtils.share(url, pageTitle);
//            }
//            SettingsItem {}
//            AboutItem {}
}
