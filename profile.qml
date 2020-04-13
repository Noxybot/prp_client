import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12

Page {
    id: mainWindow
    visible: true
    anchors.fill: parent
    title: qsTr("Come together")

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
        topPadding: mainWindow.height / 100
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: mainWindow.height / 50
        Rectangle{
            anchors.horizontalCenter: mainWindow.horizontalCenter
            width: mainWindow.width * 0.6
            height: mainWindow.width * 0.3
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
                source: 'images/vane4ka.jpg'
                width: mainWindow.width * 0.3
                height: mainWindow.width * 0.3
                fillMode: Image.PreserveAspectCrop
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: mask
                }
            }

            Rectangle {
                id: mask
                width: mainWindow.width*0.3
                height: mainWindow.width*0.3
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
            text: qsTr("Ванечка")
        }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Изменить имя")
            height: mainWindow.height/8
            width: mainWindow.width/4
        }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Изменить фото")
            height: mainWindow.height/8
            width: mainWindow.width/4
        }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Отзывы")
            height: mainWindow.height/8
            width: mainWindow.width/4
        }
    }
}
