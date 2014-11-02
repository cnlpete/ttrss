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

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../items"

Dialog {
    id: dialog
    canAccept: !network.loading && server.text.length > 0

    property bool doAutoLogin: true

    SilicaFlickable {
        contentHeight: contentcontainer.height
        contentWidth: parent.width
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AboutPage.qml"));
                }
            }
            SettingsItem {}
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
                title: qsTr("Tiny Tiny RSS")
                acceptText: qsTr("Login")
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
                enabled: !network.loading
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
                enabled: !network.loading
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
                enabled: !network.loading
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: {
                    focus = false
                    prepareLogin()
                }
            }
            TextSwitch {
                id: ignoreSSLErrors
                text: qsTr('Ignore SSL Errors')
                visible: server.text.substring(0, 5) === "https"
                checked: false
            }
            Row {
                width: parent.width
                Button {
                    text: qsTr("Restore")
                    width: Math.floor(parent.width / 2) - Theme.paddingMedium
                    onClicked: {
                        server.text = settings.servername
                        username.text = settings.username
                        password.text = settings.password
                        ignoreSSLErrors.checked = settings.ignoreSSLErrors
                    }
                    enabled: !network.loading && (
                                 server.text !== settings.servername
                                 || username.text !== settings.username
                                 || password.text !== settings.password
                                 || ignoreSSLErrors.checked !== settings.ignoreSSLErrors
                             )
                }
                Button {
                    text: qsTr("Clear")
                    width: Math.floor(parent.width / 2) - Theme.paddingMedium
                    onClicked: {
                        server.text = ''
                        username.text = ''
                        password.text = ''
                        ignoreSSLErrors.checked = false
                    }
                    enabled: !network.loading && (
                                 server.text.length > 0
                                 || username.text.length > 0
                                 || password.text.length > 0
                                 || ignoreSSLErrors.checked)
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

    function prepareLogin() {
        // check the servername for httpauth data and set/extract those
        var httpauthregex = /(https?:\/\/)?(\w+):(\w+)@(\w.+)/
        var servername = server.text
        var regexres = servername.match(httpauthregex)

        if (regexres !== null) {
            server.text = (regexres[1] ? regexres[1] : '') + regexres[4]
            settings.httpauthusername = regexres[2]
            settings.httpauthpassword = regexres[3]
        } else {
            settings.httpauthusername = ''
            settings.httpauthpassword = ''
        }

        settings.servername = server.text
        settings.username = username.text
        settings.password = password.text
        settings.ignoreSSLErrors = ignoreSSLErrors.checked

        startLogin();
    }

    function startLogin() {
        var ttrss = rootWindow.getTTRSS()
        ttrss.initState()
        ttrss.setLoginDetails(username.text, password.text, server.text)

        // BUGFIX somehow the silica QML Image can not display images
        // coming from a secure line
        if (settings.ignoreSSLErrors && server.text.substring(0, 5) === "https") {
            ttrss.setImageProxy("http://proxy.cnlpete.de/proxy.php?url=")
        }

        if (settings.httpauthusername != '' && settings.httpauthpassword != '') {
            ttrss.setHttpAuthInfo(settings.httpauthusername, settings.httpauthpassword)
            console.log('doing http basic auth with username ' + settings.httpauthusername)
        }
        ttrss.login(loginDone)
    }

    function loginDone(successful, errorMessage) {
        if(!successful) {
            // login failed....don't autlogin
            settings.autologin = false

            // Let the user know
            //loginErrorDialog.text = errorMessage;
            //loginErrorDialog.open();
            dialog.reject()
            return;
        }

        // Login succeeded, auto login next Time
        settings.autologin = true
        rootWindow.getTTRSS().getConfig(configDone);
    }

    function configDone(successful, errorMessage) {
        if(!successful) {
            // Let the user know
            //loginErrorDialog.text = errorMessage;
            //loginErrorDialog.open();
            return;
        }

        categoryModel.update()
        // Now show the categories View

        var pages = [Qt.resolvedUrl("Categories.qml")]
        if (settings.useAllFeedsOnStartup) {
            var ttrss = rootWindow.getTTRSS()
            var params = {
                category: {
                    categoryId: ttrss.constants['categories']['ALL'],
                    title: constant.allFeeds,
                    unreadcount: 0
                }
            }
            pages.push({page: Qt.resolvedUrl("Feeds.qml"), properties: params })
        }
        /*else if (settings.useSpecialFeedOnStartup) {
            var ttrss = rootWindow.getTTRSS()
            var params = {
                category: {
                    categoryId: ttrss.constants['categories']['SPECIAL'],
                    title: constant.specialCategory,
                    name: constant.specialCategory,
                    unreadcount: 0
                }
            }
            pages.push({page: Qt.resolvedUrl("Feeds.qml"), properties: params })
            params = {
                feed: {
                    feedId:     ttrss.constants['feeds']['fresh'],
                    categoryId: ttrss.constants['categories']['SPECIAL'],
                    title:      constant.freshArticles,
                    unreadcount: 0,
                    isCat:       false,
                    icon:        settings.displayIcons ? ttrss.getIconUrl(ttrss.constants['feeds']['fresh']) : ''
                }
            }
            pages.push({page: Qt.resolvedUrl("FeedItems.qml"), properties: params })
        }*/
        pageStack.replace(pages)
    }

    Component.onCompleted: {
        server.text = settings.servername
        username.text = settings.username
        password.text = settings.password
        ignoreSSLErrors.checked = settings.ignoreSSLErrors

        if(settings.autologin && settings.useAutologin && doAutoLogin) {
            startLogin();
        }
    }

    onAccepted: prepareLogin()
}
