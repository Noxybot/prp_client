import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12

Page {
    id: markerDescriptionPage
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
            text: qsTr("Информация о точке")
            anchors.centerIn: parent
        }


    }
    ColumnLayout {
        width: parent.width
        spacing: parent.height/50
        TextField {
            id: name
            Layout.maximumWidth: 300
            Layout.alignment: Qt.AlignHCenter
            placeholderText: qsTr("Название")
            Layout.preferredWidth: markerDescriptionPage.width / 1.5
        }
        Text {
            id: name_error
            text: qsTr("Это поле не должно быть пустым")
            color: "#c22d23"
            font.pointSize: 10
            Layout.alignment: Qt.AlignHCenter
            visible: false
        }
        ComboBox {
            id: type
            Layout.maximumWidth: 300
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: markerDescriptionPage.width / 1.5
            model: ["Спорт", "Культурный отдых", "Ночная жизнь", "Развлечения"]
            onCurrentIndexChanged:
            {
                switch(type.currentIndex)
                {
                case 0:
                    subtype.model = ["Велоспорт", "Футбол", "Бег", "Баскетбол", "Спортзал"];
                    break;
                case 1:
                    subtype.model = ["Галерея", "Экскурсия", "Театр", "Кинотеатр"];
                    break;
                case 2:
                    subtype.model = ["Бар", "Ресторан", "Клуб", "Кальян"];
                    break;
                case 3:
                    subtype.model = ["Цирк", "Парк развлечений", "Концерт", "Развлекательный центр", "Квест", "Лазертаг\Пейнтбол", "Зоопарк"];
                    break;
                }
            }
        }
        ComboBox {
            id: subtype
            Layout.maximumWidth: 300
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: markerDescriptionPage.width / 1.5
            model: ["Велоспорт", "Футбол", "Бег", "Баскетбол", "Спортзал"]
        }

        TextArea {
            id: description_
            leftPadding: 20
            rightPadding: 20
            Layout.maximumWidth: 300
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: markerDescriptionPage.width / 1.5
            wrapMode: TextEdit.Wrap
            Layout.maximumHeight: 100
            Layout.preferredHeight: markerDescriptionPage.height / 5
            background: Rectangle
            {
                radius: 20
                border.color: "#6fda9c"
                color: "#394454"
            }

            placeholderText: "Опишите свое мероприятие"
        }
        Button {
            Layout.maximumWidth: 200
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: markerDescriptionPage.height / 10
            Layout.preferredWidth: markerDescriptionPage.width / 2
            contentItem: Text {
                text: qsTr("          Далее          ")
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
            onClicked: {
                if(validateName()) {
                    stack.push("timePicker.qml", {"name":name.text,
                                   "type":type.currentText, "subtype":subtype.currentText,
                                   "description":description_.text, "coordinates":coordinates})
                }
            }
        }

        Button {
            text: qsTr("Отмена")
            onClicked: {
                stack.pop()
            }
            Layout.alignment: Qt.AlignHCenter
            contentItem: Text {
                text: qsTr("          Отмена          ")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 20
                minimumPointSize: 10
                fontSizeMode: Text.Fit
                color: "#f0f0f0"
            }
            Layout.maximumWidth: 200
            Layout.preferredHeight: markerDescriptionPage.height / 10
            Layout.preferredWidth: markerDescriptionPage.width / 2
            background: Rectangle {
                radius: 20
                color: "#6fda9c"
            }
        }
    }
    function validateName() {
        if(name.text.length == 0)
        {
            name_error.visible = true
            return false;
        }
        else
        {
            name_error.visible = false
            return true;
        }
    }
}
