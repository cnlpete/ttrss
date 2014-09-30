/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2014  Hauke Schade
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
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
    }

    Column {
        id: settingsColumn
        anchors {
            top: pageHeader.bottom
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
            horizontalAlignment: Text.AlignRight
            color: Theme.highlightColor
            text: qsTr("Startup")
            font.pixelSize: Theme.fontSizeSmall
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

        // -- Items --
        Label {
            width: parent.width
            horizontalAlignment: Text.AlignRight
            color: Theme.highlightColor
            text: qsTr("Items")
            font.pixelSize: Theme.fontSizeSmall
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

        // -- Icons --
        Label {
            width: parent.width
            horizontalAlignment: Text.AlignRight
            color: Theme.highlightColor
            text: qsTr("Icons")
            font.pixelSize: Theme.fontSizeSmall
        }
        TextSwitch {
            text: qsTr('Show Icons')
            checked: settings.displayIcons
            onCheckedChanged: settings.displayIcons = checked
        }

        // -- Text --
        Label {
            width: parent.width
            horizontalAlignment: Text.AlignRight
            color: Theme.highlightColor
            text: qsTr("Text")
            font.pixelSize: Theme.fontSizeSmall
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
            horizontalAlignment: Text.AlignRight
            color: Theme.highlightColor
            text: qsTr("Images")
            font.pixelSize: Theme.fontSizeSmall
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
