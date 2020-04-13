import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtQuick.LocalStorage 2.0

ApplicationWindow {
    id: mainWindow
    visible: true
    title: qsTr("Come together")
    property var db
    StackView {
        anchors.fill: parent
        id: stack
        initialItem: Qt.resolvedUrl("login.qml")
    }
    Component.onCompleted: {
        db = LocalStorage.openDatabaseSync("LoginDB", "1.0", "Example!", 1000000);
        db.transaction(
                    function(tx) {
                        tx.executeSql('CREATE TABLE IF NOT EXISTS user(name TEXT, surname TEXT, login TEXT, password TEXT)');
                    })
    }

    function addUser(name, surname, login, password) {
        db.transaction(function(tx) {
                    var results = tx.executeSql('SELECT password FROM user WHERE name=?;', name);
                    if(results.rows.length !== 0)
                    {
                        console.log("User already exist!")
                        return
                    }
                    tx.executeSql('INSERT INTO user VALUES(?, ?, ?, ?)', [ name, surname, login, password]);
                    console.log("Done")
                })
    }

    function confirmLogin(login, password) {
        var ret = false
        db.transaction(function(tx) {
                    var results = tx.executeSql('SELECT password FROM user WHERE login=?;', login);
                    if(results.rows.length == 1 && results.rows.item(0).password == password)
                    {
                        console.log("Correct!")
                        ret = true
                    }
                })
        return ret
    }

}
