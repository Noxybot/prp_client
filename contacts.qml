import QtQuick 2.0
import QtQuick.Controls 2.12

Page {
    visible: true
    header: ToolBar {
        ToolButton {
            id: backButton
            onClicked: {
                stack.pop()
            }

            Text {
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
            text: qsTr("Чаты")
            anchors.centerIn: parent
        }

    }
ListView {
            id: listView
            anchors.fill: parent
            topMargin: 48
            leftMargin: 48
            bottomMargin: 48
            rightMargin: 48
            spacing: 20
            model: contactModel
            delegate: ItemDelegate {
                text: name
                property string imageBase64: fetchImageByLogin(name)
                width: listView.width - listView.leftMargin - listView.rightMargin
                height: avatar.implicitHeight
                leftPadding: avatar.implicitWidth + 32
                onClicked: {conversationModel.setRecipient(name); stack.push("chat.qml", {"inConversationWith" : name, "imageBase64": imageBase64}) }
                Image {
                    visible: true
                    width: 40
                    height: 40
                    id: avatar
                    source: "data:image/png;base64," + imageBase64
                }
            }
        }
}
