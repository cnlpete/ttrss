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

import QtQuick 2.0
import Sailfish.Silica 1.0

MenuItem {
    property bool showAll
    property bool notInitialAssignment: false
    signal updateView(bool showAll)

    text: showAll ? qsTr("Show Unread Only") : qsTr("Show All")
    onClicked: {
        var ttrss = rootWindow.getTTRSS()
        ttrss.setShowAll(!showAll)
        showAll = !showAll
        settings.showAll = showAll
    }

    onShowAllChanged: {
        // send the signal only if this is not the initial assignment
        if (notInitialAssignment) {
            updateView(showAll)
        }
    }

    Component.onCompleted: {
        showAll = settings.showAll
        var ttrss = rootWindow.getTTRSS()
        ttrss.setShowAll(showAll)
        notInitialAssignment = true
    }

    onVisibleChanged: {
        if (visible && notInitialAssignment) {
            var ttrss = rootWindow.getTTRSS()
            showAll = ttrss.getShowAll()
        }
    }
}
