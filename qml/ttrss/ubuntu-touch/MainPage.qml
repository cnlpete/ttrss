import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Keyboard 0.1

Item {
    id: root
    anchors.fill: parent
    anchors.margins: units.gu(1)
    property bool doAutoLogin: true

    Flickable {
        contentHeight: contentcontainer.height
        contentWidth: parent.width
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: osk.top

        /* TODO
        PullDownMenu {
            AboutItem {}
            SettingsItem {}
            MenuItem {
                text: qsTr("No Account Yet?")
                onClicked: {
                    Qt.openUrlExternally("http://tt-rss.org/redmine/projects/tt-rss/wiki");
                }
            }
        }
        */

        Column {
            id: contentcontainer
            width: parent.width
            spacing: units.gu(1)

            Image {
                width: 256
                height: 256
                anchors.horizontalCenter: parent.horizontalCenter
                source: "../resources/ttrss256.png"

                anchors.bottomMargin: Theme.paddingLarge
            }

            Column {
                width: parent.width
                Label {
                    id: serverLabel
                    text: qsTr("Server:")
                    width: parent.width
                    font.pixelSize: Theme.fontSizeMedium
                }
                TextField {
                    id: server
                    text: ""
                    width: parent.width
                    enabled: !network.loading
                    inputMethodHints: Qt.ImhUrlCharactersOnly + Qt.ImhNoPredictiveText
                    KeyNavigation.tab: username
                    Keys.onReturnPressed: username.forceActiveFocus()
                    InputMethod.extensions: { "enterKeyText": qsTr("Next") }
                }
            }

            Column {
                width: parent.width
                Label {
                    id: usernameLabel
                    text: qsTr("Username:")
                    width: parent.width
                    font.pixelSize: Theme.fontSizeMedium
                }
                TextField {
                    id: username
                    text: ""
                    width: parent.width
                    enabled: !network.loading
                    inputMethodHints: Qt.ImhNoPredictiveText + Qt.ImhNoAutoUppercase
                    KeyNavigation.tab: password
                    KeyNavigation.backtab: server
                    Keys.onReturnPressed: password.forceActiveFocus()
                    InputMethod.extensions: { "enterKeyText": qsTr("Next") }
                }
            }

            Column {
                width: parent.width
                Label {
                    id: passwordLabel
                    text: qsTr("Password:")
                    width: parent.width
                    font.pixelSize: Theme.fontSizeMedium
                }
                TextField {
                    id: password
                    echoMode: TextInput.Password
                    width: parent.width
                    enabled: !network.loading
                    KeyNavigation.backtab: username
                    Keys.onReturnPressed: root.submit()
                    InputMethod.extensions: { "enterKeyText": qsTr("Login") }
                }
            }
            CheckBox {
                text: qsTr('Ignore SSL Errors')
                visible: server.text.substring(0, 5) === "https"
                checked: settings.ignoreSSLErrors
                onCheckedChanged: settings.ignoreSSLErrors = checked
            }

            Item {
                width: parent.width
                height: clearButton.height
                Button {
                    id: clearButton
                    text: qsTr("Clear")
                    width: Math.floor(parent.width / 2) - units.gu(1)
                    onClicked: {
                        server.text = ''
                        username.text = ''
                        password.text = ''

                        settings.httpauthusername = ''
                        settings.httpauthpassword = ''
                        settings.servername = server.text
                        settings.username = username.text
                        settings.password = password.text
                    }
                    enabled: !network.loading
                }
                Button {
                    id: loginButton
                    anchors.right: parent.right
                    text: qsTr("Login")
                    width: Math.floor(parent.width / 2) - units.gu(1)
                    onClicked: root.submit()
                    enabled: !network.loading
                }
            }
        }
    }
    ActivityIndicator {
        id: busyindicator1
        running: network.loading
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
    }

    Item {
        id: osk
        height: Qt.inputMethod.visible ? Qt.inputMethod.keyboardRectangle.height : 0
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    function enableLoginBox(focus) {
        if(focus) {
            password.forceActiveFocus();
        }
    }

    function submit() {
        // check the servername for httpauth data and set/extract those
        var httpauthregex = /(https?:\/\/)?(\w+):(\w+)@(\w.+)/
        var servername = server.text
        var regexres = servername.match(httpauthregex)
        if (regexres !== null) {
            server.text = (regexres[1]?regexres[1]:'') + regexres[4]
            settings.httpauthusername = regexres[2]
            settings.httpauthpassword = regexres[3]
        }

        settings.servername = server.text
        settings.username = username.text
        settings.password = password.text

        startLogin();
    }

    function startLogin() {
        var ttrss = rootWindow.getTTRSS();
        ttrss.clearState();
        ttrss.setLoginDetails(username.text, password.text, server.text);
        // BUGFIX since somehow the silica QML Image can not display images coming from a secure line
        if (settings.ignoreSSLErrors && server.text.substring(0, 5) === "https")
            ttrss.setProxy("http://proxy.cnlpete.de/proxy.php?url=")
        if (settings.httpauthusername != '' && settings.httpauthpassword != '') {
            ttrss.setHttpAuthInfo(settings.httpauthusername, settings.httpauthpassword);
            console.log('doing http basic auth with username ' + settings.httpauthusername)
        }
        ttrss.login(loginSuccessfull);
    }

    function loginSuccessfull(retcode, text) {
        if(retcode) {
            //login failed....don't autlogin
            settings.autologin = false

            //Let the user know
//            loginErrorDialog.text = text;
//            loginErrorDialog.open();
        }
        else {
            //Login succeeded, auto login next Time
            settings.autologin = true
            rootWindow.getTTRSS().updateConfig(configSuccessfull);
        }
    }

    function configSuccessfull(retcode, text) {
        if(retcode) {
            //Let the user know
//            loginErrorDialog.text = text;
//            loginErrorDialog.open();
        }
        else {
            categories.update()
            pageStack.clear()
            //Now show the categories View
            if (settings.useAllFeedsOnStartup) {
                var ttrss = rootWindow.getTTRSS()
                pageStack.push("Feeds.qml", {
                    category: {
                        categoryId: ttrss.constants['categories']['ALL'],
                        title: constant.allFeeds,
                        unreadcount: 0
                    }
                })
            }
            else
                pageStack.push(Qt.resolvedUrl('Categories.qml'))
        }
    }

    Component.onCompleted: {
        server.text = settings.servername
        username.text = settings.username
        password.text = settings.password

        if (settings.autologin && settings.useAutologin && doAutoLogin)
            startLogin();
    }
}
