import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12

Page {
    id: profilePage
    visible: true
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
                text: qsTr("\u2661")
                width: parent.width * 0.7
                height: parent.height * 0.7
                font.pointSize: 100
                minimumPointSize: 10
                fontSizeMode: Text.Fit
                anchors.centerIn: parent
            }
        }
    }
    Item {
        id: top_
        height: parent.height / 50
        width: parent.width
    }

    ColumnLayout {
      //  anchors.top: row_.bottom
        width: parent.width
        spacing: profilePage.height / 100
            Image {
                id: img
                Layout.alignment: Qt.AlignHCenter
                source: "data:image/png;base64," + profileImageBase64
                Layout.preferredWidth: profilePage.width*0.3
                Layout.preferredHeight: profilePage.width*0.3
                sourceSize.width: profilePage.width*0.3
                sourceSize.height: profilePage.width*0.3
                //fillMode: Image.PreserveAspectCrop
//                layer.enabled: true
//                layer.effect: OpacityMask {
//                    maskSource: mask
//                }
            }

//            Rectangle {
//                id: mask
//                Layout.preferredWidth: profilePage.width*0.3
//                Layout.preferredHeight: profilePage.width*0.3
//                radius: width*0.5
//                visible: false

//            }


        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: profilePage.height/18
            Layout.preferredWidth: profilePage.width/4
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: currentUserDN
        }

        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: profilePage.height/18
            Layout.preferredWidth: profilePage.width/4
            visible: true
        }
        Button {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Изменить имя")
            Layout.maximumWidth: 200
            Layout.preferredHeight: profilePage.height/10
            Layout.preferredWidth: profilePage.width/2
        }
        Button {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Изменить фото")
            Layout.maximumWidth: 200
            Layout.preferredHeight: profilePage.height/10
            Layout.preferredWidth: profilePage.width/2
        }
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: 200
            Layout.preferredHeight: profilePage.height/10
            Layout.preferredWidth: profilePage.width/2
        }

    }
}
