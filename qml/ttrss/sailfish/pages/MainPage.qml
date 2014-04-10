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
    SilicaFlickable {
        contentHeight: contentcontainer.height
        contentWidth: parent.width
        anchors.fill: parent

        PullDownMenu {
            AboutItem {}
            SettingsItem {}
            MenuItem {
                text: qsTr("No Account Yet?")
                onClicked: {
                    rootWindow.openFile(Qt.openUrlExternally("http://tt-rss.org/redmine/projects/tt-rss/wiki"));
                }
            }
        }

        Rectangle {
            width: parent.width
            anchors.margins: Theme.paddingLarge
            Column {
                id: contentcontainer
                width: 350
                anchors.horizontalCenter: parent.horizontalCenter

                Image {
                    width: 256
                    height: 256
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "../../resources/ttrss256.png"

                    anchors.bottomMargin: Theme.paddingLarge
                }

                Label {
                    id: serverLabel
                    text: qsTr("Server:")
                    width: parent.width
                    font.pixelSize: Theme.fontSizeMedium
                }
                TextField {
                    id: server
                    text: ""
                    width: parent.width
                    enabled: !network.loading
                }
                Label {
                    id: usernameLabel
                    text: qsTr("Username:")
                    width: parent.width
                    font.pixelSize: Theme.fontSizeMedium
                }
                TextField {
                    id: username
                    text: ""
                    width: parent.width
                    enabled: !network.loading
                }
                Label {
                    id: passwordLabel
                    text: qsTr("Password:")
                    width: parent.width
                    font.pixelSize: Theme.fontSizeMedium
                }
                TextField {
                    id: password
                    echoMode: TextInput.Password
                    width: parent.width
                    enabled: !network.loading
                }
                TextSwitch {
                    text: qsTr('Ignore SSL Errors')
                    visible: server.text.substring(0, 5) === "https"
                    checked: settings.ignoreSSLErrors
                    onCheckedChanged: settings.ignoreSSLErrors = checked
                }
                Button {
                    id: loginButton
                    text: qsTr("Login")
                    width: parent.width
                    onClicked: {
                        // check the servername for httpauth data and set/extract those
                        var httpauthregex = /(https?:\/\/)?(\w+):(\w+)@(\w.+)/
                        var servername = server.text
                        var regexres = servername.match(httpauthregex)
                        if (regexres !== null) {
                            server.text = (regexres[1]?regexres[1]:'') + regexres[4]
                            settings.httpauthusername = regexres[2]
                            settings.httpauthpassword = regexres[3]
                        }

                        settings.servername = server.text
                        settings.username = username.text
                        settings.password = password.text

                        startLogin();
                    }
                    enabled: !network.loading
                }
                Button {
                    id: clearButton
                    text: qsTr("Clear")
                    width: parent.width
                    onClicked: {
                        server.text = ''
                        username.text = ''
                        password.text = ''

                        settings.httpauthusername = ''
                        settings.httpauthpassword = ''
                        settings.servername = server.text
                        settings.username = username.text
                        settings.password = password.text
                    }
                    enabled: !network.loading
                }
            }
        }
    }
    BusyIndicator {
        id: busyindicator1
        visible: network.loading
        running: visible
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        size: BusyIndicatorSize.Large
    }

    function enableLoginBox(focus) {
        if(focus) {
            password.forceActiveFocus();
        }
    }

    function startLogin() {
        var ttrss = rootWindow.getTTRSS();
        ttrss.clearState();
        ttrss.setLoginDetails(username.text, password.text, server.text);
        // BUGFIX since somehow the silica QML Image can not display images coming from a secure line
        if (server.text.substring(0, 5) === "https")
            ttrss.setProxy("http://proxy.cnlpete.de/proxy.php?url=")
        if (settings.httpauthusername != '' && settings.httpauthpassword != '') {
            ttrss.setHttpAuthInfo(settings.httpauthusername, settings.httpauthpassword);
            console.log('doing http basic auth with username ' + settings.httpauthusername)
        }
        ttrss.login(loginSuccessfull);
    }

    function loginSuccessfull(retcode, text) {
        if(retcode) {
            //login failed....don't autlogin
            settings.autologin = false

            //Let the user know
//            loginErrorDialog.text = text;
//            loginErrorDialog.open();
        }
        else {
            //Login succeeded, auto login next Time
            settings.autologin = true
            rootWindow.getTTRSS().updateConfig(configSuccessfull);
        }
    }

    function configSuccessfull(retcode, text) {
        if(retcode) {
            //Let the user know
//            loginErrorDialog.text = text;
//            loginErrorDialog.open();
        }
        else {
            categories.update()
            //Now show the categories View
            if (settings.useAllFeedsOnStartup) {
                var ttrss = rootWindow.getTTRSS()
                pageStack.replace("Feeds.qml", {
                                        category: {
                                            categoryId: ttrss.constants['categories']['ALL'],
                                            title: constant.allFeeds,
                                            unreadcount: 0
                                        }
                                    })
            }
            else
                pageStack.replace(Qt.resolvedUrl('Categories.qml'))
        }
    }

    Component.onCompleted: {
        server.text = settings.servername
        username.text = settings.username
        password.text = settings.password

        if(settings.autologin && settings.useAutologin)
            startLogin();
    }
}
