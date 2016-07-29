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
import Ubuntu.Components 1.3

Page {
    id: categoriesPage

    property var categories

    header: PageHeader {
        title: qsTr("Tiny Tiny RSS Reader")
        flickable: listView
        trailingActionBar.actions: [
            Action {
                iconName: "settings"
                onTriggered: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            }
        ]

        extension: Sections {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            model: [ qsTr("Unread"), qsTr("All") ]
            selectedIndex: settings.showAll ? 1 : 0
            onSelectedIndexChanged: {
                var ttrss = rootWindow.getTTRSS()
                var showAll = (selectedIndex == 1)
                if (showAll != settings.showAll) {
                    ttrss.setShowAll(showAll)
                    settings.showAll = showAll
                    categories.update()
                }
            }
        }
    }

    ListView {
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

        MyPullToRefresh {
            id: pullToRefresh
            updating: network.loading
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
            running: network.loading && !pullToRefresh.refreshing
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
