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
    id: settingsPage

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: settingsColumn.width
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

            PageHeader {
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
                label: qsTr("Order")
                model: orderItems
                initialValue: settings.feeditemsOrder
                onCurrentIndexChanged: settings.feeditemsOrder = currentIndex
            }


            TextSwitch {
                text: qsTr('Automatically Mark Items as Read')
                checked: settings.autoMarkRead
                onCheckedChanged: settings.autoMarkRead = checked
            }

            TextSwitch {
                text: qsTr('Show Icons')
                checked: settings.displayIcons
                onCheckedChanged: settings.displayIcons = checked
            }
            TextSwitch {
                text: qsTr('Show a White Background on Icons')
                checked: settings.whiteBackgroundOnIcons
                onCheckedChanged: settings.whiteBackgroundOnIcons = checked
            }

            TextSwitch {
                text: qsTr('Use All Feeds on Startup')
                description: qsTr('You need to restart the App for this to take effect.')
                checked: settings.useAllFeedsOnStartup
                onCheckedChanged: settings.useAllFeedsOnStartup = checked
            }

            TextSwitch {
                text: qsTr('Automatically Login')
                checked: settings.useAutologin
                onCheckedChanged: settings.useAutologin = checked
            }

        Slider {
            anchors { left: parent.left; right: parent.right }
            label: qsTr('Font Size')
            minimumValue: Theme.fontSizeTiny
            maximumValue: Theme.fontSizeExtraLarge
            stepSize: 1
            value: settings.webviewFontSize
            onValueChanged: settings.webviewFontSize = value
            }
        }
    }
}
