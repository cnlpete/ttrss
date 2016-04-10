//Copyright Alberto Mardegan, 2015
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
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3
import Ubuntu.Content 1.3

ActionSelectionPopover {
    id: root

    property bool isImage: false
    property string url: ""

    grabDismissAreaEvents: true

    delegate: ListItem.Standard {
        text: action.text
        onTriggered: root.hide()
    }
    actions: ActionList {
        Action {
            text: qsTr("Open in Web Browser")
            onTriggered: Qt.openUrlExternally(root.url)
        }
        Action {
            text: qsTr("Save image")
            visible: isImage
            onTriggered: pageStack.push(Qt.resolvedUrl("FileSaver.qml"), {
                "url": url,
                "contentType": ContentType.Pictures,
            })
        }
    }
}
