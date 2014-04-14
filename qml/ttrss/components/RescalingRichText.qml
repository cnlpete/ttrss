/* Copyright (C) 2013 Martin Grimme <martin.grimme _AT_ gmail.com>
*
* This file was adapted from Tidings
* Copyright (C) 2013 Martin Grimme <martin.grimme _AT_ gmail.com>
*
* It was then adjusted by Hauke Schade <cnlpete _AT_ cnlpete.de>
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/

import QtQuick 1.1

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
    property real fontSize: MyTheme.fontSizeSmall
    property string _RICHTEXT_STYLESHEET_PREAMBLE: "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><style>a { text-decoration: none; color: '" + theme.selectionColor + "' }</style></head><body>";
    property string _RICHTEXT_STYLESHEET_APPENDIX: "</body></html>";
    property bool useRichText: true
//    property real maxScaling: 0.5

    property real scaling: 1

    signal linkActivated(string link)

    height: contentText.height * scaling
    clip: true

    onWidthChanged: {
        rescaleTimer.restart();
    }

    Text {
        id: layoutText
        visible: false
        width: parent.width
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        textFormat: useRichText ? Text.RichText : Text.StyledText

        text: useRichText ? "<style>* { font-size: 1px }</style>" + parent.text : parent.text

        onPaintedWidthChanged: {
            console.log("contentWidth: " + paintedWidth)
            rescaleTimer.restart()
        }

        onTextChanged: rescaleTimer.restart()
    }

    Text {
        id: contentText

        width: parent.width / scaling
        scale: scaling

        transformOrigin: Item.TopLeft
        font.pointSize: parent.fontSize / scaling
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        textFormat: useRichText ? Text.RichText : Text.StyledText
        smooth: true
        font.weight: Font.Light

//        text: useRichText ? _RICHTEXT_STYLESHEET_PREAMBLE + parent.text + _RICHTEXT_STYLESHEET_APPENDIX : parent.text

        onLinkActivated: {
            root.linkActivated(link);
        }
    }

    Timer {
        id: rescaleTimer
        interval: 100

        onTriggered: {
            var paintedWidth = Math.floor(layoutText.paintedWidth);
            scaling = Math.min(1, parent.width / (layoutText.paintedWidth + 0.0));
//            scaling = Math.max(scaling, root.maxScaling)
            console.log("scaling: " + scaling);

            // set text to content item
            contentText.text = useRichText ? _RICHTEXT_STYLESHEET_PREAMBLE + parent.text + _RICHTEXT_STYLESHEET_APPENDIX : parent.text
        }
    }
}
