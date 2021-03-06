import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12

Page {
    id: profilePage
    property string display_name: ""
    property string login: ""
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
                text: qsTr("\uf060")
                width: parent.width * 0.7
                height: parent.height * 0.7
                font.pointSize: 100
                minimumPointSize: 10
                fontSizeMode: Text.Fit
                anchors.centerIn: parent
                font.family: "Font Awesome 5 Free Solid"
                font.bold: true
                color: "#6fda9c"
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
            source: "image://contact_image_provider/" + (!login.length ? currentUserLogin :  login)
            Layout.preferredWidth: profilePage.width*0.6
            Layout.preferredHeight: profilePage.width*0.6
            sourceSize.width: 400
            sourceSize.height: 400
            BusyIndicator {
                anchors.centerIn: parent
                running: img.status !== Image.Ready
            }
            onStatusChanged: {
                if (img === null || img.source === undefined)
                    return
                if (img.status !== Image.Ready){
                    if (img === null || img.source === undefined)
                        return
                    delay(500, function(){ let old_src = img.source;
                        img.source = "";
                        img.source = old_src})
                }}

        }
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: profilePage.height/18
            Layout.preferredWidth: profilePage.width/4
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: display_name.length ? display_name : currentUserDN
            color: "#6fda9c"
            font.pointSize: 14
        }

        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: profilePage.height/18
            Layout.preferredWidth: profilePage.width/4
            visible: true
        }
       /* Button {
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
        }*/

    }
}
