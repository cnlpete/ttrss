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


    tools: ToolBarLayout {
        ToolIcon {
            iconId: 'toolbar-back'
            onClicked: pageStack.pop()
        }
    }

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
}
