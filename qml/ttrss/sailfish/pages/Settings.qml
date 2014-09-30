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
            Label {
                width: parent.width
                horizontalAlignment: Text.AlignRight
                color: Theme.highlightColor
                text: qsTr("Startup")
                font.pixelSize: Theme.fontSizeSmall;
            }

            TextSwitch {
                id: autoLoginSetting
                text: qsTr('Automatically Login')
                checked: settings.useAutologin
            }

            TextSwitch {
                id: useAllFeedsOnStartupSetting
                text: qsTr('Use All Feeds on Startup')
                description: qsTr('You need to restart the App for this to take effect.')
                checked: settings.useAllFeedsOnStartup
            }

            // -- Items --
            Label {
                width: parent.width
                horizontalAlignment: Text.AlignRight
                color: Theme.highlightColor
                text: qsTr("Items")
                font.pixelSize: Theme.fontSizeSmall;
            }

            ComboBoxList {
                id: orderSetting
                label: qsTr("Order")
                model: orderItems
                initialValue: settings.feeditemsOrder

                ListModel {
                    id: orderItems
                    ListElement { name: ""; value: 0 }
                    ListElement { name: ""; value: 1 }
                    Component.onCompleted: {
                        orderItems.get(0).name = qsTr("Newest First")
                        orderItems.get(1).name = qsTr("Oldest First")
                    }
                }
            }

            TextSwitch {
                id: autoMarkReadSetting
                text: qsTr('Automatically Mark Items as Read')
                checked: settings.autoMarkRead
            }

            // -- Icons --
            Label {
                width: parent.width
                horizontalAlignment: Text.AlignRight
                color: Theme.highlightColor
                text: qsTr("Icons")
                font.pixelSize: Theme.fontSizeSmall;
            }

            TextSwitch {
                id: showIconsSetting
                text: qsTr('Show Icons')
                checked: settings.displayIcons
            }

            TextSwitch {
                id: showWhiteBackgroundSetting
                enabled: showIconsSetting.checked
                text: qsTr('Show a White Background on Icons')
                checked: settings.whiteBackgroundOnIcons
            }

            // -- Text --
            Label {
                width: parent.width
                horizontalAlignment: Text.AlignRight
                color: Theme.highlightColor
                text: qsTr("Text")
                font.pixelSize: Theme.fontSizeSmall;
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

            // -- Images --
            Label {
                width: parent.width
                horizontalAlignment: Text.AlignRight
                color: Theme.highlightColor
                text: qsTr("Images")
                font.pixelSize: Theme.fontSizeSmall;
            }

            TextSwitch {
                id: displayImagesSetting
                width: parent.width
                text: qsTr('Display images')
                checked: settings.displayImages
            }

            TextSwitch {
                id: stripInvisibleImgSetting
                text: qsTr('Strip invisible images')
                checked: settings.stripInvisibleImg
                enabled: displayImagesSetting.checked
            }
        }
    }

    onAccepted: {
        settings.feeditemsOrder = orderSetting.currentIndex
        settings.autoMarkRead = autoMarkReadSetting.checked
        settings.displayIcons = showIconsSetting.checked
        settings.whiteBackgroundOnIcons = showWhiteBackgroundSetting.checked
        settings.useAllFeedsOnStartup = useAllFeedsOnStartupSetting.checked
        settings.useAutologin = autoLoginSetting.checked
        settings.displayImages = displayImagesSetting.checked
        settings.stripInvisibleImg = stripInvisibleImgSetting.checked
        settings.webviewFontSize = fontSizeSetting.value
    }
}
