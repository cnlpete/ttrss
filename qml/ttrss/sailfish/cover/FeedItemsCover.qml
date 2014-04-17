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

import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    id: root

    property bool active: status === Cover.Active

    Column {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: Theme.paddingLarge
        }
        Image {
            source: '/usr/share/icons/hicolor/86x86/apps/harbour-ttrss-cnlpete.png'
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label {
            width: parent.width
            truncationMode: TruncationMode.Fade
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.primaryColor
            maximumLineCount: 1
            text: feeds.getSelectedItem().title
        }
        Label {
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeHuge
            font.weight: Font.Light
            textFormat: Text.PlainText
            text: feeds.getSelectedItem().unreadcount
        }
        Label {
            text: qsTr("Unread Items")
            id: countText
            width: parent.width
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeSmall
            textFormat: Text.StyledText
            lineHeight: 0.7
            wrapMode: Text.WordWrap
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        opacity: running ? 1 : 0
        running: active && network.loading
        Behavior on opacity { FadeAnimation{} }
    }

    CoverActionList {
        id: coverAction
        enabled: !network.visible

        CoverAction {
            iconSource: "image://theme/icon-cover-sync"
            onTriggered: {
                feeditems.update()
            }
        }
    }
}
