//Copyright Hauke Schade, 2012
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

QtObject{
    id: constant

    property color colorListItemActive: "#000033"
    property color colorListItemActiveTwo: "#cc6633"
    property color colorListItemDisabled: "#888888"

    property int paddingSmall: 4
    property int paddingMedium: 6
    property int paddingLarge: 8
    property int paddingXLarge: 12
    property int paddingXXLarge: 16

    property int fontSizeXSmall: 20
    property int fontSizeSmall: 22
    property int fontSizeMedium: 24
    property int fontSizeLarge: 26
    property int fontSizeXLarge: 28
    property int fontSizeXXLarge: 32

    property int headerHeight: inPortrait ? 72 : 56

    property url sourceRepoSite: "http://cnlpete.github.com/ttrss"
}
