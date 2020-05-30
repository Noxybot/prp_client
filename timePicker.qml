import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12

Page {
    id: timePickerPage
    property var coordinates;
    property string imageBase64 : "";
    property string name;
    property string type;
    property string subtype;
    property string description;
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
            text: qsTr("Выбор времени и даты")
            anchors.centerIn: parent
        }
    }
    function formatNumber(number) {
        return number < 10 && number >= 0 ? "0" + number : number.toString()
    }
    ColumnLayout {
        width: parent.width
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: parent.width/3
            Text {
                id: time
                Layout.alignment: Qt.AlignLeft
                text: qsTr("Начало: ")
                color: "#6fda9c"
                font.pointSize: 14
            }
            Button{
                id: today1
                property bool chosen: true
                Layout.alignment: Qt.AlignRight
                contentItem: Text {
                    text:qsTr("Сегодня")
                    color: today1.chosen ? "white" : "#9da19e"
                    font.pointSize: 20
                    minimumPointSize: 10
                    fontSizeMode: Text.Fit
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Layout.maximumWidth: 70
                Layout.preferredHeight: timePickerPage.height / 12
                onClicked: {
                    if(!today1.chosen) {
                        today1.chosen = true
                        tomorrow1.chosen = false
                        today2.enabled = true
                    }
                }
                background: Rectangle {
                    radius: 20
                    color:today1.chosen ? "#6fda9c" : "#3d6e41"
                }
            }
            Button{
                id: tomorrow1
                property bool chosen: false
                Layout.alignment: Qt.AlignRight
                contentItem: Text {
                    text:qsTr("Завтра")
                    color: tomorrow1.chosen ? "white" : "#9da19e"
                    font.pointSize: 20
                    minimumPointSize: 10
                    fontSizeMode: Text.Fit
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Layout.maximumWidth: 70
                Layout.preferredHeight: timePickerPage.height / 12
                onClicked: {
                    if(!tomorrow1.chosen) {
                        today1.chosen = false
                        tomorrow1.chosen = true
                        today2.enabled = false
                    }
                }
                background: Rectangle {
                    radius: 20
                    color:tomorrow1.chosen ? "#6fda9c" : "#3d6e41"
                }
            }
        }


        RowLayout {

            id: rowTumbler
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 20
            ComboBox {
                font.pixelSize: 24
                id: fromHour
                model: 24
                delegate: ItemDelegate {
                    text:formatNumber(index)
                }
                displayText:formatNumber(index)
            }
            Label {
                font.pixelSize: 24
                text: ':'
                Layout.alignment: Qt.AlignCenter
            }
            ComboBox {
                font.pixelSize: 24
                id: fromMinute
                model: 60
                delegate: ItemDelegate {
                    text:formatNumber(index)
                }
                displayText:formatNumber(index)
            }
        }
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: parent.width/3
            Text {
                id: time2
                Layout.alignment: Qt.AlignLeft
                text: qsTr("Конец:  ")
                color: "#6fda9c"
                font.pointSize: 14
            }
            Button{
                id: today2
                property bool chosen: true
                Layout.alignment: Qt.AlignRight
                contentItem: Text {
                    text:qsTr("Сегодня")
                    color: today1.chosen ? "white" : "#9da19e"
                    font.pointSize: 20
                    minimumPointSize: 10
                    fontSizeMode: Text.Fit
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Layout.maximumWidth: 70
                Layout.preferredHeight: timePickerPage.height / 12
                onClicked: {
                    if(!today2.chosen) {
                        today2.chosen = true
                        tomorrow2.chosen = false
                    }
                }
                background: Rectangle {
                    radius: 20
                    color:today2.chosen ? "#6fda9c" : "#3d6e41"
                }
            }
            Button{
                id: tomorrow2
                property bool chosen: false
                Layout.alignment: Qt.AlignRight
                contentItem: Text {
                    text:qsTr("Завтра")
                    color: tomorrow2.chosen ? "white" : "#9da19e"
                    font.pointSize: 20
                    minimumPointSize: 10
                    fontSizeMode: Text.Fit
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Layout.maximumWidth: 70
                Layout.preferredHeight: timePickerPage.height / 12
                onClicked: {
                    if(!tomorrow2.chosen) {
                        today2.chosen = false
                        tomorrow2.chosen = true
                    }
                }
                background: Rectangle {
                    radius: 20
                    color:tomorrow2.chosen ? "#6fda9c" : "#3d6e41"
                }
            }
        }


        RowLayout {

            id: rowTumbler2
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 20
            ComboBox {
                font.pixelSize: 24
                id: toHour
                model: 24
                delegate: ItemDelegate {
                    text:formatNumber(index)
                }
                displayText:formatNumber(index)
            }
            Label {
                font.pixelSize: 24
                text: ':'
                Layout.alignment: Qt.AlignCenter
            }
            ComboBox {
                font.pixelSize: 24
                id: toMinute
                model: 60
                delegate: ItemDelegate {
                    text:formatNumber(index)
                }
                displayText:formatNumber(index)
            }
        }
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: timePickerPage.height / 10
            Layout.preferredWidth: timePickerPage.width / 4
        }
        ComboBox {
            id: peopleCount
            Layout.maximumWidth: 300
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: timePickerPage.width / 1.5
            model: ["Ожидаемое кол-во участников", "1 - 3", "4 - 6", "7 - 10", "11 - 20", "21 - 30"]
        }
        ComboBox {
            id: expenses
            Layout.maximumWidth: 300
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: timePickerPage.width / 1.5
            model: ["Ожидаемы траты с человека", "0 - 100", "100 - 200", "200 - 500", "500 - 1000", "1000 - 5000"]
        }
        Button {
            Layout.alignment: Qt.AlignHCenter
            contentItem: Text {
                text: qsTr("         Фото         ")
                font.pointSize: 20
                minimumPointSize: 10
                fontSizeMode: Text.Fit
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }


            Layout.maximumWidth: 200
            Layout.preferredHeight: timePickerPage.height / 10
            Layout.preferredWidth: timePickerPage.width / 1.5
            onClicked: {
                if(checkTime())
                {
                    stack.push("camera.qml")/*, {"name":name,
                                   "type":type, "subtype":subtype,
                                   "description":description, "from_time" : from_time.text,
                                   "to_time": to_time.text, "peopleCount" : peopleCount.currentText,
                                   "expenses": expenses.currentText, "coordinates" : coordinates})*/
                }
            }

            background: Rectangle {
                radius: 20
                color: "#6fda9c"
            }
        }
    }

    function checkTime() {
        if(today1.chosen == true && tomorrow2.chosen == true) {
            return true;
        }
        if(fromHour.currentIndex < toHour.currentIndex) {
            return true;
        }
        if(fromHour.currentIndex == toHour.currentIndex &&
                fromMinute.currentIndex < toMinute.currentIndex)
        {
            return true;
        }
        popup.popMessage = qsTr("Время начала должно быть больше времени конца")
        popup.open()
        return false;
    }
 }
