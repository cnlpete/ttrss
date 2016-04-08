import QtQuick 2.0
import Ubuntu.Components 1.3
import "../models/tinytinyrss.js" as TTRss
import "../models" 1.0
 
/*!
    brief MainView with a Label and Button elements.
*/
 
MainView {
    id: rootWindow
    applicationName: Qt.application.name
    automaticOrientation: true
 
    width: units.gu(45)
    height: units.gu(75)
 
    PageStack {
        id: pageStack
        Component.onCompleted: push(mainPage)

        MainPage {
            id: mainPage
        }
    }

    function getTTRSS() {
        return TTRss;
    }

    property bool showAll: false

    Constants{ id: constant }

    CategoryModel {
        id: categoryModel
    }
    FeedModel {
        id: feedModel
        categories: categoryModel
    }
    FeedItemModel {
        id: feedItemModel
        categories: categoryModel
    }
}
