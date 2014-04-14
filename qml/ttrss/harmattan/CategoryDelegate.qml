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
import "../components" 1.0

Item {
    id: root

    signal clicked
    signal pressAndHold
    property alias pressed: mouseArea.pressed

    height: 80
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

    Label {
        id: mainText
        text: model.title
        anchors.right: unreadBubble.left
        anchors.rightMargin: MyTheme.paddingMedium
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter
        font.weight: Font.Bold
        font.pixelSize: MyTheme.fontSizeLarge
        color: (model.unreadcount > 0) ?
                   (theme.inverted ? MyTheme.primaryColorInverted : MyTheme.primaryColor) :
                   (theme.inverted ? MyTheme.secondaryColorInverted : MyTheme.secondaryColor)
    }

    Bubble {
        id: unreadBubble
        anchors.right: drilldownarrow.left
        anchors.rightMargin: MyTheme.paddingMedium
        anchors.verticalCenter: parent.verticalCenter

        amount: model.unreadcount
        color: (model.unreadcount > 0) ?
                   (theme.inverted ? MyTheme.highlightColorInverted : MyTheme.highlightColor) :
                   (theme.inverted ? MyTheme.secondaryHighlightColorInverted : MyTheme.secondaryHighlightColor)
    }

    Image {
        id: drilldownarrow
        anchors.right: parent.right
        anchors.rightMargin: 0
        source: "image://theme/icon-m-common-drilldown-arrow" + (theme.inverted ? "-inverse" : "")
        anchors.verticalCenter: parent.verticalCenter
        visible: model.categoryId != null
    }

    MouseArea {
        id: mouseArea;
        anchors.fill: parent
        onClicked: root.clicked();
        onPressAndHold: root.pressAndHold();
    }
}
