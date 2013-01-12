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

                    left: parent.left
                    top: parent.top
                }
            }
            AnchorChanges {
                target: aboutInfoContainer
                anchors {
                    horizontalCenter: undefined

                    left: logo.right
                    top: logo.top
                }
            }
            PropertyChanges {
                target: aboutInfoContainer
                anchors.leftMargin: 50
            }
        },
        State {
            name: "portrait"
            AnchorChanges {
                target: logo
                anchors {
                    left: undefined

                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
            }
            AnchorChanges {
                target: aboutInfoContainer
                anchors {
                    left: undefined

                    top: logo.bottom
                    horizontalCenter: parent.horizontalCenter
                }
            }
            PropertyChanges {
                target: aboutInfoContainer
                anchors.topMargin: 50
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
            width: 350
            text:  qsTr("Version")+": 0.1.0<br/>"
                  +qsTr("Copyright")+": Hauke Schade 2012<br/>"
                   +'';
            onLinkActivated: {
                Qt.openUrlExternally(link)
            }
        }
        Button {
            text: qsTr("Homepage")
            onClicked: {
                Qt.openUrlExternally(constant.sourceRepoSite)
            }
        }
        Label {
            width: 350
            text: qsTr("If you encounter bugs or have feature requests, please visit the Issue Tracker")
        }
        Button {
            text: qsTr("Issue Tracker")
            onClicked: {
                Qt.openUrlExternally(constant.issueTrackerUrl)
            }
        }
        Button {
            text: qsTr("License")
            onClicked: {
                popup.open();
            }
        }
    }

    SimplePopup {
        id: popup
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


    ToolBarLayout {
        id: aboutTools

        ToolIcon {
            iconId: "toolbar-back";
            onClicked: { pageStack.pop(); }
        }
    }
}

