/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2016  Hauke Schade
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

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: root
    property alias  pageTitle:      subtitleLabel.text
    property alias  subTitle:       pageHeader.title
    property string url:            ""
    property string date:           ""
    property string note:           ""
    property bool   marked:         false
    property bool   unread:         true
    property bool   rss:            false
    property bool   previousId:     false
    property bool   nextId:         false
    property bool   isCat:          false
    property var    labels

    anchors.margins: 0
    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    SilicaFlickable {
        id: flick
        contentWidth: parent.width - (orientation === Orientation.Portrait ? 0 : Theme.itemSizeMedium)
        contentHeight: content.height
        interactive: true
        clip: true
        anchors {
            fill: parent
            bottomMargin: orientation === Orientation.Portrait ? panel.height : 0
            rightMargin: orientation === Orientation.Portrait ? 0 : panel.width
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Mark all above as read")
                onClicked: {
                    if (feedItemModel.selectedIndex !== -1) {
                        remorse.execute(qsTr("Marked all above as read"),
                                        function() {
                                            feedItemModel.markAllAboveAsRead(feedItemModel.selectedIndex)
                                        })
                    }
                }
            }

            MenuItem {
                text: qsTr("Open in Web Browser")
                enabled: url && (url != "")
                onClicked: Qt.openUrlExternally(url)
            }

//            MenuItem {
//                text: panel.open ? qsTr("Hide Dock") : qsTr("Open Dock")
//                enabled: !panel.moving
//                onClicked: panel.open ? panel.hide() : panel.show()
//            }

            MenuItem {
                text: qsTr("Edit Note")
                enabled: !network.loading
                onClicked: {
                    var params = {
                        previousNote: root.note,
                        feedItemPage: root
                    }
                    pageStack.push(Qt.resolvedUrl("NoteEditor.qml"), params)
                }
            }

            MenuItem {
                text: qsTr("Assign Labels")
                enabled: !network.loading
                onClicked: {
                    feedItemModel.getLabels(function(successful, errorMessage,
                                                     labels) {
                        if (successful) {
                            var params = {
                                labels: labels,
                                headline: root.pageTitle,
                                feedItemPage: root
                            }
                            pageStack.push(Qt.resolvedUrl("LabelUpdater.qml"),
                                           params)
                        }

                        // TODO make use of errorMessage
                    })
                }
            }
        }

        RemorsePopup { id: remorse }

        Column {
            id: content
            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }
            spacing: Theme.paddingSmall

            PageHeader {
                id: pageHeader
            }

            Label {
                id: subtitleLabel
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                textFormat: Text.RichText
                color: Theme.highlightColor
            }

            Row {
                id: headerRow
                anchors {
                    right: parent.right
                }
                spacing: Theme.paddingSmall

                Icon {
                    source: "qrc:///images/ic_star.svg"
                    height: dateLabel.height
                    width: height
                    color: Theme.highlightColor
                    opacity: marked ? 1 : 0
                    Behavior on opacity { FadeAnimation{} }
                }
                Icon {
                    source: "qrc:///images/ic_rss.svg"
                    height: dateLabel.height
                    width: height
                    color: Theme.highlightColor
                    opacity: rss ? 1 : 0
                    Behavior on opacity { FadeAnimation{} }
                }
                Label {
                    id: dateLabel
                    text: date
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Light
                    textFormat: Text.PlainText
                    color: Theme.secondaryColor
                }
            }

            RescalingRichText {
                id: itemView
                text: body
                fontSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                width: parent.width - Theme.paddingLarge
                onLinkActivated: {
                    if (link.substring(0,3) === '|||') {
                        var curstomLinkRegex = /\|\|\|([^\|]*)\|\|\|([^\|]*)\|\|\|/i;
                        var curstomLinkContent = curstomLinkRegex.exec(link);
                        pageStack.push(Qt.resolvedUrl("ImageViewer.qml"), { imgUrl: curstomLinkContent[1], strHpTitle: curstomLinkContent[2] })
                    }
                    else {
                        pageStack.push(Qt.openUrlExternally(link))
                    }
                }
            }

            Label {
                id: noteView
                width: parent.width
                text: qsTr("Note: %1").arg(note)
                color: Theme.primaryColor
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                textFormat: Text.PlainText
                font.weight: Font.Light
                font.italic: true
                font.pixelSize: Theme.fontSizeTiny
                visible: note !== ""
            }

            Grid {
                spacing: Theme.paddingMedium
                width: parent.width
                visible: labels !== null && labels.count > 0

                Repeater {
                    model: labels.count
                    LabelLabel {
                        label: labels.get(index)
                    }
                }
            }

            Separator {
                width: parent.width
                horizontalAlignment: Qt.AlignHCenter
                color: Theme.highlightColor
                visible: images.model.count > 0
            }
            ListView {
                id: images
                width: parent.width
                height: model.count * Theme.itemSizeSmall

                delegate: ListItem {
                    width: parent.width
                    height: Theme.itemSizeSmall

                    Label {
                        text: title
                        width: parent.width
                        height: Theme.itemSizeSmall
                        color: Theme.highlightColor
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: pageStack.push(Qt.resolvedUrl("ImageViewer.qml"), { imgUrl: url, strHpTitle: title })
                    }
                }
            }

            Separator {
                width: parent.width
                horizontalAlignment: Qt.AlignHCenter
                color: Theme.highlightColor
                visible: attachments.model.count > 0
            }
            ListView {
                id: attachments
                width: parent.width
                height: model.count * Theme.itemSizeSmall

                delegate: ListItem {
                    width: parent.width
                    height: Theme.itemSizeSmall

                    Label {
                        text: title ? title : content_url.replace(/^.*[\/]/g, '')
                        width: parent.width
                        height: Theme.itemSizeSmall
                        color: Theme.highlightColor
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var url = content_url
                            var isImage = (content_type.indexOf("image") === 0 ||
                                           /(jpe?g|png)$/i.test(url))
                            if (isImage) {
                                pageStack.push(Qt.resolvedUrl("ImageViewer.qml"), { imgUrl: url, strHpTitle: title })
                            }
                            else {
                                pageStack.push(Qt.openUrlExternally(url))
                            }
                        }
                    }
                }
            }
        }
        VerticalScrollDecorator { }
    }
    BusyIndicator {
        visible: network.loading
        running: visible
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
    }

    DockedPanel {
        id: panel

        width: orientation === Orientation.Portrait ? parent.width : Theme.itemSizeMedium
        height: orientation === Orientation.Portrait ? Theme.itemSizeMedium : parent.height
        open: true

        dock: orientation === Orientation.Portrait ? Dock.Bottom : Dock.Right

        Column {
            visible: !panelRow.visible
            anchors.centerIn: parent

            IconButton {
                id: previousButton
                icon.source: "image://theme/icon-m-previous"
                enabled: previousId !== false
                onClicked: {
                    feedItemModel.selectPrevious()
                    pageStack.replace(Qt.resolvedUrl("FeedItem.qml"),
                                      { isCat: root.isCat })
                    //showFeedItem()
                }
            }

            IconButton {
                icon.source: "qrc:///images/ic_rss.svg"
                icon.color: rss ? Theme.highlightColor : Theme.secondaryColor
                icon.width: Theme.iconSizeSmallPlus
                icon.height: Theme.iconSizeSmallPlus
                onClicked: {
                    feedItemModel.togglePublished(function(successful,
                                                           errorMessage,
                                                           state) {
                        rss = state
                        // TODO make use of errorMessage
                    })
                }
            }

            IconButton {
                icon.source: "qrc:///images/ic_star.svg"
                icon.color: marked ? Theme.highlightColor : Theme.secondaryColor
                icon.width: Theme.iconSizeSmallPlus
                icon.height: Theme.iconSizeSmallPlus
                onClicked: {
                    feedItemModel.toggleStar(function(successful, errorMessage,
                                                      state) {
                        marked = state
                        // TODO make use of errorMessage
                    })
                }
            }

            IconButton {
                icon.source: "qrc:///images/ic_"
                             + (unread ? "unread" : "read") + ".svg"
                icon.color: unread ? Theme.highlightColor : Theme.secondaryColor
                icon.width: Theme.iconSizeSmallPlus
                icon.height: Theme.iconSizeSmallPlus
                onClicked: {
                    feedItemModel.toggleRead(function(successful, errorMessage,
                                                      state) {
                        unread = state
                        // TODO make use of errorMessage
                    })
                }
            }

            IconButton {
                icon.source: "image://theme/icon-m-next"
                enabled: nextId !== false
                onClicked: {
                    feedItemModel.selectNext()
                    pageStack.replace(Qt.resolvedUrl("FeedItem.qml"),
                                      { isCat: root.isCat })
                    //showFeedItem()
                }
            }
        }

        Row {
            id: panelRow
            anchors.centerIn: parent
            visible: orientation === Orientation.Portrait

            IconButton {
                icon.source: "image://theme/icon-m-previous"
                enabled: previousId !== false
                onClicked: {
                    feedItemModel.selectPrevious()
                    pageStack.replace(Qt.resolvedUrl("FeedItem.qml"),
                                      { isCat: root.isCat })
                    //showFeedItem()
                }
            }

            IconButton {
                icon.source: "qrc:///images/ic_rss.svg"
                icon.color: rss ? Theme.highlightColor : Theme.secondaryColor
                icon.width: Theme.iconSizeSmallPlus
                icon.height: Theme.iconSizeSmallPlus
                onClicked: {
                    feedItemModel.togglePublished(function(successful,
                                                           errorMessage,
                                                           state) {
                        rss = state
                        // TODO make use of errorMessage
                    })
                }
            }

            IconButton {
                icon.source: "qrc:///images/ic_star.svg"
                icon.color: marked ? Theme.highlightColor : Theme.secondaryColor
                icon.width: Theme.iconSizeSmallPlus
                icon.height: Theme.iconSizeSmallPlus
                onClicked: {
                    feedItemModel.toggleStar(function(successful, errorMessage,
                                                      state) {
                        marked = state
                        // TODO make use of errorMessage
                    })
                }
            }

            IconButton {
                icon.source: "qrc:///images/ic_"
                             + (unread ? "unread" : "read") + ".svg"
                icon.color: unread ? Theme.highlightColor : Theme.secondaryColor
                icon.width: Theme.iconSizeSmallPlus
                icon.height: Theme.iconSizeSmallPlus
                onClicked: {
                    feedItemModel.toggleRead(function(successful, errorMessage,
                                                      state) {
                        unread = state
                        // TODO make use of errorMessage
                    })
                }
            }

            IconButton {
                icon.source: "image://theme/icon-m-next"
                enabled: nextId !== false
                onClicked: {
                    feedItemModel.selectNext()
                    pageStack.replace(Qt.resolvedUrl("FeedItem.qml"),
                                      { isCat: root.isCat })
                    //showFeedItem()
                }
            }
        }
    }

    function showFeedItem() {
        var data = feedItemModel.getSelectedItem()

        if (data) {
            var content = data.content.replace('target="_blank"', '')

            if (!content.match(/<body>/gi)) {
                // not yet html, detect urls
                console.log('doing link detection on ' + content)

                var regex = /(([a-z]+:\/\/)?(([a-z0-9\-]+\.)+([a-z]{2}|aero|arpa|biz|com|coop|edu|gov|info|int|jobs|mil|museum|name|nato|net|org|pro|travel|local|internal))(:[0-9]{1,5})?(\/[a-z0-9_\-\.~]+)*(\/([a-z0-9_\-\.]*)(\?[a-z0-9+_\-\.%=&amp;]*)?)?(#[a-zA-Z0-9!$&'()*+.=-_~:@/?]*)?)(\s+|$)/gi;
                content = content.replace(regex, "<a href='$1'>$1</a> ")

            }

            itemView.text = content
            url         = data.url
            pageTitle   = data.title
            subTitle    = data.feedTitle
            date        = data.date
            root.labels = data.labels
            images.model = data.images
            attachments.model = data.attachments
            note        = data.note !== undefined ? data.note : ""
            marked      = data.marked
            unread      = data.unread
            rss         = data.rss
            //rssSwitch.checked = rss

            previousId  = feedItemModel.hasPrevious()
            nextId      = feedItemModel.hasNext()

            if (settings.autoMarkRead && unread) {
                feedItemModel.toggleRead(function(successful, errorMessage,
                                                  state) {
                    unread = state
                    // TODO make use of errorMessage
                })
            }
        }
    }

    function updateLabels() {
        feedItemModel.updateLabels(function(successful, errorMessage, labels) {
            if (successful) {
                root.labels = labels
            }

            // TODO make use of errorMessage
        })
    }

    function updateNote(note) {
        feedItemModel.updateNote(note, function(successful, errorMessage) {
            if (successful) {
                root.note = note
            }

            // TODO make use of errorMessage
        })
    }

    Binding {
        target: itemView
        property: "fontSize"
        value: settings.webviewFontSize
    }

    Component.onCompleted: {
        // go for default if out of range
        if (settings.webviewFontSize < Theme.fontSizeTiny || settings.webviewFontSize > Theme.fontSizeExtraLarge) {
            settings.webviewFontSize = Theme.fontSizeSmall;
        }
        itemView.fontSize = settings.webviewFontSize
        showFeedItem();
    }
}
