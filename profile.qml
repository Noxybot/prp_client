import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12

Page {
    id: profilePage
    visible: true
    anchors.fill: parent
    title: qsTr("Come together")
    property var userInfo
    Component.onCompleted: {
        userInfo = getUserInfoByLogin(mainWindow.currentUserLogin)
    }

    header: ToolBar {
        ToolButton {
            id: menuButton
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
            text: qsTr("Профиль")
            anchors.centerIn: parent
        }

        ToolButton {
            id: likeButton
            anchors.right:  parent.right
            onClicked: {
            }

            Text {
                id: likeButtonName
                text: qsTr("\u2665")
                width: parent.width * 0.7
                height: parent.height * 0.7
                font.pointSize: 100
                minimumPointSize: 10
                fontSizeMode: Text.Fit
                anchors.centerIn: parent
            }
        }
    }

    Column {
        //Layout.alignment: Qt.AlignHCenter
        topPadding: profilePage.height / 100
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: profilePage.height / 50
        Rectangle{
            anchors.horizontalCenter: profilePage.horizontalCenter
            width: profilePage.width * 0.6
            height: profilePage.width * 0.3
            Rectangle {
                id: call2
                width: parent.width * 0.2
                height: parent.width * 0.2
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                Text{
                    text: qsTr("\u2706")
                    font.pointSize: 100
                    minimumPointSize: 10
                    fontSizeMode: Text.Fit
                    anchors.fill: call2
                }
            }
            Image {
                id: img
                anchors.centerIn: parent
                source: userInfo["pathToImage"]
                width: profilePage.width * 0.3
                height: profilePage.width * 0.3
                fillMode: Image.PreserveAspectCrop
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: mask
                }
            }

            Rectangle {
                id: mask
                width: profilePage.width*0.3
                height: profilePage.width*0.3
                radius: width*0.5
                visible: false

            }
            Rectangle {
                id: call
                width: parent.width*0.2
                height: parent.width*0.2
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                Text{
                    text: qsTr("\u270E")
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pointSize: 100
                    minimumPointSize: 10
                    fontSizeMode: Text.Fit
                    anchors.fill: call
                }
            }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: userInfo["displayName"]
        }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Изменить имя")
            height: profilePage.height/8
            width: profilePage.width/4
        }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Изменить фото")
            height: profilePage.height/8
            width: profilePage.width/4
        }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Отзывы")
            height: profilePage.height/8
            width: profilePage.width/4
        }
    }
}
