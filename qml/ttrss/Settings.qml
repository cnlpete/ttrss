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

import QtQuick 1.1
import com.nokia.meego 1.0

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
            topMargin: constant.paddingMedium
            left: parent.left
            right: parent.right
        }
        height: childrenRect.height
        spacing: constant.paddingMedium

        SettingsButtonRow {
            text: qsTr("Theme")
            checkedButtonIndex: settings.whiteTheme ? 1 : 0
            buttonsText: [qsTr("Dark"), qsTr("White")]
            onButtonClicked: settings.whiteTheme = index === 1
        }

        SettingsButtonRow {
            text: qsTr("Order")
            checkedButtonIndex: settings.feeditemsOrder
            buttonsText: [qsTr("Newest First"), qsTr("Oldest First")]
            onButtonClicked: settings.feeditemsOrder = index
        }
    }
}
