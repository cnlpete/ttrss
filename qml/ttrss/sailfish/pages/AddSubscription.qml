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

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../models" 1.0

Dialog {
    id: root

    property int categoryId
    property int selectedId
    property alias src: feedAddress.text

    canAccept: feedAddress.text && allCategories.count > 0 && root.selectedId >= 0
    acceptDestinationAction: PageStackAction.Pop

    CategoryModel {
        id: allCategories

        onUpdateFinished: {
            // we need to use the timer as the repeater might not have filled the contextmenu of the combobox yet
            categoryChooser.startTimer()
        }
    }

    Component.onCompleted: {
        var oldShowAll = settings.showAll
        var ttrss = rootWindow.getTTRSS()
        ttrss.setShowAll(true)
        allCategories.update()
        ttrss.setShowAll(oldShowAll)
    }

    BusyIndicator {
        visible: network.loading
        running: visible
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
    }

    Column {
        width: parent.width

        DialogHeader {
            acceptText: qsTr("Add subscription")
        }
        TextField {
            id: feedAddress
            anchors {
                left: parent.left
                right: parent.right
            }
            focus: true
            label: qsTr("Feed address:")
            placeholderText: label
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhUrlCharactersOnly
            EnterKey.enabled: text || inputMethodComposing
            EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            EnterKey.onClicked: root.accept()
        }
        ComboBoxList {
            id: categoryChooser
            anchors {
                left: parent.left
                right: parent.right
            }
            label: qsTr("Category:")
            model: allCategories
            initialValue: root.categoryId
            withTimer: false

            onCurrentIndexChanged: {
                root.selectedId = allCategories.get(categoryChooser.currentIndex).categoryId
            }
        }
    }
}
