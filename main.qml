import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtQuick.LocalStorage 2.0

import QtWebSockets 1.14
import QtPositioning 5.14

ApplicationWindow {
    id: mainWindow
    visible: true
    title: qsTr("Come together")
    minimumWidth: Screen.width/1.5; minimumHeight: Screen.height/1.5
    property var db
    property string currentUserLogin: ""
    property string serverIP: "localhost:1337"//"178.150.141.36:1337"
    property string profileImageBase64: ""

    WebSocket {
        id: mainWebsocket
        url: "ws://" + serverIP
        onStatusChanged: {
            if (status == WebSocket.Open){
                let login_user_msg = {}
                login_user_msg["method"] = "login_user"
                login_user_msg["login"] = currentUserLogin
                mainWebsocket.sendTextMessage(JSON.stringify(login_user_msg))
                conversationModel.setCurrentUserLogin(currentUserLogin)
                contactModel.setCurrentUserLogin(currentUserLogin)
            }
        }

        onTextMessageReceived: {
            let json_msg = JSON.parse(message)
            let method = json_msg["method"]
            if (method === "draw_marker") {
                let id = parseInt(json_msg["id"])
                if (markerModel.containtsMarker(id))
                    return
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
                if (from_login === currentUserLogin){
                    conversationModel.sendMessage("Me", to_login, msg_text)
                    if (!contactModel.userPresent(to_login))
                        contactModel.addContact(to_login, getDisplayNameByLogin(to_login))
                }
                else {
                    conversationModel.sendMessage(from_login, "Me", msg_text)
                    if (!contactModel.userPresent(from_login))
                        contactModel.addContact(from_login, getDisplayNameByLogin(from_login))
                }
                contactModel.updateContacts()
            }
            else if (method === "delete_marker"){
                let marker_id = parseInt(json_msg["id"])
                console.log("Deleting marker: " + marker_id)
                markerModel.removeMarker(marker_id)
            }
        }
    }

    StackView {
        anchors.fill: parent
        id: stack
        initialItem: Qt.resolvedUrl("login.qml")
    }
    Component.onCompleted: {
        db = LocalStorage.openDatabaseSync("LoginDB1", "1.0", "Example!", 1000000);
        db.transaction(
                    function(tx) {
                        tx.executeSql('CREATE TABLE IF NOT EXISTS user(name TEXT, surname TEXT, login TEXT, password TEXT, path_to_image TEXT)');
                    })
    }
    function uploadImage(login, image_base64) {
        var xhr = new XMLHttpRequest();
        xhr.responseType = "json"
        xhr.open("POST", "http://" + serverIP)
        xhr.setRequestHeader("Content-type", "application/json")
        let json_request = {"method": "upload_user_image", "login": login, "image": image_base64}
        xhr.onready = function(){
            console.log("image sent")

        }

        xhr.send(JSON.stringify(json_request));
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
        let ret = false
        if (login.length < 4 || password.length < 6)
            return ret
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://" + serverIP, false)
        xhr.setRequestHeader("Content-type", "application/json")
        let json_request = {"method": "login_user", "login": login, "password": password}
        try {
            xhr.send(JSON.stringify(json_request));
            if (xhr.status === 200) {//HTTP OK

                let response = JSON.parse(xhr.response)
                let result = response["result"]
                if (result === "logged in")
                    ret = true;
                else if (result === "not found") {
                    console.log("user not found")
                }
                else {
                    console.log("login error " + xhr.status + ": " +  xhr.statusText)
                }
            }
            else {
                console.log("login error " + xhr.status + ": " +  xhr.statusText)
            }

        } catch(err) {
            console.log("confirmLogin request failed: " + err.message)
        }
        return ret
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
}
