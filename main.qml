import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtQuick.LocalStorage 2.0
import QtQuick.Layouts 1.12

import QtWebSockets 1.14
import QtPositioning 5.14
import Cometogether.converter 1.0
import Cometogether.downloader 1.0

ApplicationWindow {
    id: mainWindow
    visible: true
    title: qsTr("Come together")
    minimumWidth: Screen.width/1.5; minimumHeight: Screen.height/1.5
    property var db
    property string currentUserLogin: ""
    property string currentUserDN: ""
    property string serverIP: "109.87.116.179:1337"//"178.150.141.36:1337"
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
    BackendImageConverter {
        id: imageConverter
        onImageConveted_marker: {

            console.log("converted image for marker" + id + ", sending to server...")
            uploadMarkerImage(id, imageBase64)
        }

        onImageConveted_user: {
            console.log("converted image for user" + login + ", sending to server...")
            uploadImage(login, imageBase64)
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
                currentUserDN = getDisplayNameByLogin(currentUserLogin) //blocking function
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
            let json_msg = JSON.parse(message)
            let method = json_msg["method"]
            if (method === "draw_marker") {
                let id = parseInt(json_msg["id"])
                if (markerModel.containtsMarker(id)) {
//                    if (!markerModel.markerHasImage(id)){
//                        console.log("marker: " + id + " has no image, will try to obtain it")
//                        let xhr = new XMLHttpRequest();
//                        xhr.responseType = "json"
//                        xhr.open("POST", "http://" + serverIP)
//                        xhr.setRequestHeader("Content-type", "application/json")
//                        let json_request = {"method": "get_marker_image", "id": id}
//                        xhr.onload = function() {
//                            if (xhr.status === 200) {
//                                let response = xhr.response
//                                if (response["result"] !== "no image"){
//                                    console.log("get_marker_image for marker id: " + id +" success")
//                                    markerModel.addImage(id, response["result"])
//                                    //console.log("stack.currentItem.objectName = " + stack.currentItem.objectName)
//                                    if (stack.currentItem.objectName === "mapPage"){
//                                        //console.log("stack.currentItem.bottomProfile.placeId: " + stack.currentItem.bottomProfile.placeId + " id: " + id)
//                                        if (stack.currentItem.bottomProfile.placeId === id)
//                                            stack.currentItem.bottomProfile.img_source  = "data:image/png;base64," + response["result"]
//                                    }
//                                }
//                            }
//                        }
//                        xhr.send(JSON.stringify(json_request));
//                    }
                    return;
                }
                let latitude = parseFloat(json_msg["latitude"])
                let longitude = parseFloat(json_msg["longitude"])
                let creator_login = json_msg["creator_login"]
                let name = json_msg["name"]
                let category = json_msg["category"]
                let subcategory = json_msg["subcategory"]
                let from_time = json_msg["from_time"]
                let to_time = json_msg["to_time"]
                let creation_time = ""
                let expected_people_number = json_msg["expected_people_number"]
                let expected_expenses = json_msg["expected_expenses"]
                let description = json_msg["description"]
                markerModel.addMarker(QtPositioning.coordinate(latitude, longitude), creator_login, name,
                                      category, subcategory, from_time, to_time,
                                      expected_people_number, expected_expenses,
                                      description, creation_time, id);
            }
            else if (method === "send_message"){
               // console.log("onTextMessageReceived: " + message)
                let to_login = json_msg["to"] //todo: fix it
                let from_login = json_msg["from"]
                let msg_text = json_msg["text"]
                let unix_time = parseInt(json_msg["timestamp"])
                if (from_login === currentUserLogin){
                    conversationModel.sendMessage("Me", to_login, msg_text, unix_time)
                    if (!contactModel.userPresent(to_login))
                        contactModel.addContact(to_login, getDisplayNameByLogin(to_login))
                }
                else {
                    conversationModel.sendMessage(from_login, "Me", msg_text, unix_time)
                    let dn = json_msg["from_dn"]
                    if(stack.currentItem.objectName !== "chatPage" && stack.currentItem.inConversationWithDN !== dn)
                    {
                        console.log("page " + stack.currentItem.objectName)
                        console.log("name "+stack.currentItem.inConversationWithDN + " "+dn)
                        popup_msg.text = msg_text
                        popup_msg.login = from_login
                        popup_msg.dn = dn
                        popup_msg.dn_alias = dn
                        popup_msg.img = "image://contact_image_provider/" + from_login
                        popup_msg.open()
                    }


                    if (!contactModel.userPresent(from_login))
                        contactModel.addContact(from_login, dn)
                }
            }
            else if (method === "delete_marker"){
                let marker_id = parseInt(json_msg["id"])
                console.log("Deleting marker: " + marker_id)
                markerModel.removeMarker(marker_id)
            }
            else if (method === "login_user"){
                let login = json_msg["login"]
                console.log("loggin in user: " + login)
                contactModel.loginUser(login);
                //contactModel.userLoggedIn(login);
            }
            else if (method === "logout_user"){
                let login = json_msg["login"]
                console.log("logout user: " + login)
                contactModel.logoutUser(login);
                //contactModel.userLogout(login);
            }
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
    function addUser(name, surname, login, password, isFB, pathToImage) {
        console.log("addUser(), login: " + login +
                    ", pass: " + password, ", isFB: " + isFB +
                    ", DN: " + name + " " + surname + ", path: " + pathToImage)
        //for FB user pathToImage is URL from where we will download image
        if (isFB === undefined)
        {
            console.log("addUser: IsFB is undefined")
            return;
        }
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://" + serverIP)
        xhr.setRequestHeader("Content-type", "application/json")

        let json_request = {"method": "register_user", "login": login,
            "password": password, "display_name": name + ' ' + surname}
        if (isFB)
            json_request["method"] = "login_fb_user" //todo: write it better

        var timer = Qt.createQmlObject("import QtQuick 2.14; Timer {interval: 5000; repeat: false; running: true;}",mainWindow,"MyTimer");
        timer.triggered.connect(function(){
            load.visible = false
            console.log("addUser: cant connect to server");
            popup.popMessage = qsTr("Ошибка подключения к серверу")
            popup.open()
            xhr.abort();
        });

        xhr.onreadystatechange  = function(){
            if (xhr.readyState !== XMLHttpRequest.DONE) //in process
                return
            timer.stop()
            load.visible = false
            if (xhr.status === 200) {//HTTP OK

                let response = JSON.parse(xhr.response)
                let result = response["result"]
                if (result === "registered" || result === "logged in"/*when isFB is true*/){
                    console.log("addUser: setting curentuserlogin to " + login)
                    currentUserLogin = login
                    mainWebsocket.active = true
                    if (isFB)
                        downloader.downloadImage(login, pathToImage);
                    else
                        imageConverter.scheduleToBase64(login, pathToImage, "convert user image");

                    if (stack.top !== "map.qml")
                        stack.push("map.qml")
                }
                else if (result === "user exists") {
                    console.log("addUser: " + result)
                    popup.popMessage = qsTr("Логин") + " " + login + " " + qsTr("занят")
                    load.visible = false
                    popup.open()
                }
            }
            else {
                console.log("addUser error " + xhr.status + ": " +  xhr.statusText)
            }

        }
        xhr.send(JSON.stringify(json_request));
    }
    function addUserImagePath(login, path_to_image) {
        db.transaction(function(tx) {
            tx.executeSql('UPDATE user SET path_to_image=? WHERE login=?', [path_to_image, login])

        })
        console.log("addUserImagePath")
    }

    function confirmLogin(login, password) {
        console.log("confirmLogin(), login: " + login + ", pass: " + password)
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://" + serverIP)
        xhr.setRequestHeader("Content-type", "application/json")
        let json_request = {"method": "login_user", "login": login, "password": password}
        var timer = Qt.createQmlObject("import QtQuick 2.14; Timer {interval: 5000; repeat: false; running: true;}",mainWindow,"MyTimer");
        timer.triggered.connect(function(){
            load.visible = false
            console.log("cant connect to server");
            popup.popMessage = qsTr("Ошибка подключения к серверу")
            popup.open()
            xhr.abort();
        });

        xhr.onreadystatechange  = function(){
            if (xhr.readyState !== XMLHttpRequest.DONE) //in process
                return
            timer.stop()
            load.visible = false
            if (xhr.status === 200) {//HTTP OK

                let response = JSON.parse(xhr.response)
                let result = response["result"]
                if (result === "logged in"){
                    console.log("setting cuurentuserlogin to " + login)
                    currentUserLogin = login
                    mainWebsocket.active = true
                    if (stack.top !== "map.qml")
                        stack.push("map.qml")
                }
                else if (result === "not found") {
                    console.log("user not found")
                    popup.popMessage = qsTr("Пользователь не найден")
                    popup.open()
                }
                else if (result === "wrong credentials"){
                    console.log("login error " + xhr.status + ": " +  xhr.statusText)
                    popup.popMessage = qsTr("Неверный пароль")
                    popup.open()
                }
                else if (result === "already logged in"){
                    console.log("login error " + xhr.status + ": " +  xhr.statusText)
                    popup.popMessage = qsTr("Этот аккаунт используется на другом устройстве")
                    popup.open()
                }
            }
            else {
                console.log("login error " + xhr.status + ": " +  xhr.statusText)
            }

        }
        xhr.send(JSON.stringify(json_request));
    }

    function getDisplayNameByLogin(login) {
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://" + serverIP, false)
        xhr.setRequestHeader("Content-type", "application/json")
        xhr.responseType = "json"
        let json_request = {"method": "get_display_name", "login": login}
        try {
           xhr.send(JSON.stringify(json_request))
           return xhr.response["result"]
        }
        catch(err) {
            console.log("getUserInfoByLogin request failed: " + err.message)
        }
    }

    function uploadImage(login, image_base64) {
        let xhr = new XMLHttpRequest();
        xhr.responseType = "json"
        xhr.open("POST", "http://" + serverIP)
        xhr.setRequestHeader("Content-type", "application/json")
        let json_request = {"method": "upload_user_image", "login": login, "image": image_base64}
        xhr.onready = function(){
            console.log("image for user: " + login + " sent")

        }
        xhr.send(JSON.stringify(json_request));
    }

    function uploadMarkerImage(id, imageBase64){
        let xhr = new XMLHttpRequest();
        xhr.responseType = 'json'
        xhr.open("POST", "http://" + serverIP, true)
        xhr.setRequestHeader("Content-type", "application/json")
        let upload_place_image_request = {}
        upload_place_image_request["method"] = "upload_marker_image"
        upload_place_image_request["id"] = id
        console.log("uploading image for marker: " + id + ", img size: " + imageBase64.length)
        upload_place_image_request["image"] = imageBase64
        xhr.onready = function(){
            console.log("image for marker: " + id + " sent")
        }
        xhr.send(JSON.stringify(upload_place_image_request))
    }

    function delay(delayTime, cb) {
        let timer = Qt.createQmlObject("import QtQuick 2.0; Timer {}", mainWindow)
        timer.interval = delayTime;
        timer.repeat = false;
        timer.triggered.connect(cb);
        timer.start();
    }
}
