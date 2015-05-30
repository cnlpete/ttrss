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
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem

Page {
    id: settingsPage
    title: qsTr("Settings")

    Flickable {
        id: flickable
        contentHeight: settingsColumn.height
        anchors.fill: parent

        /* TODO
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AboutPage.qml"));
                }
            }
        }
        */

        Column {
            id: settingsColumn
            anchors {
                left: parent.left
                right: parent.right
            }

            // -- Startup --
            Label {
                font.bold: true
                text: qsTr("Startup")
            }

            ListItem.Standard {
                text: qsTr('Automatically Login')
                control: Switch {
                    id: autoLoginSetting
                    checked: settings.useAutologin
                }
            }

            ListItem.Standard {
                text: qsTr('Show "All Feeds"')
                control: Switch {
                    id: useAllFeedsOnStartupSetting
                    //description: qsTr('You need to restart the App for this to take effect.')
                    checked: settings.useAllFeedsOnStartup
                }
            }

            ListItem.ItemSelector {
                id: minimumSSLVersionSetting
                text: qsTr("Minimum Ssl Version")
                selectedIndex: settings.minSSLVersion
                //description: qsTr('Specify a minimum protocol version for your SSL connection. This might be necessary when your server does not allow connections with older (insecure) protocols. However, your server might not support the newest protocol.')

                model: [
                    qsTr("Any"),
                    qsTr("SslV2"),
                    qsTr("SslV3"),
                    qsTr("TlsV1.0"),
                    qsTr("TlsV1.1"),
                    qsTr("TlsV1.2")
                ]
            }

            ListItem.Divider {}

            // -- Feeds --
            Label {
                font.bold: true
                text: qsTr("Feeds")
            }

            ListItem.Standard {
                text: qsTr("Show Icons")
                control: Switch {
                    id: showIconsSetting
                    checked: settings.displayIcons
                }
            }

            ListItem.Standard {
                enabled: showIconsSetting.checked
                text: qsTr("White Background on Icons")
                control: Switch {
                    id: showWhiteBackgroundSetting
                    checked: settings.whiteBackgroundOnIcons
                }
            }

            ListItem.Divider {}

            // -- Item List --
            Label {
                font.bold: true
                text: qsTr("Item List")
            }

            ListItem.ItemSelector {
                id: orderSetting
                text: qsTr("Order")
                selectedIndex: settings.feeditemsOrder

                model: [
                    qsTr("Newest First"),
                    qsTr("Oldest First")
                ]
            }

            ListItem.Divider {}

            // -- Items --
            Label {
                font.bold: true
                text: qsTr("Items")
            }

            ListItem.Standard {
                text: qsTr("Automatically Mark as Read")
                control: Switch {
                    id: autoMarkReadSetting
                    checked: settings.autoMarkRead
                }
            }

            ListItem.Standard {
                text: qsTr("Show Images")
                control: Switch {
                    id: displayImagesSetting
                    checked: settings.displayImages
                }
            }

            ListItem.Standard {
                text: qsTr("Strip invisible Images")
                enabled: displayImagesSetting.checked
                control: Switch {
                    id: stripInvisibleImgSetting
                    //description: qsTr("height or width < 2")
                    checked: settings.stripInvisibleImg
                }
            }

            ListItem.ItemSelector {
                id: fontSizeSetting
                text: qsTr('Font Size')
                selectedIndex: settings.webviewFontSize
                model: [
                    qsTr("Tiny"),
                    qsTr("Small"),
                    qsTr("Medium"),
                    qsTr("Large"),
                    qsTr("Huge")
                ]
            }
        }
    }

    Scrollbar {
        flickableItem: flickable
    }

    onActiveChanged: if (!active) {
        // Startup
        settings.useAutologin = autoLoginSetting.checked
        settings.useAllFeedsOnStartup = useAllFeedsOnStartupSetting.checked
        settings.minSSLVersion = minimumSSLVersionSetting.selectedIndex

        // Feeds
        settings.displayIcons = showIconsSetting.checked
        settings.whiteBackgroundOnIcons = showWhiteBackgroundSetting.checked

        // Item List
        settings.feeditemsOrder = orderSetting.selectedIndex

        // Items
        settings.autoMarkRead = autoMarkReadSetting.checked
        settings.displayImages = displayImagesSetting.checked
        settings.stripInvisibleImg = stripInvisibleImgSetting.checked
        settings.webviewFontSize = fontSizeSetting.selectedIndex
    }
}
