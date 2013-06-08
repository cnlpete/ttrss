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

Item {
    id: root

    signal clicked
    signal pressAndHold
    property alias pressed: mouseArea.pressed

    height: 88
    width: parent.width

    BorderImage {
        id: background
        anchors.fill: parent
        // Fill page borders
        anchors.leftMargin: -constant.paddingLarge
        anchors.rightMargin: -constant.paddingLarge
        visible: mouseArea.pressed
        source: "image://theme/meegotouch-list-background-selected-center"
    }

    Row {
        spacing: constant.paddingMedium
        anchors.fill: parent
        Image {
            source: "resources/ic_star_enabled.png"
            visible: model.marked
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.5
        }
        Image {
            source: "resources/ic_rss_enabled.png"
            visible: model.rss
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.5
        }
    }

    Row {
        anchors.left: parent.left
        anchors.right: drilldownarrow.left
        clip: true

        Column {

            Label {
                id: mainText
                text: model.title
                font.weight: Font.Bold
                font.pixelSize: constant.fontSizeLarge
                color: (model.unread > 0) ? constant.colorListItemActive : constant.colorListItemDisabled;
                elide: Text.ElideRight
            }

            Label {
                id: subText
                text: model.subtitle
                font.weight: Font.Light
                font.pixelSize: constant.fontSizeSmall
                color: (model.unread > 0) ? constant.colorListItemActiveTwo : constant.colorListItemDisabled;
                elide: Text.ElideRight
                visible: text != ""
            }
        }
    }

    Image {
        id: drilldownarrow
        source: "image://theme/icon-m-common-drilldown-arrow" + (theme.inverted ? "-inverse" : "")
        anchors.right: parent.right;
        anchors.verticalCenter: parent.verticalCenter
        visible: ((model.id != null)&&(model.id !== "__ttrss_get_more_items"))
    }

    MouseArea {
        id: mouseArea
        anchors.fill: background
        onClicked: root.clicked();
        onPressAndHold: root.pressAndHold();
    }
}
