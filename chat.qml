import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

Page {
    visible: true
    property string inConversationWith
    property string inConversationWithDN
    //property string imageBase64_receip
    StackView.onActivated: {
        //imageBase64_receip = contactModel.getUserImageByLogin(inConversationWith)
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
            text: inConversationWithDN
            anchors.centerIn: parent
        }

        ToolButton {
            id: editButton
            anchors.right:  parent.right
            onClicked: {
            }

            Text {
                id: editButtonName
                text: qsTr("\u2630")
                width: parent.width * 0.7
                height: parent.height * 0.7
                font.pointSize: 100
                minimumPointSize: 10
                fontSizeMode: Text.Fit
                anchors.centerIn: parent
            }
        }

    }
    ColumnLayout {
        anchors.fill: parent

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: pane.leftPadding + messageField.leftPadding
            displayMarginBeginning: 40
            displayMarginEnd: 40
            verticalLayoutDirection: ListView.BottomToTop
            spacing: 12
            model: conversationModel
            delegate: Column {
                anchors.right: sentByMe && parent != null ? parent.right : undefined
                spacing: 6

                readonly property bool sentByMe: model.recipient !== "Me"

                Row {
                    id: messageRow
                    spacing: 6
                    anchors.right: sentByMe ? parent.right : undefined

                    Image {
                        width: 40
                        height: 40
                        id: avatar
                        sourceSize.width: 40
                        sourceSize.height: 40
                        source:  (!sentByMe ? "image://contact_image_provider/" + inConversationWith
                                            : "data:image/png;base64," + profileImageBase64)
                    }

                    Rectangle {
                        width: Math.min(messageText.implicitWidth + 24, listView.width - avatar.width - messageRow.spacing)
                        height: messageText.implicitHeight + 24
                        color: sentByMe ? "lightgrey" : "steelblue"

                        Label {
                            id: messageText
                            text: model.message
                            color: sentByMe ? "black" : "white"
                            anchors.fill: parent
                            anchors.margins: 12
                            wrapMode: Label.Wrap
                        }
                    }
                }

                Label {
                    id: timestampText
                    text: Qt.formatDateTime(model.timestamp, "d MMM hh:mm")
                    color: "lightgrey"
                    anchors.right: sentByMe ? parent.right : undefined
                }
            }

            ScrollBar.vertical: ScrollBar {}
        }

        Pane {
            id: pane
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                TextArea {
                    id: messageField
                    Layout.fillWidth: true
                    placeholderText: qsTr("Compose message")
                    wrapMode: TextArea.Wrap
                    Keys.onEnterPressed: {
                        if (messageField.length > 0)
                            send()
                    }
                    Keys.onReturnPressed: {
                        if (messageField.length > 0)
                            send()
                    }
                }

                Button {
                    id: sendButton
                    text: qsTr("Send")
                    enabled: messageField.length > 0
                    onClicked: {
                        send()
                    }
                }
            }
        }
    }
    function send() {
        let send_message_request = {}
        send_message_request["method"] = "send_message"
        send_message_request["from"] = currentUserLogin
        send_message_request["from_dn"] = currentUserDN
        send_message_request["to"] = inConversationWith
        send_message_request["text"] = messageField.text
        mainWebsocket.sendTextMessage(JSON.stringify(send_message_request))
        messageField.text = "";
    }
}
