/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2015  Hauke Schade
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

MenuItem {
    text: qsTr("About")
    onClicked: {
        var params = {
            title : 'ttrss ' + APP_VERSION,
            iconSource: Qt.resolvedUrl('/usr/share/icons/hicolor/80x80/apps/ttrss80.png'),
//            slogan : '',
            donatebutton: qsTr("Buy me a beer"),
            donateurl: constant.donateUrl,
            text: qsTr("Author: %1").arg("Hauke Schade 2012-2015") + "<br/>"
                   + qsTr("Thanks to:") + " "
                    + "Francois Cattin, Jakub Kožíšek, Alberto Mardegan, gwmgdemj, equeim, Silviu Vulcan, Michael Käufl, Patrik Nilsson, Alexey, clovis86, Heimen Stoffels",
            homepageurl: constant.website,
            issuetrackertext: qsTr("If you encounter bugs or have feature requests, please visit the Issue Tracker"),
            issuetrackerurl: constant.issueTrackerUrl
        }

        rootWindow.openFile("../components/AboutPage.qml", params);
    }
}
