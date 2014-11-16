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
    id: settingsPage

    SilicaFlickable {
        contentHeight: settingsColumn.height
        contentWidth: parent.width
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AboutPage.qml"));
                }
            }
        }

        Column {
            id: settingsColumn
            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingMedium
            }
            spacing: Theme.paddingMedium

            DialogHeader {
                width: dialog.width
                title: qsTr("Settings")
                acceptText: qsTr("Save")
                cancelText: qsTr("Cancel")
            }

            // -- Startup --
            SectionHeader {
                text: qsTr("Startup")
            }

            TextSwitch {
                id: autoLoginSetting
                text: qsTr('Automatically Login')
                checked: settings.useAutologin
            }

            TextSwitch {
                id: useAllFeedsOnStartupSetting
                text: qsTr('Show "All Feeds"')
                description: qsTr('You need to restart the App for this to take effect.')
                checked: settings.useAllFeedsOnStartup
            }

            ComboBox {
                id: minimumSSLVersionSetting
                label: qsTr("Minimum Ssl Version")
                currentIndex: settings.minSSLVersion
                description: qsTr('Specify a minimum protocol version for your SSL connection. This might be necessary when your server does not allow connections with older (insecure) protocols.')

                menu: ContextMenu {
                    MenuItem { text: qsTr("Any") }
                    MenuItem { text: qsTr("SslV2") }
                    MenuItem { text: qsTr("SslV3") }
                    MenuItem { text: qsTr("TlsV1.0") }
                    MenuItem { text: qsTr("TlsV1.1") }
                    MenuItem { text: qsTr("TlsV1.2") }
                }
            }

            // -- Feeds --
            SectionHeader {
                text: qsTr("Feeds")
            }

            TextSwitch {
                id: showIconsSetting
                text: qsTr("Show Icons")
                checked: settings.displayIcons
            }

            TextSwitch {
                id: showWhiteBackgroundSetting
                enabled: showIconsSetting.checked
                text: qsTr("White Background on Icons")
                checked: settings.whiteBackgroundOnIcons
            }

            // -- Item List --
            SectionHeader {
                text: qsTr("Item List")
            }

            ComboBox {
                id: orderSetting
                label: qsTr("Order")
                currentIndex: settings.feeditemsOrder

                menu: ContextMenu {
                    MenuItem { text: qsTr("Newest First") }
                    MenuItem { text: qsTr("Oldest First") }
                }
            }

            Slider {
                id: lengthOfTitleSetting
                width: parent.width
                label: qsTr("Max. Length of Title (in Lines)")
                minimumValue: 0
                maximumValue: 5
                stepSize: 1
                value: settings.lengthOfTitle
                valueText: value == 0 ? qsTr("No Limit") : value
            }

            TextSwitch {
                id: showExcerptSetting
                text: qsTr("Show Excerpt")
                checked: settings.showExcerpt
            }

            Slider {
                id: lengthOfExcerptSetting
                width: parent.width
                label: qsTr("Max. Length of Excerpt (in Lines)")
                minimumValue: 0
                maximumValue: 10
                stepSize: 1
                value: settings.lengthOfExcerpt
                valueText: value == 0 ? qsTr("No Limit") : value
                enabled: showExcerptSetting.checked
            }

            TextSwitch {
                id: displayLabelsSetting
                text: qsTr("Show Labels")
                checked: settings.displayLabels
            }

            TextSwitch {
                id: displayNoteSetting
                text: qsTr("Show Note")
                checked: settings.showNote
            }

            Slider {
                id: lengthOfNoteSetting
                width: parent.width
                label: qsTr("Max. Length of Note (in Lines)")
                minimumValue: 0
                maximumValue: 10
                stepSize: 1
                value: settings.lengthOfNote
                valueText: value == 0 ? qsTr("No Limit") : value
                enabled: displayNoteSetting.checked
            }

            // -- Items --
            SectionHeader {
                text: qsTr("Items")
            }

            TextSwitch {
                id: autoMarkReadSetting
                text: qsTr("Automatically Mark as Read")
                checked: settings.autoMarkRead
            }

            TextSwitch {
                id: displayImagesSetting
                width: parent.width
                text: qsTr("Show Images")
                checked: settings.displayImages
            }

            TextSwitch {
                id: stripInvisibleImgSetting
                text: qsTr("Strip invisible Images")
                description: qsTr("height or width < 2")
                checked: settings.stripInvisibleImg
                enabled: displayImagesSetting.checked
            }

            Slider {
                id: fontSizeSetting
                width: parent.width
                label: qsTr('Font Size')
                minimumValue: Theme.fontSizeTiny
                maximumValue: Theme.fontSizeExtraLarge
                stepSize: 1
                value: settings.webviewFontSize
                valueText: {
                    switch (value) {
                    case parseInt(Theme.fontSizeTiny):
                        qsTr("Tiny")
                        break
                    case parseInt(Theme.fontSizeSmall):
                        qsTr("Small")
                        break
                    case parseInt(Theme.fontSizeMedium):
                        qsTr("Medium")
                        break
                    case parseInt(Theme.fontSizeLarge):
                        qsTr("Large")
                        break
                    case parseInt(Theme.fontSizeExtraLarge):
                        qsTr("Huge")
                        break
                    default:
                        value
                    }
                }
            }

        }
        VerticalScrollDecorator {}
    }

    onAccepted: {
        // Startup
        settings.useAutologin = autoLoginSetting.checked
        settings.useAllFeedsOnStartup = useAllFeedsOnStartupSetting.checked
        settings.minSSLVersion = minimumSSLVersionSetting.currentIndex

        // Feeds
        settings.displayIcons = showIconsSetting.checked
        settings.whiteBackgroundOnIcons = showWhiteBackgroundSetting.checked

        // Item List
        settings.feeditemsOrder = orderSetting.currentIndex
        settings.lengthOfTitle = lengthOfTitleSetting.value
        settings.showExcerpt = showExcerptSetting.checked
        settings.lengthOfExcerpt = lengthOfExcerptSetting.value
        settings.displayLabels = displayLabelsSetting.checked
        settings.showNote = displayNoteSetting.checked
        settings.lengthOfNote = lengthOfNoteSetting.value

        // Items
        settings.autoMarkRead = autoMarkReadSetting.checked
        settings.displayImages = displayImagesSetting.checked
        settings.stripInvisibleImg = stripInvisibleImgSetting.checked
        settings.webviewFontSize = fontSizeSetting.value
    }
}
