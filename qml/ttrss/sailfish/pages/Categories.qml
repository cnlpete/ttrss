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

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: categoriesPage

    SilicaListView {
        id: listView
        anchors.fill: parent

        model: categories

        PullDownMenu {
            AboutItem {}
            SettingsItem {}
            ToggleShowAllItem {
                onUpdateView: {
                    categories.update()
                }
            }
        }

        delegate: CategoryDelegate {
            onClicked: {
                categories.selectedIndex = index
                showCategory(model)
            }
        }

        header: PageHeader {
           title: qsTr("Tiny Tiny RSS Reader")
        }
        ViewPlaceholder {
            enabled: listView.count == 0
            text: network.loading ?
                      qsTr("Loading") :
                      rootWindow.showAll ? qsTr("No categories to display") : qsTr("No categories have unread items")
        }
        ScrollDecorator {
            flickable: listView
        }
    }

    function showCategory(categoryModel) {
        if(categoryModel != null) {
            pageStack.push("Feeds.qml", {
                                    category: categoryModel
                                })
        }
    }
}
