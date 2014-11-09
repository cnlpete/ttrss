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
import "../../models" 1.0

Dialog {
    id: root

    property int categoryId
    property int selectedId
    property alias src: feedAddress.text

    canAccept: feedAddress.text && allCategories.count > 0 && root.selectedId >= 0
    acceptDestinationAction: PageStackAction.Pop

    ListModel {
        id: allCategories

        function load(categories) {
            if (!categories || !categories.length) {
                return
            }

            var ttrss = rootWindow.getTTRSS()

            for(var i = 0; i < categories.length; ++i) {
                var title = ttrss.html_entity_decode(categories[i].title, 'ENT_QUOTES')

                if (categories[i].id === ttrss.constants['categories']['UNCATEGORIZED']) {
                    title = constant.uncategorizedCategory
                }

                allCategories.append({
                                         name:  title,
                                         value: parseInt(categories[i].id),
                            });
            }
            categoryChooser.startTimer()
        }
    }

    Component.onCompleted: {
        categoryModel.getAllCategories(function(successful, errorMessage,
                                                categories) {
            if (successful) {
                allCategories.load(categories)
                categoryChooser.startTimer()
            }
            // TODO make use of errorMessage
        })
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
            initialId: root.categoryId

            onCurrentIndexChanged: {
                root.selectedId = model.get(categoryChooser.currentIndex).id
            }
        }
    }
}
