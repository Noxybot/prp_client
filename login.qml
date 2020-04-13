import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12

Page {
    id: mainWindow
    anchors.fill: parent
    ColumnLayout {
       anchors.fill: parent
       Layout.alignment: Qt.AlignHCenter
     Rectangle {
          Layout.alignment: Qt.AlignHCenter
          Layout.preferredWidth: mainWindow.width * 0.3
          Layout.preferredHeight: mainWindow.width * 0.3
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("\u36BE")
                    font.pointSize: parent.width * 0.75
                    fontSizeMode: Text.Fit
                    anchors.centerIn: parent
            }
        }
        TextField {
            id: login_
            Layout.alignment: Qt.AlignHCenter
            placeholderText: qsTr("Логин")
            Layout.preferredWidth: mainWindow.width / 2
        }
        TextField {
            id: password
            Layout.alignment: Qt.AlignHCenter
            placeholderText: qsTr("Пароль")
            Layout.preferredWidth: mainWindow.width / 2
        }
        Button {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Войти")
            Layout.preferredHeight: mainWindow.height / 10
            Layout.preferredWidth: mainWindow.width / 4
            onClicked: {
                console.log("Login")
                if (confirmLogin(login_.text, password.text) === true) {
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
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Зарегистрироваться")
            Layout.preferredHeight: mainWindow.height / 10
            Layout.preferredWidth: mainWindow.width / 4
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
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Войти с Facebook")
            font.underline: true
            onClicked: {
                console.log("FB")
            }
            Layout.preferredWidth: mainWindow.width / 4
            background: Rectangle {
                color: "white"
            }
        }
    }
}
