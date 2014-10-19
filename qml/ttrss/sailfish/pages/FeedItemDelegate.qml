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

import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: listItem

    contentHeight: content.height + contentRow.anchors.topMargin
                   + contentRow.anchors.bottomMargin
    width: parent.width

    Row {
        id: markerRow
        spacing: Theme.paddingMedium
        anchors.fill: parent
        anchors.leftMargin: (icon.visible ? icon.width : 0) + Theme.paddingMedium
        Image {
            source: "../../resources/ic_star_enabled.png"
            visible: model.marked
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.5
        }
        Image {
            source: "../../resources/ic_rss_enabled.png"
            visible: model.rss
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.5
        }
    }

    Row {
        id: contentRow
        anchors.fill: parent
        anchors.margins: Theme.paddingMedium
        spacing: Theme.paddingMedium
        clip: true

        Image {
            id: icon
            sourceSize.height: 80
            sourceSize.width: 80
            asynchronous: true
            width: 60
            height: 60
            anchors.verticalCenter: parent.verticalCenter

            source: feed.isCat ? model.icon : ''

            visible: settings.displayIcons && model.icon !== '' && feed.isCat && status == Image.Ready
            Rectangle {
                color: "white"
                anchors.fill: parent
                visible: settings.whiteBackgroundOnIcons && parent.status == Image.Ready
                z: parent.z - 1
            }
        }

        Column {
            id: content
            width: icon.visible ? (parent.width - icon.width) : parent.width

            Label {
                width: parent.width
                text: model.title
                color: model.unread > 0 ?
                           (listItem.highlighted ? Theme.highlightColor : Theme.primaryColor) :
                           (listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor)
                // 'maximumLineCount: 0' means 'no limit'
                maximumLineCount: settings.lengthOfTitle
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                truncationMode: TruncationMode.Fade
                textFormat: Text.StyledText
                font.weight: Font.Bold
                font.pixelSize: Theme.fontSizeMedium
            }
            Label {
                width: parent.width
                text: model.subtitle
                color: model.unread > 0 ?
                           (listItem.highlighted ? Theme.highlightColor : Theme.primaryColor) :
                           (listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor)
                maximumLineCount: settings.lengthOfExcerpt
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                truncationMode: TruncationMode.Fade
                textFormat: Text.StyledText
                font.weight: Font.Light
                font.pixelSize: Theme.fontSizeSmall
                visible: settings.showExcerpt && text != ""
            }
            Grid  {
                spacing: Theme.paddingSmall
                width: parent.width
                visible: settings.displayLabels && labels !== null && labels.count > 0

                property var labels: model.labels

                Repeater {
                    model: settings.displayLabels ? labels.count : 0
                    LabelLabel {
                        label: labels.get(index)
                    }
                }
            }
        }
    }

    menu: Component {
        ContextMenu {
            MenuItem {
                id: toggleStarMenuItem
                text: model.marked ? qsTr("Unstar") : qsTr("Star")
                onClicked: {
                    feedItems.toggleStar()
                } }
            MenuItem {
                id: togglePublishedMenuItem
                text: model.rss ? qsTr("Unpublish") : qsTr("Publish")
                onClicked: {
                    feedItems.togglePublished()
                } }
            MenuItem {
                id: toggleReadMenuItem
                text: model.unread ? qsTr("Mark read") : qsTr("Mark Unread")
                onClicked: {
                    feedItems.toggleRead()
                } }
            MenuItem {
                id: openInBrowserMenuItem
                text: qsTr("Open in Web Browser")
                visible: model.url && model.url !== ""
                onClicked: {
                    var item = feedItems.getSelectedItem()
                    Qt.openUrlExternally(item.url)
                }
            }
            Component.onCompleted: {
                feedItems.selectedIndex = index
            }
        }
    }
}
