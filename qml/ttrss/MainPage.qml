//Copyright Hauke Schade, 2012
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

Page {
    function openFile(file) {
        var component = Qt.createComponent(file)
        if (component.status === Component.Ready)
            pageStack.push(component);
        else
            console.log("Error loading component:", component.errorString());
    }

    property bool loading: false

    tools: commonTools

    state: (screen.currentOrientation === Screen.Portrait) ? "portrait" : "landscape"

    states: [
        State {
            name: "landscape"
            PropertyChanges {
                target: logo
                anchors.leftMargin: 50
                anchors.topMargin: 50
            }
            AnchorChanges {
                target: logo
                anchors {
                    horizontalCenter: undefined

                    left: parent.left
                    top: parent.top
                }
            }
            AnchorChanges {
                target: loginBox
                anchors {
                    horizontalCenter: undefined

                    left: logo.right
                    top: logo.top
                }
            }
            PropertyChanges {
                target: loginBox
                anchors.leftMargin: 50
            }
        },
        State {
            name: "portrait"
            AnchorChanges {
                target: logo
                anchors {
                    left: undefined

                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
            }
            AnchorChanges {
                target: loginBox
                anchors {
                    left: undefined

                    top: logo.bottom
                    horizontalCenter: parent.horizontalCenter
                }
            }
            PropertyChanges {
                target: loginBox
                anchors.topMargin: 50
            }
        }
    ]

    transitions: Transition {
        AnchorAnimation { duration: 500 }
    }

    Column {
        id: logo
        anchors {
            top: parent.top
            topMargin:  30
        }

        Image {
            width: 398
            height: 225
            source: "resources/ttrsslogo.png"
        }
    }

    Column {
        id: loginBox

        Label {
            id: serverLabel
            text: qsTr("Server:")
        }
        TextField {
            id: server
            text: ""
            width: 300
            enabled: !loading
        }
        Label {
            id: usernameLabel
            text: qsTr("Username:")
        }
        TextField {
            id: username
            text: ""
            width: 300
            enabled: !loading
        }
        Label {
            id: passwordLabel
            text: qsTr("Password:")
        }
        TextField {
            id: password
            echoMode: TextInput.PasswordEchoOnEdit
            width: 300
            enabled: !loading
        }
    }
    BusyIndicator {
        id: busyindicator1
        visible: loading
        running: loading
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        platformStyle: BusyIndicatorStyle { size: 'large' }
    }

    ToolBarLayout {
        id: commonTools
        visible: true
        ToolButton {
            id: loginButton
            text: qsTr("Login")
            anchors.right: menuButton.left
            onClicked: {
                var settings = rootWindow.settingsObject();
                settings.set("server", server.text);
                settings.set("username", username.text);
                settings.set("password", password.text);

                startLogin();
            }
            enabled: !loading
        }
        ToolIcon {
            id: menuButton
            platformIconId: "toolbar-view-menu"
            anchors.right: (parent === undefined) ? undefined : parent.right
            onClicked: (myMenu.status === DialogStatus.Closed) ? myMenu.open() : myMenu.close()
            enabled: !loading
        }
    }

    Menu {
        id: myMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem {
                text: qsTr("About")
                onClicked: {
                    openFile("About.qml");
                }
            }
        }
    }

    function enableLoginBox(focus) {
        if(focus) {
            password.forceActiveFocus();
        }
    }

    function startLogin() {
        // close the menu
        if (myMenu.status !== DialogStatus.Closed)
            myMenu.close()

        //Start the loading anim
        loading = true;

    }

    //Dialog for login errors
    Dialog {
        id: loginErrorDialog
        title: Rectangle {
            id: titleField
            height: 2
            width: parent.width
            color: "red"
        }

        content:Item {
            id: loginErrorDialogContents
            height: 50
            width: parent.width
            Text {
                id: loginErrorDialogText
                font.pixelSize: 22
                anchors.centerIn: parent
                color: "white"
                text: "Hello Dialog"
            }
        }

        buttons: ButtonRow {
            style: ButtonStyle { }
            anchors.horizontalCenter: parent.horizontalCenter
            Button { text: "OK"; onClicked: loginErrorDialog.accept() }
        }
    }

    Component.onCompleted: {
        var settings = rootWindow.settingsObject();
        settings.initialize();
        server.text = settings.get("server", "http://");
        username.text = settings.get("username", "");
        password.text = settings.get("password", "");
        var dologin = settings.get("dologin", "false");

        if(dologin === "true") {
            startLogin();
        }
    }
}
