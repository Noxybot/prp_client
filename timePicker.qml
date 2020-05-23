import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12

Page {
    id: loginPage
    property var coordinates;
    property string imageBase64 : "";
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
            text: qsTr("Выбор времени и даты")
            anchors.centerIn: parent
        }

        ToolButton {
            id: likeButton
            anchors.right: parent.right
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
    ColumnLayout {
        width: parent.width
        spacing: parent.height/50
        RowLayout
        {
            Layout.alignment: Qt.AlignHCenter
            Text {
                id: time
                text: qsTr("Время")
            }

            TextField {
                id: to_time
                placeholderText: "До"
            }
        }

        ComboBox {
            id: peopleCount
            Layout.maximumWidth: 300
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: loginPage.width / 1.5
            model: ["Ожидаемое количество участников", "1 - 3", "4 - 6", "7 - 10", "11 - 20", "21 - 30"]
        }
        ComboBox {
            id: expenses
            Layout.maximumWidth: 300
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: loginPage.width / 1.5
            model: ["Ожидаемы траты с человека", "0 - 100", "100 - 200", "200 - 500", "500 - 1000", "1000 - 5000"]
        }
        Button {
            Layout.maximumWidth: 200
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: loginPage.width / 1.5
            text: qsTr("Фото")
            onClicked: {
                stack.push("camera.qml")
            }
        }
    }
}
