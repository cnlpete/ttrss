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

import QtQuick 1.1
import com.nokia.meego 1.0
import "../components" 1.0

Page {
    orientationLock: Screen.Portrait
    tools: commonTools

    Column {
        id: contentcontainer
        width: 350
        spacing: MyTheme.paddingMedium

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 50
        }

        Image {
            width: 256
            height: 256
            anchors.horizontalCenter: parent.horizontalCenter
            source: "../resources/ttrss256.png"

            anchors.bottomMargin: 50
        }

        Column {
            width: parent.width
            Label {
                id: serverLabel
                text: qsTr("Server:")
                width: parent.width
            }
            TextField {
                id: server
                text: ""
                width: parent.width
                enabled: !network.loading
            }
        }
        Column {
            width: parent.width
            Label {
                id: usernameLabel
                text: qsTr("Username:")
                width: parent.width
            }
            TextField {
                id: username
                text: ""
                width: parent.width
                enabled: !network.loading
            }
        }
        Column {
            width: parent.width
            Label {
                id: passwordLabel
                text: qsTr("Password:")
                width: parent.width
            }
            TextField {
                id: password
                echoMode: TextInput.Password
                width: parent.width
                enabled: !network.loading
            }
        }
        TextSwitch {
            text: qsTr('Ignore SSL Errors')
            visible: server.text.substring(0, 5) === "https"
            checked: settings.ignoreSSLErrors
            onCheckedChanged: settings.ignoreSSLErrors = checked
            enabled: !network.loading
        }
    }
    BusyIndicator {
        id: busyindicator1
        visible: network.loading
        running: network.loading
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        platformStyle: BusyIndicatorStyle { size: 'large' }
    }

    ToolBarLayout {
        id: commonTools
        visible: true
        ToolButton {
            id: clearButton
            text: qsTr("Clear")
            anchors.right: loginButton.left
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
        ToolButton {
            id: loginButton
            text: qsTr("Login")
            anchors.right: menuButton.left
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
        ToolIcon {
            id: menuButton
            platformIconId: "toolbar-view-menu"
            anchors.right: (parent === undefined) ? undefined : parent.right
            onClicked: (myMenu.status === DialogStatus.Closed) ? myMenu.open() : myMenu.close()
            enabled: !network.loading
        }
    }

    Menu {
        id: myMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem {
                text: qsTr("No Account Yet?")
                onClicked: {
                    rootWindow.openFile(Qt.openUrlExternally(constant.registerUrl));
                }
            }
            SettingsItem {}
            AboutItem {}
        }
    }

    function enableLoginBox(focus) {
        if(focus) {
            password.forceActiveFocus();
        }
    }

    function startLogin() {
        // close the menu
        if (myMenu.status !== DialogStatus.Closed)
            myMenu.close()

        var ttrss = rootWindow.getTTRSS();
        ttrss.clearState();
        ttrss.setLoginDetails(username.text, password.text, server.text);
        if (settings.httpauthusername != '' && settings.httpauthpassword != '') {
            ttrss.setHttpAuthInfo(settings.httpauthusername, settings.httpauthpassword);
            infoBanner.text = 'doing login with httpauth (' + settings.httpauthusername + ')'
            infoBanner.show()
            console.log('doing http basic auth with username ' + settings.httpauthusername)
        }
        ttrss.login(loginSuccessfull);
    }

    function loginSuccessfull(retcode, text) {
        if(retcode) {
            //login failed....don't autlogin
            settings.autologin = false

            //Let the user know
            loginErrorDialog.text = text;
            loginErrorDialog.open();
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
            loginErrorDialog.text = text;
            loginErrorDialog.open();
        }
        else {
            categories.update()
            //Now show the categories View
            if (settings.useAllFeedsOnStartup) {
                var ttrss = rootWindow.getTTRSS()
                rootWindow.openFile("Feeds.qml", {
                                        category: {
                                            categoryId: ttrss.constants['categories']['ALL'],
                                            title: constant.allFeeds,
                                            unreadcount: 0
                                        }
                                    })
            }
            else
                rootWindow.openFile('Categories.qml')
        }
    }

    //Dialog for login errors
    ErrorDialog {
        id: loginErrorDialog
        text: "pageTitle"
    }

    Component.onCompleted: {
        server.text = settings.servername
        username.text = settings.username
        password.text = settings.password

        if(settings.autologin && settings.useAutologin)
            startLogin();
    }
}
