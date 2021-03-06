import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12
import QtWebSockets 1.14

Page {
    id: loginPage
    background: Rectangle
    {
        color: "#394454"
    }
    focus: true
    StackView.onActivated: {
        login_.focus = true;
    }
    function do_login(){
        if (login_.text.length < 4 || password.text.length < 6)
        {
            load.visible = false
            popup.popMessage = qsTr("Слишком короткий логин или пароль")
            popup.open()
            return
        }
        load.visible = true
        let res = GUIConnector.confirmLogin(login_.text, password.text)
        load.visible = false
        if (res) {
            currentUserLogin = login_.text
            if (stack.top !== "map.qml")
                stack.push("map.qml")
        }
        else {
            popup.popMessage = qsTr("Какая-то ошибка")
            popup.open()
        }
    }

    Rectangle {
        id: icon
        width: parent.width
        height: parent.height * 0.4
        color: "#394454"
        Label {
            horizontalAlignment: Text.AlignHCenter
            height: parent.height
            color: "#6fda9c"
            text: qsTr("\uf5a0")
            font {
                pointSize: 200
                family: "Font Awesome 5 Free Solid"
                bold: true
            }
            fontSizeMode: Text.Fit
            anchors.centerIn: parent
        }
    }

    ColumnLayout {
        anchors.top: icon.bottom
        width: parent.width
        spacing: parent.height/50
        focus: true
        TextField {
            id: login_
            focus: true
            Layout.maximumWidth: 300
            Layout.alignment: Qt.AlignHCenter
            placeholderText: qsTr("Логин")
            Layout.preferredWidth: loginPage.width / 1.5
            leftPadding: 10
            onAccepted: {
                password.focus = true;
                login_.focus = false;
                console.log("login enter")
            }
        }
        TextField {
            id: password
            Layout.maximumWidth: 300
            Layout.alignment: Qt.AlignHCenter
            placeholderText: qsTr("Пароль")
            Layout.preferredWidth: loginPage.width / 1.5
            echoMode: TextInput.Password
            leftPadding: 10
            onAccepted: {
                do_login()
            }
        }
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: loginPage.height / 50
            Layout.preferredWidth: loginPage.width / 4
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
                color: "#f0f0f0"
            }
            Layout.maximumWidth: 200
            Layout.preferredHeight: loginPage.height / 10
            Layout.preferredWidth: loginPage.width / 2
            onClicked: {
                do_login()
            }
            background: Rectangle {
                radius: 20
                color: "#6fda9c"
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
                height: parent.height * 0.7
                font.pointSize: 100
                fontSizeMode: Text.Fit
                color: "#f0f0f0"
            }
            onClicked: {
                load.visible = true
                console.log("Registration")
                if(stack.top !== "signin.qml")
                    stack.push("signin.qml")
            }
            background: Rectangle {
                radius: 20
                color: "#394454"
                border.color: "#6fda9c"
            }
        }
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: loginPage.height / 30
            Layout.preferredWidth: loginPage.width / 4
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Button {
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: 113
                Layout.preferredHeight: loginPage.height / 10
                Layout.preferredWidth: loginPage.width / 2
                contentItem: Text {
                    color: "#6fda9c"
                    text: "\uf082"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    height: parent.height * 0.7
                    font.pointSize: 100
                    fontSizeMode: Text.Fit
                    font.family: "Font Awesome 5 Brands Regular"
                }

                font.underline: true
                onClicked: {
                    console.log("FB")
                    if(stack.top !== "loginFB.qml")
                        stack.push("loginFB.qml")
                }
                background: Rectangle {
                    color: "#394454"
                }
            }
        }
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: loginPage.height / 100
            Layout.preferredWidth: loginPage.width / 4
        }
    }
}


