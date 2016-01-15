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
import com.nokia.extras 1.1
import "../models/tinytinyrss.js" as TTRss
import "../models" 1.0

PageStackWindow {
    id: rootWindow
    initialPage: mainPage

    function openFile(file, params) {
        var component = Qt.createComponent(file)
        if (component.status === Component.Ready) {
            if (params !== undefined)
                pageStack.push(component, params);
            else
                pageStack.push(component);
        } else {
            console.log("Error loading component:", component.errorString());
        }
    }
    function pageStackReplace(file, params) {
        var component = Qt.createComponent(file)
        if (component.status === Component.Ready) {
            if (params !== undefined)
                pageStack.replace(component, params);
            else
                pageStack.replace(component);
        } else {
            console.log("Error loading component:", component.errorString());
        }
    }

    function getTTRSS() {
        return TTRss;
    }

    Binding {
        target: theme
        property: "inverted"
        value: !settings.whiteTheme
    }

    Constants {
        id: constant
    }

    InfoBanner {
        id: infoBanner
        topMargin: 50
    }

    MainPage {
        id: mainPage
    }

    CategoryModel {
        id: categories
    }

    FeedModel {
        id: feeds
        categories: categories
    }

    FeedItemModel {
        id: feedItems
        categories: categories
    }

    Component.onCompleted: {
        theme.inverted = !settings.whiteTheme
    }
}
