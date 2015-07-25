//Copyright Hauke Schade, 2012-2014
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
import Ubuntu.Components 1.1

Page {
    id: categoriesPage
    title: qsTr("Tiny Tiny RSS Reader")

    property var categories

    head {
        actions: [
            Action {
                iconName: "settings"
                onTriggered: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            }
        ]

        sections {
            model: [ qsTr("Unread"), qsTr("All") ]
            selectedIndex: settings.showAll ? 1 : 0
            onSelectedIndexChanged: {
                var ttrss = rootWindow.getTTRSS()
                var showAll = (categoriesPage.head.sections.selectedIndex == 1)
                if (showAll != settings.showAll) {
                    ttrss.setShowAll(showAll)
                    settings.showAll = showAll
                    categories.update()
                }
            }
        }
    }

    UbuntuListView {
        id: listView
        anchors.fill: parent

        model: categories

        /* TODO
        PullDownMenu {
            //AboutItem {}
            MenuItem {
                text: qsTr("Logout")
                visible: pageStack.depth == 1
                onClicked: {
                    pageStack.replace(Qt.resolvedUrl("MainPage.qml"), { doAutoLogin: false })
                }
            }
        }
        */

        pullToRefresh {
            enabled: true
            onRefresh: categories.update()
            refreshing: network.loading
        }

        delegate: CategoryDelegate {
            onClicked: {
                categories.selectedIndex = index
                showCategory(categories.getSelectedItem())
            }
        }

        Label {
            visible: listView.count == 0
            text: network.loading ?
                      qsTr("Loading") :
                      rootWindow.showAll ? qsTr("No categories to display") : qsTr("No categories have unread items")
        }
        ActivityIndicator {
            running: listView.count != 0 && network.loading
            anchors.centerIn: parent
        }
        Scrollbar {
            flickableItem: listView
        }
    }

    function showCategory(categoryModel) {
        if (categoryModel != null) {
            pageStack.push(Qt.resolvedUrl("Feeds.qml"), {
                category: categoryModel
            })
        }
    }
}
