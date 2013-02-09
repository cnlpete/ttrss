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
import QtWebKit 1.0

Page {
    tools: aboutTools

    state: (screen.currentOrientation === Screen.Portrait) ? "portrait" : "landscape"

    states: [
        State {
            name: "landscape"
            PropertyChanges {
                target: logo
                anchors.leftMargin: 50
                anchors.topMargin: 50
            }
            AnchorChanges {
                target: logo
                anchors {
                    horizontalCenter: undefined
                    top: undefined

                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }
            PropertyChanges {
                target: aboutInfoContainer
                anchors.rightMargin: 50
                width: 400
            }
            AnchorChanges {
                target: aboutInfoContainer
                anchors {
                    horizontalCenter: undefined
                    top: undefined

                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
            }
        },
        State {
            name: "portrait"
            AnchorChanges {
                target: logo
                anchors {
                    left: undefined
                    verticalCenter: undefined

                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
            }
            PropertyChanges {
                target: aboutInfoContainer
                anchors.topMargin: 50
                width: 350
            }
            AnchorChanges {
                target: aboutInfoContainer
                anchors {
                    left: undefined
                    verticalCenter: undefined

                    top: logo.bottom
                    horizontalCenter: parent.horizontalCenter
                }
            }
        }
    ]

    transitions: Transition {
        AnchorAnimation { duration: 500 }
    }


    Column {
        id: logo
        anchors {
            top: parent.top
            topMargin:  30
        }

        Image {
            width: 256
            height: 256
            source: "resources/ttrss256.png"
        }
    }

    Column {
        id: aboutInfoContainer

        Label {
            width: parent.width
            text:  qsTr("Version: %1").arg(APP_VERSION) + "<br/>"
                   +qsTr("Author: %1").arg("Hauke Schade 2012") + "<br/>"
                   +qsTr("Thanks to:") + " "
                   + "Francois Cattin"
            onLinkActivated: {
                Qt.openUrlExternally(link)
            }
        }
        Button {
            width: parent.width
            text: qsTr("Homepage")
            onClicked: {
                Qt.openUrlExternally(constant.sourceRepoSite)
            }
        }
        Label {
            width: parent.width
            text: qsTr("If you encounter bugs or have feature requests, please visit the Issue Tracker")
        }
        Button {
            width: parent.width
            text: qsTr("Issue Tracker")
            onClicked: {
                Qt.openUrlExternally(constant.issueTrackerUrl)
            }
        }
    }

    SimplePopup {
        id: license
        text: "This program is free software; you can redistribute it and/or modify
                it under the terms of the GNU General Public License as published by
                the Free Software Foundation; either version 2 of the License, or
                (at your option) any later version.<br>
                <br>
                This program is distributed in the hope that it will be useful,
                but WITHOUT ANY WARRANTY; without even the implied warranty of
                MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
                GNU General Public License for more details.<br>
                <br>
                You should have received a copy of the GNU General Public License
                along with this program. If not, see <a href=\"http://www.gnu.org/licenses/\">http://www.gnu.org/licenses/</a>."
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

