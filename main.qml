import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtQuick.LocalStorage 2.0
import QtQuick.Layouts 1.12

import QtWebSockets 1.14
import QtPositioning 5.14
import Cometogether.downloader 1.0

ApplicationWindow {
    id: mainWindow
    visible: true
    title: qsTr("Come together")
    minimumWidth: Screen.width/1.5; minimumHeight: Screen.height/1.5
    property var db
    property string currentUserLogin: ""
    property string currentUserDN: ""
    property string serverIP: "178.150.141.36:1337"
    property string profileImageBase64: ""


    BackendFileDonwloader {
         id: downloader
         onDownloaded: {
             console.log("FB: downloaded image for login: " + login)
             if (login === currentUserLogin)
                 profileImageBase64 = image
             uploadImage(login, image)
             //addUserImagePath(id, path) //FB user login same as FB id
         }
    }

    WebSocket {
        property bool show_popup: true
        id: mainWebsocket
        url: "ws://" + serverIP
        onStatusChanged: { //webscoket is opened when http login confirmation received
            if (status == WebSocket.Open){
                console.log("WS: connected to server")
                let login_user_msg = {}
                login_user_msg["method"] = "login_user"
                login_user_msg["login"] = currentUserLogin
                mainWebsocket.sendTextMessage(JSON.stringify(login_user_msg))
                conversationModel.setCurrentUserLogin(currentUserLogin)
                contactModel.setCurrentUserLogin(currentUserLogin)
                contact_image_provider.setCurrentUserLogin(currentUserLogin)
                currentUserDN = GUIConnector.getDisplayNameByLogin(currentUserLogin) //blocking function
                if (!contactModel.userPresent(currentUserLogin)) //hack: add myself to contacts
                    contactModel.addContact(currentUserLogin, currentUserDN)

            }
            else if (status == WebSocket.Closing || status == WebSocket.Closed){
                if (currentUserLogin.length !== 0){
                    console.log("WS: lost connection to server")
                    currentUserLogin = ""
                    currentUserDN = ""
                    conversationModel.setCurrentUserLogin(currentUserLogin)
                    contactModel.setCurrentUserLogin(currentUserLogin)
                    contact_image_provider.setCurrentUserLogin(currentUserLogin)
                    if (show_popup){
                        popup.popMessage = qsTr("Соединение с сервером потеряно")
                        popup.open()
                    }
                    stack.pop(null)
                }
            }
        }

        onTextMessageReceived: {
        }
    }

    Rectangle {
        id: load
        anchors.fill: parent
        color: "white"
        opacity: 0.5
        visible: false
        z: 10
        BusyIndicator {
            anchors.centerIn: parent
            running: true
        }
    }

    //Popup to show messages or warnings on the bottom postion of the screen
        Popup {
            id: popup
            property alias popMessage: message.text

            background: Rectangle {
                implicitWidth: mainWindow.width
                implicitHeight: 60
                color: "#b44"
            }
            y: (mainWindow.height - 60)
            modal: true
            focus: true
            closePolicy: Popup.CloseOnPressOutside
            Text {
                id: message
                anchors.centerIn: parent
                font.pointSize: 12
                color: "white"
            }
            onOpened: popupClose.start()
        }
        Timer {
            id: popupClose
            interval: 2000
            onTriggered: popup.close()
        }
        Popup {
            id: popup_msg
            property alias text: text_content.text
            property alias img: img.source
            property alias dn_alias: text_dn.text
            property string dn: ""
            property string login: ""

            background: Rectangle {
                implicitWidth: mainWindow.width
                implicitHeight: 60
                color: "#b44"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (stack.top !== "chat.qml") {
                        conversationModel.setRecipient(popup_msg.login)
                        stack.push("chat.qml", {"inConversationWith" : popup_msg.login,
                                       "inConversationWithDN": popup_msg.dn})
                        popup_msg.close()
                    }
                }
            }
            y: 30
            modal: true
            focus: true
            closePolicy: Popup.CloseOnPressOutside
            RowLayout{
                Image {
                    visible: true
                    BusyIndicator {
                        anchors.centerIn: parent
                        running: img.status !== Image.Ready
                    }
                    id: img
                    sourceSize.width: 40
                    sourceSize.height: 40
                    onStatusChanged: {
                        if (img.status !== Image.Ready){
                            if (img === null || img.source === undefined)
                                return
                            delay(500, function(){ let old_src = img.source;
                                img.source = "";
                                img.source = old_src})
                        }}
                }
                ColumnLayout {
                    Text {
                        id: text_dn
                        //anchors.centerIn: parent
                        font.pointSize: 12
                        color: "white"
                    }
                    Text {
                        id: text_content
                        //anchors.centerIn: parent
                        font.pointSize: 12
                        color: "white"
                    }

                }
            }
            onOpened: popup_mss_close.start()
        }
        Timer {
            id: popup_mss_close
            interval: 2000
            onTriggered: popup_msg.close()
        }

        // Popup will be closed automatically in 2 seconds after its opened


    StackView {
        anchors.fill: parent
        id: stack
        initialItem: Qt.resolvedUrl("login.qml")
        focus: true
    }
    Component.onCompleted: {
        db = LocalStorage.openDatabaseSync("LoginDB1", "1.0", "Example!", 1000000);
        db.transaction(
                    function(tx) {
                        tx.executeSql('CREATE TABLE IF NOT EXISTS user(name TEXT, surname TEXT, login TEXT, password TEXT, path_to_image TEXT)');
                    })
    }

    function delay(delayTime, cb) {
        let timer = Qt.createQmlObject("import QtQuick 2.0; Timer {}", mainWindow)
        timer.interval = delayTime;
        timer.repeat = false;
        timer.triggered.connect(cb);
        timer.start();
    }
}
