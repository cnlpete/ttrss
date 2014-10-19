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


ComboBox {
    property int initialValue
    property alias model: repeater.model

    function getInitialValue() {
        for (var i = 0; i < model.count; i++) {
            if (repeater.model.get(i).value === initialValue) {
                box.currentIndex = i
                break
            }
        }
    }

    function startTimer() {
        timer.start()
    }

    id: box
    menu: ContextMenu {
        Repeater {
            id: repeater
            MenuItem {
                text: model.name
            }
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
