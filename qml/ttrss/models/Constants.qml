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

//import QtQuick 1.1 // harmattan
import QtQuick 2.0 // sailfish

QtObject{
    id: constant

    property url sourceRepoSite: "http://ttrss.cnlpete.de/"
    property url issueTrackerUrl: "https://github.com/cnlpete/ttrss/issues"
    property url registerUrl: "http://tt-rss.org/redmine/projects/tt-rss/wiki"
    property url donateUrl: "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=WUWGSGAK8K7ZN"

    property string archivedArticles: qsTr('Archived articles')
    property string starredArticles: qsTr('Starred articles')
    property string publishedArticles: qsTr('Published articles')
    property string freshArticles: qsTr('Fresh articles')
    property string allArticles: qsTr('All articles')
    property string recentlyArticles: qsTr('Recently read')

    property string labelsCategory: qsTr('Labels')
    property string specialCategory: qsTr('Special')
    property string allFeeds: qsTr('All Feeds')
    property string uncategorizedCategory: qsTr('Uncategorized')
}
