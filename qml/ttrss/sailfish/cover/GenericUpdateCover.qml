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
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    property alias headline: header.text
    property alias unreadCount: count.text

    signal updateTriggered()

    property bool active: status === Cover.Active

    Column {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: Theme.paddingLarge
        }

        Image {
            source: Qt.resolvedUrl("/usr/share/icons/hicolor/86x86/apps/"
                                   + "harbour-ttrss-cnlpete.png")
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Label {
            id: header
            visible: text != ''

            maximumLineCount: 1
            truncationMode: TruncationMode.Fade

            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.primaryColor
        }

        Label {
            id: count
            visible: text != ''

            font.weight: Font.Light
            textFormat: Text.PlainText

            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: Theme.fontSizeHuge
            color: Theme.primaryColor
        }

        Label {
            text: qsTr("Unread Items")

            lineHeight: 0.7
            textFormat: Text.PlainText
            wrapMode: Text.WordWrap

            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.primaryColor
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        opacity: running ? 1 : 0
        running: active && network.loading
        Behavior on opacity { FadeAnimation{} }
    }

    CoverActionList {
        enabled: !network.visible

        CoverAction {
            iconSource: "image://theme/icon-cover-sync"
            onTriggered: updateTriggered()
        }
    }
}
