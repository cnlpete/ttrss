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

Page {
    id: page

    property int articleId
    property string headline
    property var labels
    property var feedItemPage

    property bool initialization: true
    property bool labelsChanged: false

    SilicaListView {
        id: listView
        anchors.fill: page
        anchors.leftMargin: Theme.paddingMedium
        anchors.rightMargin: Theme.paddingMedium
        model: page.labels


        header: Column {
            width: listView.width
            height: header.height + info.height
            PageHeader {
                id: header
                width: page.width
                title: qsTr("Update Labels")
            }
            Label {
                id: info
                text: page.headline !== null ? page.headline : ""
                width: parent.width
                font.weight: Font.Bold
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                visible: page.headline !== null && page.headline !== ""
            }
        }


        delegate: ListItem {
            id: item

            width: parent.width
            property var label: page.labels[index]

            Switch {
                id: checkbox
                checked: item.label.checked
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
                    checkbox.busy = true

                    var ttrss = rootWindow.getTTRSS();
                    ttrss.setLabel(page.articleId, item.label.id,
                                   checkbox.checked,
                                   function(successful, errorMessage) {
                                       checkbox.busy = false
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
    }

    BusyIndicator {
        visible: network.loading
        running: visible
        anchors {
            horizontalCenter: page.horizontalCenter
            verticalCenter: page.verticalCenter
        }
        size: BusyIndicatorSize.Large
    }

    Component.onCompleted: {
        page.initialization = false
    }

    onStatusChanged: {
        if (page.status === PageStatus.Deactivating && page.labelsChanged) {
            feedItemPage.updateLabels()
        }
    }
}
