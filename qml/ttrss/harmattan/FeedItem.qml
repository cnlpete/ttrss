/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2014  Hauke Schade
 *
 * TTRss is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * TTRss is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with TTRss; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA or see
 * http://www.gnu.org/licenses/.
 */

import QtQuick 1.1
import com.nokia.meego 1.0
import QtWebKit 1.0
import "../components" 1.0

Page {
    id: root
    tools: itemTools
    property string pageTitle:      ""
    property string subTitle:       ""
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

    Flickable {
        id: flick
        width: parent.width - MyTheme.paddingMedium - MyTheme.paddingMedium
        height: parent.height
        contentWidth: parent.width
        contentHeight: content.height
        interactive: true
        clip: true
        anchors {
            top: pageHeader.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: MyTheme.paddingMedium
        }

        Column {
            id: content
            spacing: MyTheme.paddingMedium

            Text {
                text: date
                font.pointSize: MyTheme.fontSizeSmall
                font.weight: Font.Light
                textFormat: Text.PlainText
                anchors {
                    right: parent.right
                }

                color: theme.inverted ? MyTheme.secondaryColor : secondaryColorInverted
            }
            Row {
                id: labelsrepeater
                spacing: MyTheme.paddingMedium
                Repeater {
                    model: root.labels
                    LabelLabel {
                        label: root.labels.get(index)
                    }
                }
            }
            RescalingRichText {
                id: itemView
                fontSize: settings.webviewFontSize - 2
                text: "content"
                width: flick.width
                onLinkActivated: {
                    if (link != "") {
                        infoBanner.text = qsTr("Open in Web Browser")
                        infoBanner.show()
                        Qt.openUrlExternally(link);
                    }
                }
                color: theme.inverted ? MyTheme.primaryColorInverted: MyTheme.primaryColor
            }
        }
    }

    ScrollDecorator {
        flickableItem: flick
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
                if (!settings.displayImages) {
                    // Do not attach images if they should not be displayed.
                    continue
                }
                var re = new RegExp("<img\\s[^>]*src=\"" + url + "\"", "i")
                if (data.content.match(re)) {
                    // Do not attach images which are part of the content.
                    continue
                }
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

            itemView.text = content
            url         = data.url
            pageTitle   = data.title
            subTitle    = data.feedTitle
            date        = data.date
            root.labels = data.labels
            marked      = data.marked
            unread      = data.unread
            rss         = data.rss

            previousId  = feedItems.hasPrevious()
            nextId      = feedItems.hasNext()

            if (settings.autoMarkRead && unread) {
                feedItems.toggleRead()
                unread = !unread
            }
        }
    }

    Component.onCompleted: {
        showFeedItem();
    }

    PageHeader {
        id: pageHeader
        text: pageTitle
        subtext: root.isCat ? root.subTitle : ""
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
            iconSource: "../resources/ic_star_"+(marked?"enabled":"disabled")+".png"
            onClicked: {
                feedItems.toggleStar()
                marked = !marked
            } }
        ToolIcon {
            iconSource: "../resources/ic_rss_"+(rss?"enabled":"disabled")+".png"
            onClicked: {
                feedItems.togglePublished()
                rss = !rss
            } }

        ToolIcon {
            iconSource: "../resources/ic_"
                        + (unread ? "unread" : "read") + ".png"
            onClicked: {
                feedItems.toggleRead(function(successful, errorMessage, state) {
                    unread = state
                    // TODO make use of errorMessage
                })
            }
        }

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
            enabled: !network.loading
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
