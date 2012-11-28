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
    id: itemListPage
    tools: feedItemsTools
    property int feedId: 0
    property string pageTitle: ""
    property int numStatusUpdates
    property bool loading: false

    anchors.margins: rootWindow.pageMargin

    ListModel {
        id: itemListModel
    }

    ListView {
        id: listView
        anchors.margins: constant.paddingLarge
        anchors{ top: pageHeader.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
        model: itemListModel

        delegate:  Item {
            id: listItem
            height: 88
            width: parent.width

            BorderImage {
                id: background
                anchors.fill: parent
                // Fill page borders
                anchors.leftMargin: -itemListPage.anchors.leftMargin
                anchors.rightMargin: -itemListPage.anchors.rightMargin
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
                        font.pixelSize: constant.fontSizeLarge
                        color: (model.unread > 0) ? constant.colorListItemActive : constant.colorListItemDisabled;
                        elide: Text.ElideRight
                    }

                    Label {
                        id: subText
                        text: model.subtitle
                        font.weight: Font.Light
                        font.pixelSize: constant.fontSizeSmall
                        color: (model.unread > 0) ? constant.colorListItemActiveTwo : constant.colorListItemDisabled;
                        elide: Text.ElideRight
                        visible: text != ""
                    }
                }
            }

            Image {
                id: drilldownarrow
                source: "image://theme/icon-m-common-drilldown-arrow" + (theme.inverted ? "-inverse" : "")
                anchors.right: parent.right;
                anchors.verticalCenter: parent.verticalCenter
                visible: ((model.id != null)&&(model.id !== "__ttrss_get_more_items"))
            }


            MouseArea {
                id: mouseArea
                anchors.fill: background
                onClicked: { showFeedItem(model.id, feedId, model.title) }
            }
        }
    }
    ScrollDecorator {
        flickableItem: listView
    }

    function showFeedItem(articleId, feedId, title) {
        if(articleId != null && feedId != null) {
            console.log("Loading items for "+articleId+" in "+feedId+"\n");
            var component = Qt.createComponent("FeedItem.qml");
            if (component.status === Component.Ready)
                pageStack.push(component, {
                                   articleId: articleId,
                                   feedId: feedId,
                                   pageTitle: title
                               });
            else
                console.log("Error loading component:", component.errorString());
        }
    }

    function updateFeedItems() {
        loading = true;
        var ttrss = rootWindow.getTTRSS();
        numStatusUpdates = ttrss.getNumStatusUpdates();
        ttrss.updateFeedItems(feedId, showFeedItems);
    }

    function showFeedItems() {
        var ttrss = rootWindow.getTTRSS();
        var feeditems = ttrss.getFeedItems(feedId);
        var showAll = ttrss.getShowAll();
        itemListModel.clear();

        loading = false;

        if (feeditems && feeditems.length) {
            for(var feeditem = 0; feeditem < feeditems.length; feeditem++) {
                itemListModel.append({
                                         title:    ttrss.html_entity_decode(feeditems[feeditem].title, 'ENT_QUOTES'),
                                         subtitle: "subtitle",
                                         id:       feeditems[feeditem].id,
                                         unread:   !!feeditems[feeditem].unread,
                                     });
            }
        }
        else {
            itemListModel.append({
                                     title:     (showAll ? "No items in feed" : "No unread items in feed"),
                                     subtitle:  "",
                                     id:        null,
                                     unread:    false,
                                 });
        }
    }

    function getMoreItems() {
        updateFeedItems();
    }

    onFeedIdChanged: {
        showFeedItems();
        updateFeedItems();
    }

    Component.onCompleted: {
        showFeedItems();
        updateFeedItems();
    }

    onStatusChanged: {
        var ttrss = rootWindow.getTTRSS();
        if(status === PageStatus.Deactivating)
            numStatusUpdates = ttrss.getNumStatusUpdates();
        else if (status === PageStatus.Activating) {
            if(ttrss.getNumStatusUpdates() > numStatusUpdates)
                updateFeedItems();
        }
    }

    PageHeader {
        id: pageHeader
        text: pageTitle
    }

    ToolBarLayout {
        id: feedItemsTools

        ToolIcon { iconId: "toolbar-back"; onClicked: { feedItemsMenu.close(); pageStack.pop();} }
        ToolIcon {
            iconId: "toolbar-refresh";
            visible: !loading;
            onClicked: { updateFeedItems(); }
        }
        BusyIndicator {
            visible: loading
            running: loading
            platformStyle: BusyIndicatorStyle { size: 'medium' }
        }
        ToolIcon { iconId: "toolbar-view-menu" ; onClicked: (feedItemsMenu.status === DialogStatus.Closed) ? feedItemsMenu.open() : feedItemsMenu.close() }
    }

    Menu {
        id: feedItemsMenu
        visualParent: pageStack

        MenuLayout {
            MenuItem {
                id: toggleUnread
                text: qsTr("Toggle Unread Only")
                onClicked: {
                    var ttrss = rootWindow.getTTRSS();
                    var oldval = ttrss.getShowAll();
                    var newval = !oldval;
                    ttrss.setShowAll(newval);

                    ttrss.updateFeedItems(feedId, showFeedItems);
                }
            }
            MenuItem {
                text: qsTr("About")
                onClicked: {
                    rootWindow.openFile("About.qml");
                }
            }
        }
    }
}
