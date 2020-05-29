import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtQuick.LocalStorage 2.0

import QtWebSockets 1.14
import QtPositioning 5.14
import Cometogether.converter 1.0

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
        id: mainWebsocket
        url: "ws://" + serverIP
        onStatusChanged: {
            if (status == WebSocket.Open){
                let login_user_msg = {}
                login_user_msg["method"] = "login_user"
                login_user_msg["login"] = currentUserLogin
                mainWebsocket.sendTextMessage(JSON.stringify(login_user_msg))
                currentUserDN = getDisplayNameByLogin(currentUserLogin) //blocking function
            }
        }

        onTextMessageReceived: {
            let json_msg = JSON.parse(message)
            let method = json_msg["method"]
            if (method === "draw_marker") {
                let id = parseInt(json_msg["id"])
                if (markerModel.containtsMarker(id)) {
                    if (!markerModel.markerHasImage(id)){
                        console.log("marker: " + id + " has no image, will try to obtain it")
                        let xhr = new XMLHttpRequest();
                        xhr.responseType = "json"
                        xhr.open("POST", "http://" + serverIP)
                        xhr.setRequestHeader("Content-type", "application/json")
                        let json_request = {"method": "get_marker_image", "id": id}
                        xhr.onload = function() {
                            if (xhr.status === 200) {
                                let response = xhr.response
                                if (response["result"] !== "no image"){
                                    console.log("get_marker_image for marker id: " + id +" success")
                                    markerModel.addImage(id, response["result"])
                                    //console.log("stack.currentItem.objectName = " + stack.currentItem.objectName)
                                    if (stack.currentItem.objectName === "mapPage"){
                                        //console.log("stack.currentItem.bottomProfile.placeId: " + stack.currentItem.bottomProfile.placeId + " id: " + id)
                                        if (stack.currentItem.bottomProfile.placeId === id)
                                            stack.currentItem.bottomProfile.img_source  = "data:image/png;base64," + response["result"]
                                    }
                                }
                            }
                        }
                        xhr.send(JSON.stringify(json_request));
                    }
                    return;
                }
                let latitude = parseFloat(json_msg["latitude"])
                let longitude = parseFloat(json_msg["longitude"])
                let creator_login = json_msg["creator_login"]
                let name = json_msg["name"]
                let category = json_msg["category"]
                let subcategory = json_msg["subcategory"]
                let from_time = new Date(parseInt(json_msg["from_time"]))
                let to_time = new Date(parseInt(json_msg["to_time"]))
                let creation_time = new Date(parseInt(json_msg["creation_time"]))
                let expected_people_number = json_msg["expected_people_number"]
                let expected_expenses = json_msg["expected_expenses"]
                let description = json_msg["description"]
                markerModel.addMarker(QtPositioning.coordinate(latitude, longitude), creator_login, name,
                                      category, subcategory, from_time, to_time,
                                      expected_people_number, expected_expenses,
                                      description, creation_time, id);
            }
            else if (method === "send_message"){
                console.log("onTextMessageReceived: " + message)
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
                    if (!contactModel.userPresent(from_login))
                        contactModel.addContact(from_login, getDisplayNameByLogin(from_login))
                }
            }
            else if (method === "delete_marker"){
                let marker_id = parseInt(json_msg["id"])
                console.log("Deleting marker: " + marker_id)
                markerModel.removeMarker(marker_id)
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

        // Popup will be closed automatically in 2 seconds after its opened
        Timer {
            id: popupClose
            interval: 2000
            onTriggered: popup.close()
        }

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
    function addUser(name, surname, login, password, image_base64, isFB) {
        let ret = false
        if (isFB === undefined)
        {
            console.log("addUser: IsFB is undefined")
            return ret;
        }
        if (login.length < 4 || password.length < 6 && !isFB)
        {
            console.log("addUser: validation failed")
            return ret
        }
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://" + serverIP, false)
        xhr.setRequestHeader("Content-type", "application/json")

        let json_request = {"method": "register_user", "login": login,
            "password": password, "display_name": name + ' ' + surname, "image": image_base64}
        if (isFB)
            json_request["method"] = "login_fb_user" //todo: write it better

        try {
            xhr.send(JSON.stringify(json_request));
            if (xhr.status !== 201 && xhr.status !== 200) //HTTP Created or 200 OK for case FB user login
                console.log("Registration error " + xhr.status + " " +  xhr.statusText)
            else if (xhr.status === 409)
                console.log("conflict")
            else
            {
                console.log("Registration success " + xhr.status + " " +  xhr.statusText)
                ret = true
                mainWindow.currentUserLogin = login
            }

        } catch(err) {
            console.log("Registration request failed: " + err.message)
        }
        return ret
    }
    function addUserImagePath(login, path_to_image) {
        db.transaction(function(tx) {
            tx.executeSql('UPDATE user SET path_to_image=? WHERE login=?', [path_to_image, login])

        })
        console.log("addUserImagePath")
    }

    function confirmLogin(login, password, isFB, display_name) {
        console.log("confirmLogin")
        let ret = false
        if (login.length < 4 || password.length < 6)
        {
            load.visible = false
            popup.popMessage = qsTr("Слишком короткий логин или пароль")
            popup.open()
            return
        }
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://" + serverIP)
        xhr.setRequestHeader("Content-type", "application/json")
        let json_request = {"method": "login_user", "login": login, "password": password}
        var timer = Qt.createQmlObject("import QtQuick 2.14; Timer {interval: 5000; repeat: false; running: true;}",mainWindow,"MyTimer");
        console.log("timer " + timer)
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
                    conversationModel.setCurrentUserLogin(currentUserLogin)
                    contactModel.setCurrentUserLogin(currentUserLogin)
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
                    popup.popMessage = qsTr("Неправильный логин или пароль")
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
}
