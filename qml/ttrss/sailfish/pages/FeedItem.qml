/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2014  Hauke Schade
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: root
    property alias  pageTitle:      subtitleLabel.text
    property alias  subTitle:       pageHeader.title
    property string url:            ""
    property string date:           ""
    property bool   marked:         false
    property bool   unread:         true
    property bool   rss:            false
    property bool   previousId:     false
    property bool   nextId:         false
    property bool   isCat:          false
    property variant labels

    anchors.margins: 0

    SilicaFlickable {
        id: flick
        contentHeight: content.height
        interactive: true
        clip: true
        anchors {
            fill: parent
            bottomMargin: panel.open ? panel.height : 0
        }

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
            width: parent.width
            spacing: Theme.paddingSmall
//            Row {
//                id: labelsrepeater
//                spacing: constant.paddingMedium
//                Repeater {
//                    model: root.labels
//                    LabelLabel {
//                        label: root.labels.get(index)
//                    }
//                }
//            }
            PageHeader {
                id: pageHeader
            }
            Row {
                id: headerRow
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                }
                spacing: 5

                Label {
                    id: subtitleLabel
                    width: parent.width - starImage.width - rssImage.width
                    text: ""
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    textFormat: Text.RichText
                    color: Theme.highlightColor
                }
                Image {
                    id: starImage
                    opacity: marked ? 1 : 0
                    width: 32
                    height: 32
                    sourceSize.width: 32
                    sourceSize.height: 32
                    source: "../../resources/ic_star_enabled.png"
                    Behavior on opacity { FadeAnimation{} }
                }
                Image {
                    id: rssImage
                    opacity: rss ? 1 : 0
                    width: 32
                    height: 32
                    sourceSize.width: 32
                    sourceSize.height: 32
                    source: "../../resources/ic_rss_enabled.png"
                    Behavior on opacity { FadeAnimation{} }
                }
            }
            Label {
                text: date
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Light
                textFormat: Text.PlainText
                anchors {
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }

                color: Theme.secondaryColor
            }
            RescalingRichText {
                id: itemView
                text: body
                fontSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                }
                onLinkActivated: pageStack.push(Qt.openUrlExternally(link))
            }
        }
        VerticalScrollDecorator { }
// TODO make the FancyScroller work with SilicaFlickable aswell
//        FancyScroller {
//            flickable: flick
//            anchors.fill: parent
//        }
    }
    BusyIndicator {
        visible: network.loading
        running: visible
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
    }

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

    function computeAttachmentsCode(data) {
        var attachments = data.attachments
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
                attachmentLabel = "<img src=\"" + url + "\" style=\"max-width: 100%; height: auto\"/>"
            } else {
                attachmentLabel = a.title ? a.title : url.replace(/^.*[\/]/g, '')
            }
            attachmentsCode += "<a href=\"" + url + "\">" + attachmentLabel + "</a>"
        }

        return attachmentsCode
    }

    function showFeedItem() {
        var data = feedItems.getSelectedItem()

        if (data) {
            var attachmentsCode = computeAttachmentsCode(data)

            var content = data.content.replace('target="_blank"', '')

            if (settings.stripInvisibleImg) {
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

            itemView.text = content
            url         = data.url
            pageTitle   = data.title
            subTitle    = data.feedTitle
            date        = data.date
            root.labels = data.labels
            marked      = data.marked
            //markedSwitch.checked = marked
            unread      = data.unread
            //unreadSwitch.checked = unread
            rss         = data.rss
            //rssSwitch.checked = rss

            previousId  = feedItems.hasPrevious()
            nextId      = feedItems.hasNext()

            if (settings.autoMarkRead && unread) {
                feedItems.toggleRead()
                unread = !unread
            }
        }
    }

    Binding {
        target: itemView
        property: "fontSize"
        value: settings.webviewFontSize
    }

    Component.onCompleted: {
        itemView.fontSize = settings.webviewFontSize
        showFeedItem();
    }


//            MenuItem {
//                text: qsTr("Share")
//                enabled: url && (url != "")
//                onClicked: QMLUtils.share(url, pageTitle);
//            }
//            SettingsItem {}
//            AboutItem {}
}
