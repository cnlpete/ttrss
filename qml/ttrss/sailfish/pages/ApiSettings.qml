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
import "../items"

Dialog {
    id: dialog
    canAccept: server.text.length > 0 &&
               username.text.length > 0 &&
               password.text.length > 0

    SilicaFlickable {
        contentHeight: contentcontainer.height
        contentWidth: parent.width
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("No Account Yet?")
                onClicked: {
                    Qt.openUrlExternally("http://tt-rss.org/redmine/projects/tt-rss/wiki");
                }
            }
        }

        Column {
            id: contentcontainer
            anchors {
                leftMargin: Theme.paddingLarge
                rightMargin: Theme.paddingLarge
            }
            spacing: Theme.paddingMedium

            DialogHeader {
                width: dialog.width
                dialog: dialog
                title: qsTr("Login Details")
                acceptText: qsTr("Save")
                cancelText: qsTr("Clear")
            }

            Image {
                width: 256
                height: 256
                anchors.horizontalCenter: parent.horizontalCenter
                source: "qrc:///images/ttrss256.png"
            }

            TextField {
                id: server
                text: ""
                placeholderText: qsTr("Server address")
                label: qsTr("Server address")
                width: parent.width
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhUrlCharactersOnly
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: username.focus = true
            }
            TextField {
                id: username
                text: ""
                placeholderText: qsTr("Username")
                label: qsTr("Username")
                width: parent.width
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: password.focus = true
            }
            TextField {
                id: password
                placeholderText: qsTr("Password")
                label: qsTr("Password")
                echoMode: TextInput.Password
                width: parent.width
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: focus = false
            }
            TextSwitch {
                id: ignoreSSLErrors
                text: qsTr('Ignore SSL Errors')
                visible: server.text.substring(0, 5) === "https" && (settings.ignoreSSLErrors || network.gotSSLError)
                checked: false
            }

            TextSwitch {
                id: httpAuth
                text: qsTr('Additional HTTP Auth?')
                checked: settings.httpauthusername.length > 0 || settings.httpauthpassword.length > 0
            }

            TextField {
                id: httpAuthUsername
                text: ""
                visible: httpAuth.checked
                placeholderText: qsTr("HTTP Auth Username")
                label: qsTr("HTTP Auth Username")
                width: parent.width
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: httpAuthPassword.focus = true
            }

            TextField {
                id: httpAuthPassword
                text: ""
                visible: httpAuth.checked
                echoMode: TextInput.Password
                placeholderText: qsTr("HTTP Auth Password")
                label: qsTr("HTTP Auth Password")
                width: parent.width
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: focus = false
            }

            Row {
                width: parent.width - 2 * Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingMedium
                Button {
                    text: qsTr("Restore")
                    width: Math.floor(parent.width / 2) - Theme.paddingMedium
                    onClicked: restoreSettings()

                    enabled: server.text !== settings.servername
                             || username.text !== settings.username
                             || password.text !== settings.password
                             || ignoreSSLErrors.checked !== settings.ignoreSSLErrors
                             || httpAuthUsername.text !== settings.httpauthusername
                             || httpAuthPassword.text !== settings.httpauthpassword
                }
                Button {
                    text: qsTr("Clear")
                    width: Math.floor(parent.width / 2) - Theme.paddingMedium
                    onClicked: {
                        server.text = ''
                        username.text = ''
                        password.text = ''
                        ignoreSSLErrors.checked = false
                        httpAuth.checked = false
                        httpAuthUsername.text = ''
                        httpAuthPassword.text = ''
                    }
                    enabled: server.text.length > 0
                             || username.text.length > 0
                             || password.text.length > 0
                             || ignoreSSLErrors.checked
                             || httpAuthUsername.text.length > 0
                             || httpAuthPassword.text.length > 0
                }
            }
        }
    }

    function saveSettings() {
//        // check the servername for httpauth data and set/extract those
//        var httpauthregex = /(https?:\/\/)?(\w+):(\w+)@(\w.+)/
//        var servername = server.text
//        var regexres = servername.match(httpauthregex)

//        if (regexres !== null) {
//            server.text = (regexres[1] ? regexres[1] : '') + regexres[4]
//            settings.httpauthusername = regexres[2]
//            settings.httpauthpassword = regexres[3]
//        } else {
//            settings.httpauthusername = ''
//            settings.httpauthpassword = ''
//        }

        settings.servername = server.text
        settings.username = username.text
        settings.password = password.text
        settings.ignoreSSLErrors = ignoreSSLErrors.checked
        if (httpAuth.checked) {
            settings.httpauthusername = httpAuthUsername.text
            settings.httpauthpassword = httpAuthPassword.text
        }
        else {
            settings.httpauthusername = ''
            settings.httpauthpassword = ''
        }

    }

    function restoreSettings() {
        server.text = settings.servername
        username.text = settings.username
        password.text = settings.password
        ignoreSSLErrors.checked = settings.ignoreSSLErrors
        httpAuthUsername.text = settings.httpauthusername
        httpAuthPassword.text = settings.httpauthpassword
        httpAuth.checked = settings.httpauthusername.length > 0 && settings.httpauthpassword.length > 0
    }

    Component.onCompleted: restoreSettings()

    onAccepted: saveSettings()
}
