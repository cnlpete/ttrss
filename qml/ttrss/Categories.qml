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

import QtQuick 1.1
import com.nokia.meego 1.0

Page {
    id: categoriesPage
    tools: categoriesTools

    property int numStatusUpdates
    property bool loading: false

    ListModel {
        id: categoriesModel
    }

    ListView {
        id: listView
        anchors.margins: constant.paddingLarge
        anchors{ top: pageHeader.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }

        model: categoriesModel

        delegate: CategoryDelegate {
            onClicked: showCategory(model.categoryId, model.title)
        }
    }
    ScrollDecorator {
        flickableItem: listView
    }

    function showCategory(catId, title) {
        if(catId != null) {
            var component = Qt.createComponent("Feeds.qml");
            if (component.status === Component.Ready)
                pageStack.push(component, { categoryId: catId, pageTitle: title });
            else
                console.log("Error loading component:", component.errorString());
        }
    }

    function updateCategories() {
        loading = true;
        var ttrss = rootWindow.getTTRSS();
        numStatusUpdates = ttrss.getNumStatusUpdates();
        ttrss.updateCategories(showCategoriesCallback);
    }

    function showCategoriesCallback() {
        loading = false;
        showCategories();
    }

    function showCategories() {
        var ttrss = rootWindow.getTTRSS();
        var showAll = ttrss.getShowAll();
        var categories = ttrss.getCategories();
        categoriesModel.clear();

        if(categories && categories.length) {
            var totalUnreadCount = 0;

            //first add all the categories with unread itens
            for(var category = 0; category < categories.length; category++) {
                if (categories[category].id >= 0)
                    totalUnreadCount += categories[category].unread;

                var title = ttrss.html_entity_decode(categories[category].title,'ENT_QUOTES')
                if (categories[category].id == ttrss.constants['categories']['ALL'])
                    title = constant.allFeeds
                if (categories[category].id == ttrss.constants['categories']['LABELS'])
                    title = constant.labelsCategory
                if (categories[category].id == ttrss.constants['categories']['SPECIAL'])
                    title = constant.specialCategory
                if (categories[category].id == ttrss.constants['categories']['UNCATEGORIZED'])
                    title = constant.uncategorizedCategory

                categoriesModel.append({
                                           title:       title,
                                           unreadcount: categories[category].unread,
                                           categoryId:  categories[category].id
                                       });
            }

            if(totalUnreadCount > 0 || showAll) {
                //Add the "All" category
                categoriesModel.insert(0, {
                                           title: constant.allFeeds,
                                           categoryId: ttrss.constants['categories']['ALL'],
                                           unreadcount: totalUnreadCount,
                                       });
            }
        }
        else {
            //There are no categories
            var t = (showAll ? qsTr("No categories to display") : qsTr("No categories have unread items"))
            categoriesModel.append({
                                       title: t,
                                       categoryId: null,
                                       unreadcount: 0,
                                   });
        }
    }

    Component.onCompleted: {
        showCategories();
        updateCategories();
    }

    onVisibleChanged: {
        if (visible)
            showCategories();
    }

    onStatusChanged: {
        var ttrss = rootWindow.getTTRSS();
        if(status === PageStatus.Deactivating)
            numStatusUpdates = ttrss.getNumStatusUpdates();
        else if (status === PageStatus.Activating) {
            if(ttrss.getNumStatusUpdates() > numStatusUpdates)
                updateCategories();
        }
    }

    PageHeader {
        id: pageHeader
        text: qsTr("Tiny Tiny RSS Reader")
    }

    ToolBarLayout {
        id: categoriesTools

        ToolIcon { iconId: "toolbar-back"; onClicked: { categoriesMenu.close(); pageStack.pop(); } }
        ToolIcon {
            iconId: "toolbar-refresh";
            visible: !loading;
            onClicked: { updateCategories(); }
        }
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
            ToggleShowAllItem {
                onUpdateView: {
                    updateCategories()
                }
            }
            SettingsItem {}
            AboutItem {}
        }
    }
}
