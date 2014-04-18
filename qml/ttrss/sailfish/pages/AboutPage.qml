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

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: aboutPage
    property alias iconSource: icon.source
    property alias title: title.title
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


    SilicaFlickable {
        anchors.fill: parent
        contentHeight: aboutContainer.height + 10
        contentWidth: parent.width

        PullDownMenu {
            MenuItem {
                text: qsTr("License")
                onClicked: {
                    var params = {
                        title: qsTr("License"),
                        iconSource: iconSource,
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
                    pageStack.push("TextPage.qml", params)
                }
            }
            MenuItem {
                text: qsTr("Privacy Policy")
                onClicked: {
                    var params = {
                        title: qsTr("Privacy Policy"),
                        iconSource: iconSource,
                        text: "ttrss will collect the login information you give at startup and nothing more.
                            Your login data is stored in a configuration file on your device and nowhere else.
                            ttrss will only use it to establish connections to the available services and/or servers.
                            The login data is not given to any third party and is not used for any other purpose than the functions of ttrss.
                            <br><br>
                            If you have any questions, concerns, or comments about our privacy policy you may contact us via:<br>
                            <a href='mailto:cnlpete@cnlpete.de'>cnlpete@cnlpete.de</a>"
                    }
                    pageStack.push("TextPage.qml", params)
                }
            }
        }

        Item {
            id: aboutContainer
            width: parent.width
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

                PageHeader {
                    id: title
                }

                Image {
                    id: icon
                    source: ''
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
}
