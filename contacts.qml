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
            text: qsTr("Чаты")
            anchors.centerIn: parent
        }

    }
    Component.onCompleted: {
        contactModel.userLoggedIn.connect(
        function (login) {
            for(var child in listView.contentItem.children) {
                let item = listView.contentItem.children[child]
                if (item.delegate_login === login)
                    item.color = "green"
            }
        });
        contactModel.userLogout.connect(
        function (login)
        {
            for(var child in listView.contentItem.children) {
                let item = listView.contentItem.children[child]
                if (item.delegate_login === login)
                    item.color = "red"
            }

        });
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
                readonly property string delegate_login: login
                property alias color: cont_img_rect.border.color
                text: display_name
                width: listView.width - listView.leftMargin - listView.rightMargin
                height: 42 //avatar.implicitHeight
                leftPadding: contact_img.width + 32
                onClicked: {conversationModel.setRecipient(login);
                    stack.push("chat.qml",
                           {"inConversationWith" : login, "inConversationWithDN": display_name}) }
                Rectangle {
                    id: cont_img_rect;
                    width: 42
                    height: 42
                    visible: true
                    border.color: contactModel.isUserLoggedIn(login) ?  "green" : "red"
                    border.width: 10
                    Image {
                        //anchors.fill: parent
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
                       // Component.onCompleted:  {console.log("last msg" + )}

                        source: "image://contact_image_provider/" + login
                        onStatusChanged: {
                            if (contact_img === null || contact_img.source === undefined)
                                return
                            if (contact_img.status !== Image.Ready){
                                delay(500, function(){ let old_src = contact_img.source;
                                    contact_img.source = "";
                                    contact_img.source = old_src})
                            }}
                    }
                }
                Text {
                    id: name
                    text: last_message
                }
            }
        }
}

