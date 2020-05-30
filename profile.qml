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
    }

    ColumnLayout {
        //  anchors.top: row_.bottom
        width: parent.width
        spacing: profilePage.height / 100
        Item {
            id: top_
            height: parent.height / 50
            width: parent.width
        }

        Image {
            id: img
            Layout.alignment: Qt.AlignHCenter
            source: "data:image/png;base64," + profileImageBase64
            Layout.preferredWidth: profilePage.width*0.3
            Layout.preferredHeight: profilePage.width*0.3

        }
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: profilePage.height/18
            Layout.preferredWidth: profilePage.width/4
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: currentUserDN
            color: "#6fda9c"
            font.pointSize: 14
        }

        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: profilePage.height/18
            Layout.preferredWidth: profilePage.width/4
            visible: true
        }
        Button {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: 200
            Layout.preferredHeight: profilePage.height/10
            Layout.preferredWidth: profilePage.width/2
            contentItem: Text {
                text: qsTr("    Изменить имя      ")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 20
                minimumPointSize: 10
                fontSizeMode: Text.Fit
                color: "#f0f0f0"
            }

            background: Rectangle {
                radius: 20
                color: "#6fda9c"
            }
        }
        Button {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: 200
            Layout.preferredHeight: profilePage.height/10
            Layout.preferredWidth: profilePage.width/2
            contentItem: Text {
                text: qsTr("    Изменить фото      ")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 20
                minimumPointSize: 10
                fontSizeMode: Text.Fit
                color: "#f0f0f0"
            }

            background: Rectangle {
                radius: 20
                color: "#6fda9c"
            }
        }
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: 200
            Layout.preferredHeight: profilePage.height/10
            Layout.preferredWidth: profilePage.width/2
        }

    }
}
