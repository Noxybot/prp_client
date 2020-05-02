import QtQuick 2.0
import QtQuick.Controls 2.12

Page {
    WorkerScript {
            id: fetcher
            source: "imageFetcher.js"
            onMessage: {
                let login = messageObject.login
                console.log("imageFetcher succeed, login: " + login);
                contactModel.addUserImage(login, messageObject.image)
            }
    }


    StackView.onActivated: {
        let contacts_without_img = contactModel.getContactsWithoutAvatar()
        console.log("contacts_without_img size is: " + contacts_without_img.length)
        for (let i = 0; i < contacts_without_img.length; ++i){
            fetcher.sendMessage({"login": contacts_without_img[i], "serverIP": serverIP})
        }
    }

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
                text: display_name
                width: listView.width - listView.leftMargin - listView.rightMargin
                height: 40 //avatar.implicitHeight
                leftPadding: avatar.width + 32
                onClicked: {conversationModel.setRecipient(login); stack.push("chat.qml",
                           {"inConversationWith" : login, "imageBase64": image, "inConversationWithDN": display_name}) }
                Image {
                    visible: true
                    width: 40
                    height: 40
                    sourceSize.width: 40
                    sourceSize.height: 40
                    id: avatar
                    source: "data:image/png;base64," + image
                }
            }
        }
}

