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

Item {
    id: root

    signal clicked
    signal pressAndHold
    property alias pressed: mouseArea.pressed

    height: mainText.parent.height + MyTheme.paddingMedium
    width: parent.width

    BorderImage {
        id: background
        anchors.fill: parent
        // Fill page borders
        anchors.leftMargin: -MyTheme.paddingMedium
        anchors.rightMargin: -MyTheme.paddingMedium
        visible: mouseArea.pressed
        source: "image://theme/meegotouch-list-background-selected-center"
    }

    Row {
        spacing: MyTheme.paddingMedium
        anchors.fill: parent
        anchors.leftMargin: icon.visible ? icon.width + MyTheme.paddingMedium : 0
        Image {
            source: "../resources/ic_star_enabled.png"
            visible: model.marked
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.5
        }
        Image {
            source: "../resources/ic_rss_enabled.png"
            visible: model.rss
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.5
        }
    }

    Row {
        anchors.left: parent.left
        anchors.right: drilldownarrow.left
        spacing: MyTheme.paddingMedium
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
            //TODO
//            onStatusChanged: {
//                if (status === Image.Error)
//                    feeds.unsetIcon(index)
//            }

            visible: settings.displayIcons && model.icon != '' && feed.isCat && status == Image.Ready
        }

        Column {
            Label {
                id: mainText
                text: model.title
                font.weight: Font.Bold
                font.pixelSize: MyTheme.fontSizeLarge
                color: (model.unread) ?
                           (theme.inverted ? MyTheme.primaryColorInverted : MyTheme.primaryColor) :
                           (theme.inverted ? MyTheme.secondaryColorInverted : MyTheme.secondaryColor)
                elide: Text.ElideRight
            }

            Label {
                id: subText
                text: model.subtitle
                font.weight: Font.Light
                font.pixelSize: MyTheme.fontSizeSmall
                color: (model.unread) ?
                           (theme.inverted ? MyTheme.highlightColorInverted : MyTheme.highlightColor) :
                           (theme.inverted ? MyTheme.secondaryHighlightColorInverted : MyTheme.secondaryHighlightColor)
                elide: Text.ElideRight
                visible: text != ""
            }
            Row {
                id: myrow
                property variant mymod: model
                spacing: MyTheme.paddingSmall

                Repeater {
                    model: myrow.mymod.labels
                    LabelLabel {
                        label: myrow.mymod.labels.get(index)
                    }
                }
            }
        }
    }

    Image {
        id: drilldownarrow
        source: "image://theme/icon-m-common-drilldown-arrow" + (theme.inverted ? "-inverse" : "")
        anchors.right: parent.right;
        anchors.verticalCenter: parent.verticalCenter
        visible: model.id !== null
    }

    MouseArea {
        id: mouseArea
        anchors.fill: background
        onClicked: root.clicked();
        onPressAndHold: root.pressAndHold();
    }
}
