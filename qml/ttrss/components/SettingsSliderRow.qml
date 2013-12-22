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

Item {
    id: root

    property string text: ""
    property int value: 22
    property int min: 20
    property int max: 30

    property bool completed: false

    signal valueChanged(int value)

    width: parent.width
    height: settingText.paintedHeight + slider.height + slider.anchors.topMargin

    Label {
        id: settingText
        font.pixelSize: constant.fontSizeMedium
        text: root.text
        anchors {
            right: valuetext.left
            left: parent.left
            top: parent.top
        }
    }
    Label {
        id: valuetext
        font.pixelSize: constant.fontSizeMedium
        text: value
        anchors {
            right: parent.right
            top: parent.top
        }
    }

    Slider {
        id: slider
        anchors {
            top: settingText.bottom
            left: parent.left
            right: parent.right
        }
        minimumValue: min
        maximumValue: max
        stepSize: 1
        valueIndicatorVisible: true
        value: value
        onValueChanged: {
            if (completed) {
                root.valueChanged(value)
                valuetext.text = parseInt(value)
            }
        }
    }

    Component.onCompleted: {
        slider.value= value
        completed = true
    }
}
