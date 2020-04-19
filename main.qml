import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtQuick.LocalStorage 2.0


ApplicationWindow {
    id: mainWindow
    visible: true
    title: qsTr("Come together")
    minimumWidth: Screen.width/1.5; minimumHeight: Screen.height/1.5
    property var db
    property string currentUserLogin: ""
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

    function addUser(name, surname, login, password, path_to_image, isFB) {
       db.transaction(function(tx) {
                   let results = tx.executeSql('SELECT password FROM user WHERE name=?;', name);
                   if(results.rows.length !== 0)
                   {
                       console.log("User already exist!")
                       //return //no need to to return - just do not try to INSERT a user
                   }
                   else
                       tx.executeSql('INSERT INTO user VALUES(?, ?, ?, ?, ?)', [name, surname, login, password, path_to_image]);
                       console.log("Done")
               })

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
        xhr.open("POST", "http://192.168.0.105:1337", false)
        xhr.setRequestHeader("Content-type", "application/json")

        let json_request = {"method": "register_user", "login": login, "password": password, "display_name": name + ' ' + surname}
        if (isFB)
            json_request["method"] = "login_fb_user" //todo: write it better

        try {
            xhr.send(JSON.stringify(json_request));
            if (xhr.status !== 201 && xhr.status !== 200) //HTTP Created or 200 OK for case FB user login
                alert("Registration error ${xhr.status}: ${xhr.statusText}")
            else
            {
                ret = true
                mainWindow.currentUserLogin = login
            }
        } catch(err) {
            alert("Registration request failed: " + err.prototype.message)
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
//        db.transaction(function(tx) {
//                    var results = tx.executeSql('SELECT password FROM user WHERE login=?;', login);
//                    if(results.rows.length === 1 && results.rows.item(0).password === password)
//                    {
//                        console.log("Correct!")
//                        ret = true
//                    }
//                })

        let ret = false
        if (login.length < 4 || password.length < 6)
            return ret
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://192.168.0.105:1337", false)
        xhr.setRequestHeader("Content-type", "application/json")
        let json_request = {"method": "login_user", "login": login, "password": password}
        try {
            xhr.send(JSON.stringify(json_request));
            if (xhr.status !== 200) //HTTP OK
                alert("Login error ${xhr.status}: ${xhr.statusText}")
            else
                ret = true;
        } catch(err) {
            alert("Login request failed: " + err.prototype.message)
          }
        return ret
    }

    function getUserInfoByLogin(login) {
        let userInfo = { }
        console.log(login)
        db.transaction(function(tx) {
                    var results = tx.executeSql('SELECT * FROM user WHERE login=?;', login);
                    if(results.rows.length === 1)
                    {
                        console.log("Correct!")
                        userInfo["displayName"] = results.rows.item(0).name + " " + results.rows.item(0).surname
                        userInfo["pathToImage"] = results.rows.item(0).path_to_image
                    }
                })
        console.log(userInfo["displayName"] + " " + userInfo["pathToImage"])
        return userInfo
    }
}
