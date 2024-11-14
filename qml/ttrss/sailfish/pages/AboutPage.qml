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

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../resources/gplv2.js" as License
import "../../resources/privacypolicy.js" as PrivacyPolicy
import "../items"

Page {
    id: aboutPage

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: aboutColumn.height
        contentWidth: parent.width

        PullDownMenu {
            MenuItem {
                text: qsTr("License")
                onClicked: {
                    var params = {
                        mytitle: qsTr("License"),
                        mydata: [
                            ["", License.brief],
                            [qsTr("Full License"), License.full]
                        ]
                    }
                    pageStack.push(Qt.resolvedUrl("TextPage.qml"), params);
                }
            }
            MenuItem {
                text: qsTr("Privacy Policy")
                onClicked: {
                    var params = {
                        mytitle: qsTr("Privacy Policy"),
                        mydata: [ ["", PrivacyPolicy.sec1], ["", PrivacyPolicy.sec2] ]
                    }
                    pageStack.push(Qt.resolvedUrl("TextPage.qml"), params)
                }
            }
        }

        Column {
            id: aboutColumn
            width: parent.width

            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingMedium
            }
            spacing: Theme.paddingMedium

            PageHeader {
                id: title
                title: 'ttrss ' + APP_VERSION
            }

            Image {
                id: icon
                source: Qt.resolvedUrl("/usr/share/icons/hicolor/86x86/"
                                       + "apps/harbour-ttrss-cnlpete.png")
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.pixelSize: Theme.fontSizeSmall
                text: "<b>Copyright © 2012–2020 Hauke Schade</b>"
            }

            Row {
                width: parent.width - 2 * Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingMedium
                Button {
                    width: Math.floor(parent.width / 2) - Theme.paddingMedium
                    text: qsTr("Buy me a beer")
                    onClicked: {
                        Qt.openUrlExternally(constant.donateUrl)
                    }
                }
                Button {
                    width: Math.floor(parent.width / 2) - Theme.paddingMedium
                    text: qsTr("Homepage")
                    onClicked: {
                        Qt.openUrlExternally(constant.website)
                    }
                }
            }

            // -- Contributors --
            Label {
                width: parent.width
                horizontalAlignment: Text.AlignRight
                color: Theme.highlightColor
                text: qsTr("Contributors")
                font.pixelSize: Theme.fontSizeSmall;
            }
            Label {
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.pixelSize: Theme.fontSizeSmall
                text: "Francois Cattin, Jakub Kožíšek, Alberto Mardegan, "
                      + "gwmgdemj, equeim, Silviu Vulcan, Michael Käufl, "
                      + "Patrik Nilsson, Alexey, clovis86, Heimen Stoffels, "
                      + "mp107, dashinfantry, Alexus230, Priit Jõerüüt "
            }

            // -- Feature Requests & Bugs --
            Label {
                width: parent.width
                horizontalAlignment: Text.AlignRight
                color: Theme.highlightColor
                text: qsTr("Feature Requests & Bugs")
                font.pixelSize: Theme.fontSizeSmall;
            }
            Label {
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: qsTr("If you encounter bugs or have feature requests, "
                           + "please visit the Issue Tracker")
            }
            Button {
                id: issuetrackerbutton
                width: parent.width / 2 - Theme.paddingMedium
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Issuetracker")
                visible: constant.issueTrackerUrl !== ''
                onClicked: {
                    Qt.openUrlExternally(constant.issueTrackerUrl)
                }
            }

            // -- Legal Notice --
            Label {
                width: parent.width
                horizontalAlignment: Text.AlignRight
                color: Theme.highlightColor
                text: qsTr("Legal Notice")
                font.pixelSize: Theme.fontSizeSmall;
            }
            Label {
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.pixelSize: Theme.fontSizeSmall
                text: "TTRss comes with ABSOLUTELY NO WARRANTY. "
                      + "TTRss is free software, and you are welcome to "
                      + "redistribute it under certain conditions. "
                      + "See the License for details."
            }
            Label {
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.pixelSize: Theme.fontSizeSmall
                text: qsTr("The source code is available at %1.").arg(
                          "<a href=\"" + constant.sourceRepoSite + "\">"
                          + constant.sourceRepoSite + "</a>")
            }
        }
    }
}
