/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2014  Hauke Schade
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

MenuItem {
    text: qsTr("About")
    onClicked: {
        var params = {
            title : 'ttrss ' + APP_VERSION,
            iconSource: Qt.resolvedUrl('/usr/share/icons/hicolor/86x86/apps/harbour-ttrss-cnlpete.png'),
//            slogan : '',
            donatebutton: qsTr("Buy me a beer"),
            donateurl: constant.donateUrl,
            text: qsTr("Author: %1").arg("Hauke Schade") + "<br/>"
                   + qsTr("Thanks to:") + " "
                    + "Francois Cattin, Jakub Kožíšek, Alberto Mardegan, gwmgdemj, equeim, Silviu Vulcan",
            homepageurl: constant.sourceRepoSite,
            issuetrackertext: qsTr("If you encounter bugs or have feature requests, please visit the Issue Tracker"),
            issuetrackerurl: constant.issueTrackerUrl
        }

        pageStack.push(Qt.resolvedUrl("../pages/AboutPage.qml"), params);
    }
}
