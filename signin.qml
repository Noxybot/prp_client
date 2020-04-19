import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.12

Page {
    id: signinPage
    property string pathToFile

    property var loadVisible: false
    StackView.onDeactivated: {
        loadVisible = false
    }

    Rectangle {
        id: load
        anchors.fill: parent
        color: "white"
        opacity: 0.5
        visible: loadVisible
        z: 10
        BusyIndicator {
            anchors.centerIn: parent
            running: true
        }
    }
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
    Rectangle {
        id: top_
        height: signinPage.height / 50
        width: parent.width
        visible: true
    }
    ColumnLayout {
        anchors.top: top_.bottom
        width: parent.width
        spacing: signinPage.height / 50
        TextField {
            id: name
            Layout.alignment: Qt.AlignHCenter
            placeholderText: qsTr("Имя")
            Layout.maximumWidth: 300
            Layout.preferredWidth: signinPage.width / 1.5
        }
        TextField {
            id: surname
            Layout.alignment: Qt.AlignHCenter
            placeholderText: qsTr("Фамилия")
            Layout.maximumWidth: 300
            Layout.preferredWidth: signinPage.width / 1.5
        }
        TextField {
            id: login_
            Layout.alignment: Qt.AlignHCenter
            placeholderText: qsTr("Логин")
            Layout.maximumWidth: 300
            Layout.preferredWidth: signinPage.width / 1.5
        }
        TextField {
            id: password
            Layout.alignment: Qt.AlignHCenter
            placeholderText: qsTr("Пароль")
            Layout.maximumWidth: 300
            Layout.preferredWidth: signinPage.width / 1.5
        }
        Button {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Зарегистрироваться")
            Layout.maximumWidth: 200
            Layout.preferredHeight: signinPage.height / 10
            Layout.preferredWidth: signinPage.width / 2
            onClicked: {
                loadVisible = true
                if (addUser(name.text, surname.text, login_.text, password.text, "", false) && stack.top !== "map.qml")
                {
                    console.log("adduser returned true")
                    stack.push("map.qml")
                }

                else
                    console.log ("user was not registered") // todo: popup

            }
            background: Rectangle {
                radius: 20
                color: "light grey"
            }
        }
        Button {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Фото")
            Layout.maximumWidth: 200
            Layout.preferredHeight: signinPage.height / 10
            Layout.preferredWidth: signinPage.width / 2
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
        folder: shortcuts.pictures
        nameFilters: [ "Image files (*.png *.jpeg *.jpg)" ]
        onAccepted: {
            pathToFile = fileOpenDialog.fileUrl
                console.log("Path to file: "+pathToFile)
                addUser(name.text, surname.text, login_.text, password.text, pathToFile)
            mainWindow.currentUserLogin = login_.text
            if(stack.top !== "map.qml")
                stack.push("map.qml")
        }
    }
}
