import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.3

Page {
    id: signinPage
    property string pathToFile
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
        topPadding: signinPage.height / 50
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: signinPage.height / 50
        TextField {
            id: name
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: qsTr("Имя")
            width: signinPage.width/2
        }
        TextField {
            id: surname
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: qsTr("Фамилия")
            width: signinPage.width / 2
        }
        TextField {
            id: login_
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: qsTr("Логин")
            width: signinPage.width / 2
        }
        TextField {
            id: password
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: qsTr("Пароль")
            width: signinPage.width / 2
        }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Зарегистрироваться")
            height: signinPage.height / 10
            width: signinPage.width / 4
            onClicked: {
                addUser(name.text, surname.text, login_.text, password.text, "")


                stack.push("map.qml")
            }
            background: Rectangle {
                radius: 20
                color: "light grey"
            }
        }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("фото")
            height: signinPage.height / 10
            width: signinPage.width / 4
            onClicked: {
                fileOpenDialog.open()
            }
            background: Rectangle {
                radius: 20
                color: "light grey"
            }
        }
    }
    FileDialog {
        id: fileOpenDialog
        title: "Select an image file"
        folder: shortcuts.documents
        nameFilters: [ "Image files (*.png *.jpeg *.jpg)" ]
        onAccepted: {
            pathToFile = fileOpenDialog.fileUrl
            console.log("Path to file: "+pathToFile)
            addUser(name.text, surname.text, login_.text, password.text, pathToFile)
            mainWindow.currentUserLogin = login_.text
            stack.push("map.qml")
        }
    }
}
