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

//import QtQuick 1.1 // harmattan
import QtQuick 2.0 // sailfish

QtObject{
    id: constant

    property color sectionLabel: "#8c8c8c"

    property color colorListItemActive: theme.inverted ? "#ffffff" : "#000033"
    property color colorListItemActiveTwo: theme.inverted ? "#dd7744" : "#cc6633"
    property color colorListItemDisabled: theme.inverted ? "#aaaaaa" : "#888888"

    property color colorWebviewBG: theme.inverted ? "#000000" : "#ffffff"
    property color colorWebviewText: theme.inverted ? "#ffffff" : "#000033"

    property color colorFastScrollText: theme.inverted ? "#000033" : "#8c8c8c"

    property int listItemSpacing: 10

    property int paddingSmall: 4
    property int paddingMedium: 6
    property int paddingLarge: 8
    property int paddingXLarge: 12
    property int paddingXXLarge: 16

    property int fontSizeXXSmall: 16
    property int fontSizeXSmall: 20
    property int fontSizeSmall: 22
    property int fontSizeMedium: 24
    property int fontSizeLarge: 26
    property int fontSizeXLarge: 28
    property int fontSizeXXLarge: 32

    property int headerHeight: inPortrait ? 72 : 56
    property int headerLogoHeight: inPortrait ? 56 : 40

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
