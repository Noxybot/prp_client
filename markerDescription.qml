import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12

Page {
    id: loginPage
    property var coordinates;
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
        RowLayout
        {
            Layout.alignment: Qt.AlignHCenter
            Text {
                id: time
                text: qsTr("Время")
            }
            TextField {
                id: from
                placeholderText: "С"
            }
            TextField {
                id: to
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
        TextArea {
            id: description_
            Layout.maximumWidth: 300
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: loginPage.width / 1.5
            //lineCount: 6
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
            text: qsTr("Фото")
            onClicked: {
                stack.push("camera.qml")
            }
        }
        Button {
            Layout.maximumWidth: 200
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: loginPage.width / 1.5
            text: qsTr("Сохранить")
            onClicked: {
                markerModel.addMarker(coordinates, 1)
                stack.pop()
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
