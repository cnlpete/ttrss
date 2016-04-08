//Copyright Alberto Mardegan, 2015
//
//This file is part of TTRss.
//
//TTRss is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the
//Free Software Foundation, either version 2 of the License, or (at your option) any later version.
//TTRss is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with TTRss (on a Maemo/Meego system there is a copy
//in /usr/share/common-licenses. If not, see http://www.gnu.org/licenses/.

import QtQuick 2.0
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3
import Ubuntu.DownloadManager 1.2

Page {
    id: root

    property string url: ""
    property alias contentType: picker.contentType

    property var __activeTransfer: null

    title: qsTr("Save to")
    visible: false

    onUrlChanged: singleDownload.download(url)

    ContentPeerPicker {
        id: picker
        showTitle: false
        handler: ContentHandler.Destination
        onPeerSelected: {
            console.log("Peer selected")
            __activeTransfer = peer.request()
            __activeTransfer.downloadId = singleDownload.downloadId
            __activeTransfer.state = ContentTransfer.Downloading
            pageStack.pop()
        }
    }

    SingleDownload {
        id: singleDownload
        autoStart: false
    }
}
