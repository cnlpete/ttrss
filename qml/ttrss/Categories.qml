//Copyright Hauke Schade, 2012
//
//This file is part of TTRss.
//
//TTRss is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the
//Free Software Foundation, either version 2 of the License, or (at your option) any later version.
//TTRss is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with TTRss (on a Maemo/Meego system there is a copy
//in /usr/share/common-licenses. If not, see http://www.gnu.org/licenses/.

import QtQuick 1.1
import com.nokia.meego 1.0

Page {
    id: categoriesPage
    tools: categoriesTools
    anchors.margins: rootWindow.pageMargin

    property int numStatusUpdates
    property bool loading: false

    ListModel {
        id: categoriesModel
    }

    ListView {
        id: listView
        anchors.fill: parent

        model: categoriesModel

        delegate:  Item {
            id: listItem
            height: 88
            width: parent.width

            BorderImage {
                id: background
                anchors.fill: parent
                // Fill page borders
                anchors.leftMargin: -categoriesPage.anchors.leftMargin
                anchors.rightMargin: -categoriesPage.anchors.rightMargin
                visible: mouseArea.pressed
                source: "image://theme/meegotouch-list-background-pressed-center"
            }

            Row {
                anchors.left: parent.left
                anchors.right: drilldownarrow.left
                clip: true

                Column {
                    clip: true

                    Label {
                        id: mainText
                        text: model.title
                        font.weight: Font.Bold
                        font.pixelSize: 26
                        color: (model.unreadcount > 0) ? "#000033" : "#888888";

                    }

                    Label {
                        id: subText
                        text: model.subtitle
                        font.weight: Font.Light
                        font.pixelSize: 22
                        color: (model.unreadcount > 0) ? "#cc6633" : "#888888"

                        visible: text != ""
                    }
                }
            }

            Image {
                id: drilldownarrow
                source: "image://theme/icon-m-common-drilldown-arrow" + (theme.inverted ? "-inverse" : "")
                anchors.right: parent.right;
                anchors.verticalCenter: parent.verticalCenter
                visible: model.categoryId !== null
            }

            MouseArea {
                id: mouseArea
                anchors.fill: background
                onClicked: {
                    showCategory(model.categoryId);
                }
            }
        }
    }
    ScrollDecorator {
        flickableItem: listView
    }

    function showCategories() {
        var ttrss = rootWindow.getTTRSS();
        var showAll = ttrss.getShowAll();
        var categories = ttrss.getCategories();
        categoriesModel.clear();

        if(categories) {
            var someCategories   = false;
            var totalUnreadCount = 0;

            //first add all the categories with unread itens
            for(var category in categories) {
                someCategories = true;

                if(categories[category].unread > 0) {
                    if (category >= 0)
                        totalUnreadCount += categories[category].unread;

                    categoriesModel.append({
                                               title:       ttrss.html_entity_decode(categories[category].title,'ENT_QUOTES'),
                                               subtitle:    "Unread: " + categories[category].unread,
                                               unreadcount: categories[category].unread,
                                               categoryId:  categories[category].id
                                           });
                }
            }

            //then if we are showing all categories, add the ones with no unread items
            if(showAll) {
                for(var category in categories) {
                    if(categories[category].unread === 0) {
                        categoriesModel.append({
                                                   title:       ttrss.html_entity_decode(categories[category].title,'ENT_QUOTES'),
                                                   subtitle:    "Unread: 0",
                                                   unreadcount:  0,
                                                   categoryId:   categories[category].id
                                               });
                    }
                }
            }

            if((totalUnreadCount > 0) || ((showAll) && someCategories)) {
                //Add the "All category"
                categoriesModel.insert(0, {
                                           title: qsTr("All Categories"),
                                           subtitle: "Unread: " + totalUnreadCount,
                                           categoryId: ttrss.constants['ALL_CATEGORIES'],
                                           unreadcount: totalUnreadCount,
                                       });
            }
            else if (!someCategories) {
                //There are categories they just don't have unread items
                categoriesModel.append({
                                           title: qsTr("No categories have unread items"),
                                           subtitle: "",
                                           categoryId: null,
                                           unreadcount: 0,
                                       });
            }
            else {
                //There are no categories
                categoriesModel.append({
                                           title: qsTr("No categories to display"),
                                           subtitle: "",
                                           categoryId: null,
                                           unreadcount: 0,
                                       });
            }
        }
    }

    Component.onCompleted: {
        var ttrss = rootWindow.getTTRSS();
//        gr.addStatusListener(categoriesStatusListener);
        numStatusUpdates = ttrss.getNumStatusUpdates();
        ttrss.updateCategories(showCategories);
    }

    onStatusChanged: {
        var ttrss = rootWindow.getTTRSS();
        if(status === PageStatus.Deactivating) {
            numStatusUpdates = ttrss.getNumStatusUpdates();
        } else if (status === PageStatus.Activating) {
            if(ttrss.getNumStatusUpdates() > numStatusUpdates) {
                numStatusUpdates = ttrss.getNumStatusUpdates();
                updateCategories(showCategories);
            }
        }
    }

    ToolBarLayout {
        id: categoriesTools

        ToolIcon { iconId: "toolbar-back"; onClicked: { categoriesMenu.close(); pageStack.pop(); } }
        BusyIndicator {
            visible: loading
            running: loading
            platformStyle: BusyIndicatorStyle { size: 'medium' }
        }
        ToolIcon { iconId: "toolbar-view-menu" ; onClicked: (categoriesMenu.status === DialogStatus.Closed) ? categoriesMenu.open() : categoriesMenu.close() }
    }

    Menu {
        id: categoriesMenu
        visualParent: pageStack

        MenuLayout {
            MenuItem {
                text: qsTr("About")
                onClicked: {
                    rootWindow.openFile("About.qml");
                }
            }
        }
    }
}
