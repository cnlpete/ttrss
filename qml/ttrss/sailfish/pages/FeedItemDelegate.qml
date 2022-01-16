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

ListItem {
    id: listItem
    signal remorseRunning(bool running)
    property bool selected: model.selected

    showMenuOnPressAndHold: false

    highlighted: down || menuOpen || selected

    contentHeight: content.height + contentRow.anchors.topMargin
                   + contentRow.anchors.bottomMargin
    width: parent.width

    Row {
        id: markerRow
        spacing: Theme.paddingMedium
        anchors.rightMargin: Theme.paddingMedium
        anchors.right: parent.right

        Icon {
            source: "qrc:///images/ic_star.svg"
            visible: model.marked
            color: Theme.highlightColor
            highlighted: listItem.highlighted
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.5
            width: Theme.iconSizeSmallPlus
            height: Theme.iconSizeSmallPlus
        }
        Icon {
            source: "qrc:///images/ic_rss.svg"
            visible: model.rss
            color: Theme.highlightColor
            highlighted: listItem.highlighted
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.5
            width: Theme.iconSizeSmallPlus
            height: Theme.iconSizeSmallPlus
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
            width: icon.visible ?
                       (parent.width - icon.width - contentRow.spacing) :
                       parent.width

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
                textFormat: Text.RichText
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
            Label {
                width: parent.width
                text: model.note === undefined || model.note === "" ?
                          "" :
                          qsTr("Note: %1").arg(model.note)
                color: model.unread > 0 ?
                           (listItem.highlighted ? Theme.highlightColor : Theme.primaryColor) :
                           (listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor)
                maximumLineCount: settings.lengthOfNote
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                truncationMode: TruncationMode.Elide
                textFormat: Text.PlainText
                font.weight: Font.Light
                font.italic: true
                font.pixelSize: Theme.fontSizeExtraSmall
                visible: settings.showNote && text !== ""
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

    function markAllAboveAsRead() {
        listItem.remorseRunning(true)
        remorse.execute(listItem,
                        qsTr("Marking all above as read"),
                        function() {
                            feedItemModel.markAllAboveAsRead(index)
                        })
    }
}
