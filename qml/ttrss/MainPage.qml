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
    property bool loading: false

    orientationLock: Screen.Portrait
    tools: commonTools

    Column {
        id: contentcontainer
        width: 350

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 50
        }

        Image {
            width: 256
            height: 256
            anchors.horizontalCenter: parent.horizontalCenter
            source: "resources/ttrss256.png"

            anchors.bottomMargin: 50
        }

        Label {
            id: serverLabel
            text: qsTr("Server:")
            width: parent.width
            font.pixelSize: constant.fontSizeMedium
        }
        TextField {
            id: server
            text: ""
            width: parent.width
            enabled: !loading
        }
        Label {
            id: usernameLabel
            text: qsTr("Username:")
            width: parent.width
            font.pixelSize: constant.fontSizeMedium
        }
        TextField {
            id: username
            text: ""
            width: parent.width
            enabled: !loading
        }
        Label {
            id: passwordLabel
            text: qsTr("Password:")
            width: parent.width
            font.pixelSize: constant.fontSizeMedium
        }
        TextField {
            id: password
            echoMode: TextInput.Password
            width: parent.width
            enabled: !loading
        }
    }
    BusyIndicator {
        id: busyindicator1
        visible: loading
        running: loading
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
            enabled: !loading
        }
        ToolIcon {
            id: menuButton
            platformIconId: "toolbar-view-menu"
            anchors.right: (parent === undefined) ? undefined : parent.right
            onClicked: (myMenu.status === DialogStatus.Closed) ? myMenu.open() : myMenu.close()
            enabled: !loading
        }
    }

    Menu {
        id: myMenu
        visualParent: pageStack
        MenuLayout {
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

        //Start the loading anim
        loading = true;

        var ttrss = rootWindow.getTTRSS();
        ttrss.clearState();
        ttrss.setLoginDetails(username.text, password.text, server.text);
        if (settings.httpauthusername != '' && settings.httpauthpassword != '') {
            ttrss.setHttpAuthInfo(settings.httpauthusername, settings.httpauthpassword);
            console.log('doing http basic auth with user ' + settings.httpauthusername)
        }
        ttrss.login(loginSuccessfull);
    }

    function loginSuccessfull(retcode, text) {
        if(retcode) {
            //login failed....don't autlogin
            settings.autologin = false

            //stop the loading anim
            loading = false;

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
        //stop the loading anim
        loading = false;

        if(retcode) {
            //Let the user know
            loginErrorDialog.text = text;
            loginErrorDialog.open();
        }
        else {
            //Now show the categories View
            rootWindow.openFile('Categories.qml');
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

        if(settings.autologin)
            startLogin();
    }
}
