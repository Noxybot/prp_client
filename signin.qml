import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12

Page {
    id: mainWindow
    header: ToolBar {
        ToolButton {
            id: backButton
            onClicked: {
                stack.pop()
            }

            Text {
                id: menuButtonName
                text: qsTr("\u2190")
                width: parent.width * 0.7
                height: parent.height * 0.7
                font.pointSize: 100
                minimumPointSize: 10
                fontSizeMode: Text.Fit
                anchors.centerIn: parent
            }
        }

        Label {
            text: qsTr("Регистрация")
            anchors.centerIn: parent
        }

    }
    Column {
        topPadding: mainWindow.height / 50
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: mainWindow.height / 50
        TextField {
            id: name
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: qsTr("Имя")
            width: mainWindow.width/2
        }
        TextField {
            id: surname
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: qsTr("Фамилия")
            width: mainWindow.width / 2
        }
        TextField {
            id: login_
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: qsTr("Логин")
            width: mainWindow.width / 2
        }
        TextField {
            id: password
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: qsTr("Пароль")
            width: mainWindow.width / 2
        }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Зарегистрироваться")
            height: mainWindow.height / 10
            width: mainWindow.width / 4
            onClicked: {
                console.log("Registration")
                addUser(name.text, surname.text, login_.text, password.text)
                stack.push("map.qml")
            }
            background: Rectangle {
                radius: 20
                color: "light grey"
            }
        }
    }
}
