import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

Page {
    visible: true
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
            text: qsTr("Диалог")
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
            delegate: Column {
                anchors.right: sentByMe ? parent.right : undefined
                spacing: 6

                readonly property bool sentByMe: model.recipient !== "Me"

                Row {
                    id: messageRow
                    spacing: 6
                    anchors.right: sentByMe ? parent.right : undefined

                    Image {
                        id: avatar
                        source: !sentByMe ? "qrc:/" + model.author.replace(" ", "_") + ".png" : ""
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
                }

                Button {
                    id: sendButton
                    text: qsTr("Send")
                    enabled: messageField.length > 0
                    onClicked: {
                        listView.model.sendMessage(inConversationWith, messageField.text);
                        messageField.text = "";
                    }
                }
            }
        }
    }
}