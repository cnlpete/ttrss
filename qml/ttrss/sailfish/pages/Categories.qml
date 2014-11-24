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
import "../items"

Page {
    id: categoriesPage
    property bool needsUpdate: false

    SilicaListView {
        id: listView
        anchors.fill: parent

        model: categoryModel

        PullDownMenu {
            SettingsItem {}
            MenuItem {
                text: qsTr("Logout")
                visible: pageStack.depth === 1
                onClicked: {
                    pageStack.replace(Qt.resolvedUrl("MainPage.qml"),
                                      { doAutoLogin: false })
                }
            }
            MenuItem {
                text: qsTr("Update")
                enabled: !network.loading
                onClicked: {
                    categoryModel.update()
                }
            }
            ToggleShowAllItem {
                onUpdateView: {
                    if (categoriesPage.visible) {
                        categoryModel.load(false)
                    } else {
                        categoriesPage.needsUpdate = true
                    }
                }
            }
        }

        delegate: CategoryDelegate {
            onClicked: {
                categoryModel.selectedIndex = index
                showCategory(categoryModel.getSelectedItem())
            }
        }

        header: PageHeader {
           title: qsTr("Tiny Tiny RSS Reader")
        }
        ViewPlaceholder {
            enabled: listView.count == 0
            text: network.loading ?
                      qsTr("Loading") :
                      (settings.showAll ?
                           qsTr("No categories to display") :
                           qsTr("No categories have unread items"))
        }
        BusyIndicator {
            visible: listView.count != 0 && network.loading
            running: visible
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
        }
        VerticalScrollDecorator { }
    }

    function showCategory(categoryModel) {
        if(categoryModel !== null) {
            pageStack.push(Qt.resolvedUrl("Feeds.qml"),
                           { category: categoryModel })
        }
    }

    onVisibleChanged: {
        if (visible) {
            cover = Qt.resolvedUrl("../cover/CategoriesCover.qml")
            if (categoriesPage.needsUpdate) {
                categoriesPage.needsUpdate = false
                categoryModel.load(false)
            }
        }
    }
}
