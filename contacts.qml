import QtQuick 2.0
import QtQuick.Controls 2.12
import io.qt.examples.chattutorial 1.0

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
                width: listView.width - listView.leftMargin - listView.rightMargin
                height: avatar.implicitHeight
                leftPadding: avatar.implicitWidth + 32
                onClicked: stack.push("chat.qml", {"inConversationWith" : name})
                Rectangle {
                    color: "red"
                    visible: true
                    width: 40
                    height: 40
                    implicitHeight: 40
                    implicitWidth: 40
                    id: avatar
                   // source: "qrc:/shared/" + name.replace(" ", "_") + ".png"
                }
            }
        }
}
