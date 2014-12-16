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

import QtQuick 1.1
import com.nokia.meego 1.0
import "../components" 1.0

Page {
    id: categoriesPage
    tools: categoriesTools
    property bool needsUpdate: false

    onVisibleChanged: {
        if (visible && categoriesPage.needsUpdate) {
            categoriesPage.needsUpdate = false
            categories.load(false)
        }
    }

    Item {
        anchors {
            top: pageHeader.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: MyTheme.paddingMedium
        }
        ListView {
            id: listView
            anchors.fill: parent

            model: categories

            delegate: CategoryDelegate {
                onClicked: {
                    categories.selectedIndex = index
                    showCategory(model)
                }
            }
        }
        ScrollDecorator {
            flickableItem: listView
        }
        EmptyListInfoLabel {
            text: network.loading ?
                      qsTr("Loading") :
                      settings.showAll ? qsTr("No categories to display") : qsTr("No categories have unread items")
            anchors.fill: parent
            visible: categories.count == 0
        }
    }

    function showCategory(categoryModel) {
        if(categoryModel != null) {
            rootWindow.openFile("Feeds.qml", {
                                    category: categoryModel
                                })
        }
    }

    PageHeader {
        id: pageHeader
        text: qsTr("Tiny Tiny RSS Reader")

        hasUpdateAction: true
        onUpdateActionActivated: {
            categories.update()
        }
    }

    ToolBarLayout {
        id: categoriesTools

        ToolIcon { iconId: "toolbar-back"; onClicked: { categoriesMenu.close(); pageStack.pop(); } }
        ToolIcon { iconId: "toolbar-view-menu" ; onClicked: (categoriesMenu.status === DialogStatus.Closed) ? categoriesMenu.open() : categoriesMenu.close() }
    }

    Menu {
        id: categoriesMenu
        visualParent: pageStack

        MenuLayout {
            ToggleShowAllItem {
                onUpdateView: {
                    if (categoriesPage.visible) {
                        categories.load(false)
                    } else {
                        categoriesPage.needsUpdate = true
                    }
                }
            }
            SettingsItem {}
            AboutItem {}
        }
    }
}
