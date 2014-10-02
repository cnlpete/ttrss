/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2014  Hauke Schade
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

Button {
    property int initialValue
    property alias model: comboboxDialog.model
    property bool withTimer: true
    property alias currentIndex: comboboxDialog.selectedIndex

    signal currentIndexChanged()

    id: comboboxButton
    width: parent.width

    function getInitialValue() {
        for (var i = 0; i < model.count; i++) {
            if (comboboxDialog.model.get(i).value == initialValue) {
                comboboxDialog.selectedIndex = i
                comboboxButton.text = comboboxDialog.model.get(i).name
                break
            }
        }
    }

    function startTimer() {
        timer.start()
    }

    Component.onCompleted: {
        if (withTimer)
            timer.start()
    }

    text: comboboxDialog.model.get(0).text
    onClicked: comboboxDialog.open();

    ToolIcon {
        id: filterImage
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        platformIconId: "textinput-combobox-arrow"
    }

    SelectionDialog {
        id: comboboxDialog
        titleText: "Category"
        onAccepted: {
            comboboxButton.text = comboboxDialog.model.get(comboboxDialog.selectedIndex).name
            comboboxButton.currentIndexChanged()
        }
    }

    Timer {
        id: timer
        interval: 500
        repeat: false
        triggeredOnStart: false
        onTriggered: getInitialValue()
    }
}
