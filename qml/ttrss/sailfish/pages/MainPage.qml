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

Page {
    id: dialog

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
            spacing: Theme.paddingLarge

            PageHeader {
                width: dialog.width
                title: qsTr("Tiny Tiny RSS")
            }

            Image {
                width: 256
                height: 256
                anchors.horizontalCenter: parent.horizontalCenter
                source: "qrc:///images/ttrss256.png"
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Change Login Details")
                width: Math.floor(parent.width / 2)
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ApiSettings.qml"));
                }
                enabled: !network.loading
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.pixelSize: Theme.fontSizeMedium
                text: qsTr("%1 @ %2").arg(settings.username).arg(settings.servername)
                visible: settings.username.length > 0 && settings.servername.length > 0
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.pixelSize: Theme.fontSizeSmall
                text: qsTr("with httpauth (%1)").arg(settings.httpauthusername)
                visible: settings.httpauthusername.length > 0
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Login")
                width: Math.floor(parent.width / 2)
                onClicked: startLogin()
                enabled: !network.loading &&
                         settings.username.length > 0 &&
                         settings.password.length > 0 &&
                         settings.servername.length > 0
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

    function startLogin() {
        var ttrss = rootWindow.getTTRSS()
        ttrss.initState(settings.showAll)
        ttrss.setLoginDetails(settings.username, settings.password, settings.servername)

        // BUGFIX somehow the silica QML Image can not display images
        // coming from a secure line
        if (settings.ignoreSSLErrors && settings.servername.substring(0, 5) === "https") {
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

            // translate the error message
            if (errorMessage == 'API_DISABLED' || errorMessage == 'Error: API_DISABLED') {
                errorMessage = qsTr('The API is disabled. You have to enable it in the webinterface.')
            }
            else if (errorMessage == 'LOGIN_ERROR' || errorMessage == 'Error: LOGIN_ERROR') {
                errorMessage = qsTr('The supplied login credentials did not work.')
            }

            // Let the user know
            notification.show(errorMessage)

            return;
        }

        // Login succeeded, auto login next Time
        settings.autologin = true
        var ttrss = rootWindow.getTTRSS()

        // get the category preference
        ttrss.getPreference(ttrss.constants['prefKeys']['categories'], catPrefDone)
    }

    function catPrefDone(successful, errorMessage) {
        if(!successful) {
            // Let the user know
            notification.show(errorMessage)
            return;
        }

        // get the config
        rootWindow.getTTRSS().getConfig(configDone)
    }

    function buildPages(index) {
        var ttrss = rootWindow.getTTRSS()
        var pages = []

        // add root categories page if enabled
        var hasCategoriesEnabled = ttrss.getPref(ttrss.constants['prefKeys']['categories'])
        if (hasCategoriesEnabled === true || hasCategoriesEnabled === undefined) {
            pages.push(Qt.resolvedUrl("Categories.qml"))
        }

        switch (index) {
        default:
        case 0:
            // categories is already added
            break
        case 1:
            // all feeds
            pages.push({page: Qt.resolvedUrl("Feeds.qml"), properties: categoryModel.getAllFeedsCategory()})
            break
        case 2:
        case 3:
            // Special
            pages.push({page: Qt.resolvedUrl("Feeds.qml"), properties: categoryModel.getSpecialCategory()})

            if (index == 3) {
                var freshparams = {
                    feed: {
                        feedId:     ttrss.constants['feeds']['fresh'],
                        categoryId: ttrss.constants['categories']['SPECIAL'],
                        title:      constant.freshArticles,
                        unreadcount: 0,
                        isCat:       false,
                        icon:        settings.displayIcons ? ttrss.getIconUrl(ttrss.constants['feeds']['fresh']) : '',
                        lastUpdated: ''
                    }
                }
                pages.push({page: Qt.resolvedUrl("FeedItems.qml"), properties: freshparams })
            }
            break
        case 4:
            // Labels
            pages.push({page: Qt.resolvedUrl("Feeds.qml"), properties: categoryModel.getLabelsCategory()})
            break
        }

        return pages.length === 0 ? buildPages(1) : pages;
    }

    function configDone(successful, errorMessage) {
        if(!successful) {
            // Let the user know
            notification.show(errorMessage)
            return;
        }

        categoryModel.update()
        // Now show the categories View

        var ttrss = rootWindow.getTTRSS()

        var pages = buildPages(settings.startpage)
        pageStack.replace(pages)
    }

    Component.onCompleted: {
        if(settings.autologin && settings.useAutologin && doAutoLogin) {
            startLogin();
        }
    }
}
