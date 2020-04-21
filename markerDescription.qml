import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12

Page {
    id: loginPage
    property var coordinates;
    //property var name;
    //property var type;
    //property var description;
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
            text: qsTr("Информация о точке")
            anchors.centerIn: parent
        }

        ToolButton {
            id: likeButton
            anchors.right:  parent.right
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

        TextField {
            id: name_
        }
        TextField {
            id: type_
        }
        TextField {
            id: description_
        }
        Button {
            text: qsTr("Ок")
            onClicked: {
                //markerModel.addMarker(coordinate, name_.text)
                markerModel.addMarker(coordinates, 1)
                stack.pop()
            }
        }
    }
}
