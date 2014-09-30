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
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA or see
 * http://www.gnu.org/licenses/.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    property alias title: title.title
    property alias data: rep.model

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: textContainer.height
        contentWidth: parent.width

        Column {
            id: textContainer
            width: parent.width

            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingMedium
            }
            spacing: Theme.paddingMedium

            PageHeader {
                id: title
            }

            Repeater {
                id: rep
                Column {
                    spacing: Theme.paddingMedium
                    Label {
                        width: textContainer.width
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeSmall
                        text: modelData[0]
                        visible: text != ''
                        horizontalAlignment: Text.AlignRight
                    }
                    Text {
                        width: textContainer.width
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        text: modelData[1]
                        visible: text != ''
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        textFormat: Text.RichText
                    }
                }
            }
        }
        ScrollDecorator{}
    }
}
