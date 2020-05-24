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
            text: qsTr("Информация о точке")
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
        TextField {
            id: name
            Layout.maximumWidth: 300
            Layout.alignment: Qt.AlignHCenter
            placeholderText: qsTr("Название")
            Layout.preferredWidth: loginPage.width / 1.5
        }
        ComboBox {
            id: type
            Layout.maximumWidth: 300
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: loginPage.width / 1.5
            model: ["Спорт", "Культурный отдых", "Ночная жизнь", "Развлечения"]
            onCurrentIndexChanged:
            {
                switch(type.currentIndex)
                {
                case 0:
                    subtype.model = ["Велоспорт", "Футбол", "Бег", "Баскетбол", "Спортзал"];
                    break;
                case 1:
                    subtype.model = ["Музей", "Галерея", "Экскурсия", "Театр", "Кинотеатр"];
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
            Layout.preferredWidth: loginPage.width / 1.5
            model: ["Велоспорт", "Футбол", "Бег", "Баскетбол", "Спортзал"]
        }

        TextArea {
            id: description_
            Layout.maximumWidth: 300
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: loginPage.width / 1.5
            Layout.maximumHeight: 50
            Layout.preferredHeight: loginPage.height / 6
            background: Rectangle
            {
                border.color: "black"
            }

            placeholderText: "Опишите свое мероприятие"
        }
        Button {
            Layout.maximumWidth: 200
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: loginPage.width / 1.5
            text: qsTr("Далее")
            onClicked: {
                stack.push("timePicker.qml", {"name":name.text,
                               "type":type.currentText, "subtype":subtype.currentText,
                               "description":description_.text, "coordinates":coordinates})
            }
        }

        Button {
            Layout.maximumWidth: 200
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: loginPage.width / 1.5
            text: qsTr("Отмена")
            onClicked: {
                stack.pop()
            }
        }
    }
}
