//Copyright Hauke Schade, 2012-2014
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
import "../items"

Dialog {
    id: settingsPage

    SilicaFlickable {
        anchors.fill: parent

        //contentWidth: settingsColumn.width
        contentHeight: settingsColumn.height
        Column {
            id: settingsColumn
            anchors {
                fill: parent
                topMargin: Theme.paddingMedium
                leftMargin: Theme.paddingMedium
                rightMargin: Theme.paddingMedium
            }
            spacing: Theme.paddingMedium

            DialogHeader {
                title: qsTr("Settings")
            }

            ListModel {
                id: orderItems
                ListElement { name: ""; value: 0 }
                ListElement { name: ""; value: 1 }
                Component.onCompleted: {
                    orderItems.get(0).name = qsTr("Newest First")
                    orderItems.get(1).name = qsTr("Oldest First")
                }
            }
            ComboBoxList {
                id: orderSetting
                label: qsTr("Order")
                model: orderItems
                initialValue: settings.feeditemsOrder
            }


            TextSwitch {
                id: autoMarkReadSetting
                text: qsTr('Automatically Mark Items as Read')
                checked: settings.autoMarkRead
            }

            TextSwitch {
                id: showIconsSetting
                text: qsTr('Show Icons')
                checked: settings.displayIcons
            }
            TextSwitch {
                id: showWhiteBackgroundSetting
                visible: showIconsSetting.checked
                text: qsTr('Show a White Background on Icons')
                checked: settings.whiteBackgroundOnIcons
            }

            TextSwitch {
                id: useAllFeedsOnStartupSetting
                text: qsTr('Use All Feeds on Startup')
                description: qsTr('You need to restart the App for this to take effect.')
                checked: settings.useAllFeedsOnStartup
            }

            TextSwitch {
                id: autoLoginSetting
                text: qsTr('Automatically Login')
                checked: settings.useAutologin
            }

            Slider {
                id: fontSizeSetting
                anchors { left: parent.left; right: parent.right }
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
    }

    onAccepted: {
        settings.feeditemsOrder = orderSetting.currentIndex
        settings.autoMarkRead = autoMarkReadSetting.checked
        settings.displayIcons = showIconsSetting.checked
        settings.whiteBackgroundOnIcons = showWhiteBackgroundSetting.checked
        settings.useAllFeedsOnStartup = useAllFeedsOnStartupSetting.checked
        settings.useAutologin = autoLoginSetting.checked
        settings.webviewFontSize = fontSizeSetting.value
    }
}
