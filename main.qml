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
        db = LocalStorage.openDatabaseSync("LoginDB", "1.0", "Example!", 1000000);
        db.transaction(
                    function(tx) {
                        tx.executeSql('CREATE TABLE IF NOT EXISTS user(name TEXT, surname TEXT, login TEXT, password TEXT, path_to_image TEXT)');
                    })
    }

    function addUser(name, surname, login, password, path_to_image) {
//        db.transaction(function(tx) {
//                    var results = tx.executeSql('SELECT password FROM user WHERE name=?;', name);
//                    if(results.rows.length !== 0)
//                    {
//                        console.log("User already exist!")
//                        return
//                    }
//                    //console.log("BLOB SIZE: " + image.size)
//                    tx.executeSql('INSERT INTO user VALUES(?, ?, ?, ?, ?)', [ name, surname, login, password, path_to_image]);
//                    console.log("Done")
//                })
        var xhr = new XMLHttpRequest();
        //let request =
        xhr.open("POST", "http://localhost:1337", true)
        xhr.setRequestHeader("Content-type", "application/json")
        xhr.onreadystatechange = function () {
                       if (xhr.readyState === 4 && xhr.status === 200) {

                           // Print received data from server
                           result.innerHTML = this.responseText;

                       }
                   };

        xhr.send(JSON.stringify({"method": "register_user", "login": login, "password": password, "display_name": name +  surname}));
        console.log("SENEDE")

    }

    function confirmLogin(login, password) {
        var ret = false
//        db.transaction(function(tx) {
//                    var results = tx.executeSql('SELECT password FROM user WHERE login=?;', login);
//                    if(results.rows.length === 1 && results.rows.item(0).password === password)
//                    {
//                        console.log("Correct!")
//                        ret = true
//                    }
//                })

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
