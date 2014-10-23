/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2014  Hauke Schade
 *
 * This file was adapted from Tidings
 * (https://github.com/pycage/tidings).
 * Copyright (C) 2013–2014 Martin Grimme <martin.grimme _AT_ gmail.com>
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

/* Pretty fancy element for displaying rich text fitting the width.
 *
 * Images are scaled down to fit the width, or, technically speaking, the
 * rich text content is actually scaled down so the images fit, while the
 * font size is scaled up to keep the original font size.
 */

Item {
    id: root

    property string text
    property alias color: contentText.color
    property real fontSize: Theme.fontSizeSmall

    property string _RICHTEXT_STYLESHEET_PREAMBLE: "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><style>a { text-decoration: none; color: '" + Theme.highlightColor + "' }</style></head><body>";
    property string _RICHTEXT_STYLESHEET_APPENDIX: "</body></html>";

    property real scaling: 1

    signal linkActivated(string link)

    height: contentText.height * scaling
    clip: true

    onWidthChanged: {
        rescaleTimer.restart()
    }

    Text {
        id: layoutText

        visible: false
        width: parent.width
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        textFormat: Text.RichText

        text: "<style>* { font-size: 1px }</style>" + parent.text

        onContentWidthChanged: {
            console.log("contentWidth: " + contentWidth)
            rescaleTimer.restart()
        }
    }

    Text {
        id: contentText

        width: Math.max(1, parent.width) / scaling
        scale: scaling

        transformOrigin: Item.TopLeft
        font.pixelSize: parent.fontSize / scaling
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        textFormat: Text.RichText
        smooth: true

        //text: _RICHTEXT_STYLESHEET_PREAMBLE + parent.text + _RICHTEXT_STYLESHEET_APPENDIX

        onLinkActivated: {
            root.linkActivated(link)
        }
    }

    Timer {
        id: rescaleTimer
        interval: 100

        onTriggered: {
            var contentWidth = Math.floor(layoutText.contentWidth + 0.0)
            scaling = Math.min(1, parent.width / contentWidth)
            console.log("scaling: " + scaling)

            // force reflow
            //contentText.text = contentText.text + " "
            contentText.text = _RICHTEXT_STYLESHEET_PREAMBLE + parent.text + _RICHTEXT_STYLESHEET_APPENDIX

        }
    }
}
