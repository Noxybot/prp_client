import QtQuick 2.0
import QtQuick.Controls 2.12

Page {
//    WorkerScript {
//            id: fetcher
//            source: "imageFetcher.js"
//            onMessage: {
//                let login = messageObject.login
//                console.log("imageFetcher succeed, login: " + login);
//                contactModel.addUserImage(login, messageObject.image)
//            }
//    }


//    StackView.onActivated: {
//        let contacts_without_img = contactModel.getContactsWithoutAvatar()
//        console.log("contacts_without_img size is: " + contacts_without_img.length)
//        for (let i = 0; i < contacts_without_img.length; ++i){
//            fetcher.sendMessage({"login": contacts_without_img[i], "serverIP": serverIP})
//        }
//    }

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
                leftPadding: contact_img.width + 32
                onClicked: {conversationModel.setRecipient(login);
                    stack.push("chat.qml",
                           {"inConversationWith" : login, "inConversationWithDN": display_name}) }
                Image {
                    asynchronous: true
                    id: contact_img
                    MouseArea {
                        anchors.fill: parent;
                        onClicked:  {
                            stack.push("profile.qml", {"login": login, "display_name": display_name})
                        }
                    }
                    BusyIndicator {
                        anchors.centerIn: parent
                        running: contact_img.status !== Image.Ready
                    }
                    visible: true
                    width: 40
                    height: 40
                    sourceSize.width: 40
                    sourceSize.height: 40
                    source: "image://contact_image_provider/" + login
                    onStatusChanged: {
                        if (contact_img.status !== Image.Ready){
                            if (contact_img.source == undefined)
                                return
                            delay(500, function(){ let old_src = contact_img.source;
                                contact_img.source = "";
                                contact_img.source = old_src})
                        }}
                }
            }
        }
}

