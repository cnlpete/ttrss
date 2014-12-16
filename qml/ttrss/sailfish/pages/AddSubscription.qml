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

    property int initial
    property int selected: initial
    property alias src: feed.text

    canAccept: feed.text && allCategories.count > 0 && root.selected >= 0

    SilicaFlickable {
        contentHeight: content.height
        contentWidth: parent.width
        anchors.fill: parent

        Column {
            id: content
            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingMedium
            }
            spacing: Theme.paddingMedium

            DialogHeader {
                acceptText: qsTr("Add subscription")
            }

            TextField {
                id: feed
                label: qsTr("Feed address")
                placeholderText: label
                focus: true
                width: parent.width

                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhUrlCharactersOnly
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: root.accept()
            }

            ComboBox {
                id: categoryChooser
                label: qsTr("Category")

                menu: ContextMenu {
                    Repeater {
                        model: allCategories
                        MenuItem {
                            text: model.name
                        }
                    }
                }

                onCurrentIndexChanged: {
                    var index = categoryChooser.currentIndex
                    root.selected = allCategories.get(index).value
                }

                function setInitialIndex() {
                    timer.start()
                }

                Timer {
                    id: timer
                    interval: 200
                    onTriggered: {
                        for (var i = 0; i < allCategories.count; i++) {
                            if (allCategories.get(i).value === root.initial) {
                                categoryChooser.currentIndex = i
                                break
                            }
                        }
                    }
                }
            }
        }
    }

    BusyIndicator {
        visible: network.loading
        running: visible
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
    }

    CategoryModel {
        id: allCategories

        Component.onCompleted: {
            allCategories.getAllCategories()
            categoryChooser.setInitialIndex()
        }
    }
}
