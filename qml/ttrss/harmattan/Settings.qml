/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2015  Hauke Schade
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

import QtQuick 1.1
import com.nokia.meego 1.0
import "../components" 1.0

Page {
    id: settingsPage

    orientationLock: Screen.Portrait

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }

    PageHeader {
        id: pageHeader
        text: qsTr("Settings")
        z: 20
    }

    Flickable {
        contentHeight: settingsColumn.height
        contentWidth: parent.width
        anchors {
            top: pageHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        Column {
            id: settingsColumn
            anchors {
                top: parent.top
                topMargin: MyTheme.paddingMedium
                left: parent.left
                leftMargin: MyTheme.paddingMedium
                right: parent.right
                rightMargin: MyTheme.paddingMedium
            }
            height: childrenRect.height
            spacing: MyTheme.paddingMedium

            // -- Startup --
            Label {
                width: parent.width
                horizontalAlignment: Text.AlignLeft
                color: MyTheme.highlightColor
                text: qsTr("Startup")
                font.pixelSize: MyTheme.fontSizeSmall
            }
            TextSwitch {
                text: qsTr('Automatically Login')
                checked: settings.useAutologin
                onCheckedChanged: settings.useAutologin = checked
            }
            TextSwitch {
                text: qsTr('Use All Feeds on Startup')
                checked: settings.useAllFeedsOnStartup
                onCheckedChanged: settings.useAllFeedsOnStartup = checked
            }
            Label {
                width: parent.width
                text: qsTr("Navigate to special page after login")
                font.pixelSize: MyTheme.fontSizeSmall
            }
            ListModel {
                id: possibleStartpages
                ListElement { value: 0; name: "" }
                ListElement { value: 1; name: "" }
                ListElement { value: 2; name: "" }
                ListElement { value: 3; name: "" }
                ListElement { value: 4; name: "" }
                Component.onCompleted: {
                    possibleStartpages.setProperty(0, "name", qsTr("Standard"))
                    possibleStartpages.setProperty(1, "name", qsTr("All Feeds"))
                    possibleStartpages.setProperty(2, "name", qsTr("Special"))
                    possibleStartpages.setProperty(3, "name", qsTr("Special/Fresh Articles"))
                    possibleStartpages.setProperty(4, "name", qsTr("Labels"))
                }
            }
            ComboBoxList {
                id: startPage
                initialValue: settings.startpage
                model: possibleStartpages
                onCurrentIndexChanged: settings.startpage = currentIndex
                title: qsTr("Navigate to special page after login")
            }

            Label {
                width: parent.width
                text: qsTr("Minimum Ssl Version")
                font.pixelSize: MyTheme.fontSizeMedium
            }
            Label {
                width: parent.width
                text: qsTr("Specify a minimum protocol version for your SSL connection. This might be necessary when your server does not allow connections with older (insecure) protocols. However, your server might not support the newest protocol.")
                font.pixelSize: MyTheme.fontSizeSmall
            }

            ListModel {
                id: possibleProtocols
                ListElement { value: 0; name: "" }
                ListElement { value: 1; name: "" }
                ListElement { value: 2; name: "" }
                ListElement { value: 3; name: "" }
                Component.onCompleted: {
                    possibleProtocols.setProperty(0, "name", qsTr("Any"))
                    possibleProtocols.setProperty(1, "name", qsTr("SslV2"))
                    possibleProtocols.setProperty(2, "name", qsTr("SslV3"))
                    possibleProtocols.setProperty(3, "name", qsTr("TlsV1"))
                }
            }

            ComboBoxList {
                id: minimumSSLVersionSetting
                initialValue: settings.minSSLVersion
                model: possibleProtocols
                onCurrentIndexChanged: settings.minSSLVersion = currentIndex
                title: qsTr("Minimum Ssl Version")
            }

            // -- Items --
            Label {
                width: parent.width
                horizontalAlignment: Text.AlignLeft
                color: MyTheme.highlightColor
                text: qsTr("Items")
                font.pixelSize: MyTheme.fontSizeSmall
            }
            SettingsButtonRow {
                text: qsTr("Order")
                checkedButtonIndex: settings.feeditemsOrder
                buttonsText: [qsTr("Newest First"), qsTr("Oldest First")]
                onButtonClicked: settings.feeditemsOrder = index
            }
            TextSwitch {
                text: qsTr('Automatically Mark Items as Read')
                checked: settings.autoMarkRead
                onCheckedChanged: settings.autoMarkRead = checked
            }
            TextSwitch {
                text: qsTr('Display Labels in Item List')
                checked: settings.displayLabels
                onCheckedChanged: settings.displayLabels = checked
            }

            // -- Icons --
            Label {
                width: parent.width
                horizontalAlignment: Text.AlignLeft
                color: MyTheme.highlightColor
                text: qsTr("Icons")
                font.pixelSize: MyTheme.fontSizeSmall
            }
            TextSwitch {
                text: qsTr('Show Icons')
                checked: settings.displayIcons
                onCheckedChanged: settings.displayIcons = checked
            }

            // -- Text --
            Label {
                width: parent.width
                horizontalAlignment: Text.AlignLeft
                color: MyTheme.highlightColor
                text: qsTr("Text")
                font.pixelSize: MyTheme.fontSizeSmall
            }
            SettingsButtonRow {
                text: qsTr("Theme")
                checkedButtonIndex: settings.whiteTheme ? 1 : 0
                buttonsText: [qsTr("Dark"), qsTr("White")]
                onButtonClicked: settings.whiteTheme = index === 1
            }
            SettingsSliderRow {
                text: qsTr('Font Size')
                minimumValue: MyTheme.fontSizeTiny
                maximumValue: MyTheme.fontSizeExtraLarge
                value: settings.webviewFontSize
                onValueChanged: settings.webviewFontSize = value
            }

            // -- Images --
            Label {
                width: parent.width
                horizontalAlignment: Text.AlignLeft
                color: MyTheme.highlightColor
                text: qsTr("Images")
                font.pixelSize: MyTheme.fontSizeSmall
            }
            TextSwitch {
                id: displayImagesSetting
                width: parent.width
                text: qsTr('Display images')
                checked: settings.displayImages
                onCheckedChanged: settings.displayImages = checked
            }
            TextSwitch {
                id: stripInvisibleImgSetting
                text: qsTr('Strip invisible images')
                checked: settings.stripInvisibleImg
                onCheckedChanged: settings.stripInvisibleImg = checked
                enabled: displayImagesSetting.checked
            }
        }
    }
}
