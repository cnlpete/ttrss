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

import QtQuick 1.1
import com.nokia.meego 1.0

Sheet {
    id: page
    property string previousNote
    property variant feedItemPage

    acceptButtonText: canAccept ? qsTr("Save Note") : ""
    rejectButtonText: qsTr("Cancel")

    property bool canAccept: false

    content: Flickable {
        contentHeight: area.height + Theme.paddingMedium + header.height
        contentWidth: parent.width
        anchors.fill: parent

        Column {
            width: parent.width
            spacing: MyTheme.paddingMedium
            Label {
                id: header
                width: parent.width
                text: qsTr("Edit Note")
            }

            TextArea {
                id: area
                width: parent.width
                height: 80

                focus: true
                text: page.previousNote

                Component.onCompleted: {
                    // We don't want to change page.canAccept during initialization.
                    area.textChanged.connect(function() {
                                                 if (page.previousNote != text)
                                                     page.canAccept = true
                                             })
                }
            }
        }
    }

    onAccepted: {
        feedItemPage.updateNote(area.text)
    }
}
