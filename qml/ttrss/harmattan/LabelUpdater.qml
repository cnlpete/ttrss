/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2016  Hauke Schade
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
    id: page
    tools: theToolbar

    property alias headline: pageHeader.subtext
    property variant labels
    property variant feedItemPage

    property bool initialization: true
    property bool labelsChanged: false

    PageHeader {
        id: pageHeader
        text: qsTr("Update Labels")
    }

    ListView {
        id: listView
        anchors {
            top: pageHeader.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: MyTheme.paddingMedium
        }

        model: page.labels

        delegate: Item {
            id: item
            width: parent.width
            height: 60

            property variant label: page.labels[index]

            Switch {
                id: checkbox
                checked: item.label.checked
                enabled: !network.loading
                anchors.verticalCenter: parent.verticalCenter

                property bool noAPIcall: false

                onCheckedChanged: {
                    if (page.initialization) {
                        return
                    }
                    if (checkbox.noAPIcall) {
                        checkbox.noAPIcall = false
                        return
                    }

                    page.labelsChanged = true

                    feedItems.setLabel(item.label.id, checkbox.checked,
                                       function(successful, errorMessage) {
                                           if (!successful) {
                                               checkbox.noAPIcall = true
                                               checkbox.checked = !checkbox.checked
                                               // TODO display errorMessage
                                           }
                                       })
                }
            }

            LabelLabel {
                label: item.label
                anchors {
                    left: checkbox.right
                    verticalCenter: parent.verticalCenter
                }
            }
        }
        ScrollDecorator {
            flickableItem: listView
        }
        EmptyListInfoLabel {
            visible: listView.count === 0
            text: network.loading ?
                      qsTr("Loading") :
                      qsTr("You have no label defined. You can create them in the webview.")
        }
    }

    Component.onCompleted: {
        page.initialization = false
    }

    onStatusChanged: {
        if (page.status === PageStatus.Deactivating && page.labelsChanged) {
            feedItemPage.updateLabels()
        }
    }

    ToolBarLayout {
        id: theToolbar

        ToolIcon { iconId: "toolbar-back"; onClicked: { theMenu.close(); pageStack.pop(); } }
        ToolIcon { iconId: "toolbar-view-menu" ; onClicked: (theMenu.status === DialogStatus.Closed) ? theMenu.open() : theMenu.close() }
    }

    Menu {
        id: theMenu
        visualParent: pageStack

        MenuLayout {
            SettingsItem {}
            AboutItem {}
        }
    }
}
