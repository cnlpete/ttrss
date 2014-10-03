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

import QtQuick 1.1
import com.nokia.meego 1.0

Page {
    id: aboutPage
    property alias iconSource: icon.source
    property alias title: title.text
    property alias slogan: slogan.text

    property alias donatetext: donatetext.text
    property alias donatebutton: donatebutton.text
    property string donateurl: donate.text

    property alias homepagebutton: homepagebutton.text
    property string homepageurl: ''

    property alias text: content.text

    property alias issuetrackerbutton: issuetrackerbutton.text
    property alias issuetrackertext: issuetrackertext.text
    property string issuetrackerurl: ''


    tools: aboutTools

    Flickable {
        anchors.fill: parent
        contentHeight: aboutContainer.height + 10
        contentWidth: aboutContainer.width

        Item {
            id: aboutContainer
            width: aboutPage.width
            height: aboutColumn.height

            Column {
                id: aboutColumn

                anchors {
                    left: parent.left
                    top: parent.top
                    right: parent.right
                    margins: 10
                }

                spacing: 10

                Image {
                    id: icon
                    source: ''
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Label {
                    id: title
                    text: 'Name 0.0.0'
                    font.pixelSize: 40
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Label {
                    id: slogan
                    text: ''
                    visible: text !== ''
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Label {
                    id: donatetext
                    text: ''
                    visible: text !== ''
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Button {
                    id: donatebutton
                    width: parent.width
                    text: qsTr("Donate")
                    visible: donateurl !== ''
                    onClicked: {
                        Qt.openUrlExternally(donateurl)
                    }
                }

                Button {
                    id: homepagebutton
                    width: parent.width
                    text: qsTr("Homepage")
                    visible: homepageurl !== ''
                    onClicked: {
                        Qt.openUrlExternally(homepageurl)
                    }
                }

                Item {
                    width: 1
                    height: 50
                }
                Label {
                    id: content
                    text: ''
                    width: aboutPage.width
                    wrapMode: Text.WordWrap
                }
                Item {
                    width: 1
                    height: 50
                }

                Label {
                    id: issuetrackertext
                    text: ''
                    visible: text !== ''
                    width: aboutPage.width
                    wrapMode: Text.WordWrap
                }
                Button {
                    id: issuetrackerbutton
                    width: parent.width
                    text: qsTr("Issuetracker")
                    visible: issuetrackerurl !== ''
                    onClicked: {
                        Qt.openUrlExternally(issuetrackerurl)
                    }
                }
            }
        }
    }
    SimplePopup {
        id: license
        text: "TTRss is free software; you can redistribute it and/or modify
                    it under the terms of the GNU General Public License as published by
                    the Free Software Foundation; either version 2 of the License, or
                    (at your option) any later version.<br>
                    <br>
                    TTRss is distributed in the hope that it will be useful,
                    but WITHOUT ANY WARRANTY; without even the implied warranty of
                    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
                    GNU General Public License for more details.<br>
                    <br>
                    You should have received a copy of the GNU General Public License
                    along with TTRss. If not, see <a href=\"http://www.gnu.org/licenses/\">http://www.gnu.org/licenses/</a>."
    }

    SimplePopup {
        id: privacypolicy
        text: "ttrss will collect the login information you give at startup and nothing more.
                    Your login data is stored in a configuration file on your device and nowhere else.
                    ttrss will only use it to establish connections to the available services and/or servers.
                    The login data is not given to any third party and is not used for any other purpose than the functions of ttrss.
                    <br><br>
                    If you have any questions, concerns, or comments about our privacy policy you may contact us via:<br>
                    <a href='mailto:cnlpete@cnlpete.de'>cnlpete@cnlpete.de</a>"
    }


    ToolBarLayout {
        id: aboutTools
        ToolIcon {
            iconId: "toolbar-back";
            onClicked: { pageStack.pop(); }
        }
        ToolIcon {
            iconId: "toolbar-view-menu" ;
            onClicked: (menu.status === DialogStatus.Closed) ? menu.open() : menu.close()
        }
    }
    Menu {
        id: menu
        visualParent: pageStack

        MenuLayout {
            MenuItem {
                text: qsTr("License")
                onClicked: {
                    license.open();
                }
            }
            MenuItem {
                text: qsTr("Privacy Policy")
                onClicked: {
                    privacypolicy.open();
                }
            }
        }
    }
}
