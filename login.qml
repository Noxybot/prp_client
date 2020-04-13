import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

Page {
    id: mainWindow

    Column {
        topPadding: mainWindow.height/100
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: mainWindow.height/50
        Rectangle{
            anchors.horizontalCenter: parent.horizontalCenter
            width: mainWindow.width*0.3
            height: mainWindow.width*0.3
                Text{
                    text: qsTr("\u36BE")
                    font.pointSize: 100
                    minimumPointSize: 10
                    fontSizeMode: Text.Fit
                    anchors.centerIn: parent
            }

        }

        TextField {
            id: login_
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: qsTr("Логин")
            width: mainWindow.width/2
        }
        TextField {
            id: password
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: qsTr("Пароль")
            width: mainWindow.width/2
        }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Войти")
            height: mainWindow.height/10
            width: mainWindow.width/4
            onClicked: {
                console.log("Login")
                if(confirmLogin(login_.text, password.text) == true) {
                  console.log("Login complete")
                   stack.push("map.qml")
                }
                else {
                    console.log("Wrong credentials")
                }
            }
            background: Rectangle {
                radius: 20
                color: "light grey"
            }
        }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Зарегистрироваться")
            height: mainWindow.height/10
            width: mainWindow.width/4
            onClicked: {
                console.log("Registration")
                stack.push("signin.qml")
            }
            background: Rectangle {
                radius: 20
                color: "light grey"
            }
        }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Войти с Facebook")
            font.underline: true
            onClicked: {
                console.log("FB")
            }
            width: mainWindow.width/4
            background: Rectangle {
                color: "white"
            }
        }
    }
}
