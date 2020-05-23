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
                stack.push("timePicker.qml")
            }
        }
        Button {
            Layout.maximumWidth: 200
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: loginPage.width / 1.5
            text: qsTr("Сохранить")
            onClicked: {
                function get_milliseconds_from_hours(time_str) {
                    let date_obj = new Date()
                    let time_splited = time_str.split(':')
                    date_obj.setHours(parseInt(time_splited[0]), parseInt(time_splited[1]))
                    return date_obj.getTime()
                }

                let add_place_request = {}
                add_place_request["method"] = "add_place"
                add_place_request["latitude"] = coordinates.latitude
                add_place_request["longitude"] = coordinates.longitude
                add_place_request["creator_login"] = mainWindow.currentUserLogin
                add_place_request["name"] = name.text
                add_place_request["category"] = type.currentText
                add_place_request["subcategory"] = subtype.currentText
                add_place_request["from_time"] = get_milliseconds_from_hours(from_time.text)
                add_place_request["to_time"] = get_milliseconds_from_hours(to_time.text)
                add_place_request["expected_people_number"] = peopleCount.currentText
                add_place_request["expected_expenses"] = expenses.currentText
                add_place_request["description"] = description_.text
                add_place_request["creation_time"] = Date.now()

                var xhr = new XMLHttpRequest();
                xhr.responseType = 'json'
                xhr.open("POST", "http://" + serverIP, false)
                xhr.setRequestHeader("Content-type", "application/json")


                try {
                    xhr.send(JSON.stringify(add_place_request));
                    if (xhr.status !== 200) //HTTP 200 OK means place added
                        console.log("Registration error ${xhr.status}: ${xhr.statusText}")
                    else {
                         let response = xhr.response;
                         let xhr1 = new XMLHttpRequest();
                         xhr1.responseType = 'json'
                         xhr1.open("POST", "http://" + serverIP, true)
                         xhr1.setRequestHeader("Content-type", "application/json")
                         let upload_place_image_request = {}
                         upload_place_image_request["method"] = "upload_marker_image"
                         upload_place_image_request["id"] = response["result"] //result of the response is a marker id
                         console.log("img size: " + imageBase64.length)
                         upload_place_image_request["image"] = imageBase64
                         xhr1.onready = function(){
                             console.log("image for marker sent")
                         }
                         xhr1.send(JSON.stringify(upload_place_image_request))
                    }
                } catch(err) {
                    console.log("add_place request failed: " + err.message)
                  }


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
