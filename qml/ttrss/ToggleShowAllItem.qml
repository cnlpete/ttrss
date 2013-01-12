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
import com.nokia.meego 1.0

MenuItem {
    id: toggleUnread

    property bool showAll
    signal updateView(bool showAll)

    text: showAll ? qsTr("Show Unread Only") : qsTr("Show All")
    onClicked: {
        var ttrss = rootWindow.getTTRSS();
        ttrss.setShowAll(!showAll);
        showAll = !showAll
    }

    onShowAllChanged: {
        // send the signal
        var ttrss = rootWindow.getTTRSS();
        ttrss.trace(4, "showAll changed to " + ttrss.dump(showAll) + " sending signal")
        updateView(showAll)
    }

    onVisibleChanged: {
        if (visible) {
            var ttrss = rootWindow.getTTRSS();
            showAll = ttrss.getShowAll();
        }
    }
}
