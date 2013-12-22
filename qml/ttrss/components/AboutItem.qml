//Copyright Hauke Schade, 2012-2013
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
    text: qsTr("About")
    onClicked: {
        var params = {
            title : 'ttrss ' + APP_VERSION,
            iconSource: Qt.resolvedUrl('/usr/share/icons/hicolor/80x80/apps/ttrss80.png'),
//            slogan : '',
            donatebutton: qsTr("Buy me a beer"),
            donateurl: constant.donateUrl,
            text: qsTr("Author: %1").arg("Hauke Schade 2013") + "<br/>"
                   + qsTr("Thanks to:") + " "
                    + "Francois Cattin, Jakub Kožíšek, Alberto Mardegan, gwmgdemj, equeim",
            homepageurl: constant.sourceRepoSite,
            issuetrackertext: qsTr("If you encounter bugs or have feature requests, please visit the Issue Tracker"),
            issuetrackerurl: constant.issueTrackerUrl
        }

        rootWindow.openFile("../components/AboutPage.qml", params);
    }
}
