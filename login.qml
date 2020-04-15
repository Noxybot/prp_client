import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12

Page {
    id: loginPage
    Rectangle {
        id: icon
        width: parent.width
        height: parent.height * 0.4
        Text {
            horizontalAlignment: Text.AlignHCenter
            height: parent.height
            text: qsTr("\u36BE")
            font.pointSize: 200
            fontSizeMode: Text.Fit
            anchors.centerIn: parent
        }
    }

    ColumnLayout {
        anchors.top: icon.bottom
        width: parent.width
        spacing: parent.height/50
        TextField {
            id: login_
            Layout.maximumWidth: 300
            Layout.alignment: Qt.AlignHCenter
            placeholderText: qsTr("Логин")
            Layout.preferredWidth: loginPage.width / 1.5
        }
        TextField {
            id: password
            Layout.maximumWidth: 300
            Layout.alignment: Qt.AlignHCenter
            placeholderText: qsTr("Пароль")
            Layout.preferredWidth: loginPage.width / 1.5
        }
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: loginPage.height / 50
            Layout.preferredWidth: loginPage.width / 4
            visible:true
        }
        Button {
            Layout.alignment: Qt.AlignHCenter
            contentItem: Text {
                text: qsTr("          Войти          ")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 20
                minimumPointSize: 10
                fontSizeMode: Text.Fit
            }
            Layout.maximumWidth: 200
            Layout.preferredHeight: loginPage.height / 10
            Layout.preferredWidth: loginPage.width / 2
            onClicked: {
                console.log("Login")
                if (confirmLogin(login_.text, password.text) === true) {
                    console.log("Login complete")
                    mainWindow.currentUserLogin = login_.text
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
            Layout.maximumWidth: 200
            Layout.preferredHeight: loginPage.height / 10
            Layout.preferredWidth: loginPage.width / 2
            contentItem: Text {
                id: registrerText
                text: qsTr("Зарегистрироваться")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                height: parent.height*0.7
                font.pointSize: 100
                fontSizeMode: Text.Fit
            }
            onClicked: {
                console.log("Registration")
                stack.push("signin.qml")
            }
            background: Rectangle {
                radius: 20
                color: "light grey"
            }
        }
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: loginPage.height / 30
            Layout.preferredWidth: loginPage.width / 4
            visible:true
        }

        Button {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Войти с Facebook")
            font.underline: true
            onClicked: {
                console.log("FB")
                stack.push("loginFB.qml")
            }
            Layout.preferredWidth: loginPage.width / 2
            background: Rectangle {
                color: "white"
            }
        }
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: loginPage.height / 100
            Layout.preferredWidth: loginPage.width / 4
            visible:true
        }
    }
}
