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
import "../models" 1.0

Sheet {
    id: root

    property int categoryId
    property int selectedId
    property alias src: feedAddress.text

    acceptButtonText: selectedId >= 0 ? qsTr("Add") : ""
    rejectButtonText: qsTr("Cancel")

    CategoryModel {
        id: allCategories
        property bool finished: false

        onUpdateFinished: {
            // we need to use the timer as the repeater might not have filled the contextmenu of the combobox yet
            finished = true
            categoryChooser.startTimer()
        }
    }

    onCategoryIdChanged: {
        if (allCategories.finished)
            categoryChooser.startTimer()
    }

    Component.onCompleted: {
        var oldShowAll = settings.showAll
        var ttrss = rootWindow.getTTRSS()
        ttrss.setShowAll(true)
        allCategories.update()
        ttrss.setShowAll(oldShowAll)
    }

    content: Flickable {
        anchors.fill: parent
        anchors.leftMargin: MyTheme.paddingMedium
        anchors.topMargin: MyTheme.paddingMedium
        flickableDirection: Flickable.VerticalFlick
        Column {
            id: col2
            anchors.top: parent.top
            spacing: 10
            width: parent.width
            Label {
                id: serverLabel
                text: qsTr("Feed address:")
                width: parent.width
                font.pixelSize: MyTheme.fontSizeMedium
            }
            TextField {
                id: feedAddress
                text: ""
                width: parent.width
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhUrlCharactersOnly
            }
            Label {
                id: categoryLabel
                text: qsTr("Category:")
                width: parent.width
                font.pixelSize: MyTheme.fontSizeMedium
            }
            ComboBoxList {
                id: categoryChooser
                anchors {
                    left: parent.left
                    right: parent.right
                }
                model: allCategories
                initialValue: root.categoryId
                withTimer: false

                onCurrentIndexChanged: {
                    root.selectedId = allCategories.get(categoryChooser.currentIndex).categoryId
                }
            }
        }
    }
}
