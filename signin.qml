import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.12
import Cometogether.converter 1.0

Page {
    id: signinPage
    property string pathToImage

    property var loadVisible: false
    StackView.onDeactivated: {
        loadVisible = false
    }
    focus: true
    Rectangle {
        id: load
        anchors.fill: parent
        color: "white"
        opacity: 0.5
        visible: loadVisible
        z: 10
        BusyIndicator {
            anchors.centerIn: parent
            running: true
        }
    }
    header: ToolBar {
        ToolButton {
            id: backButton
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
            text: qsTr("Регистрация")
            anchors.centerIn: parent
        }

    }
    Item {
        id: top_
        height: signinPage.height / 50
        width: parent.width
    }
    ColumnLayout {
        anchors.top: top_.bottom
        width: parent.width
        focus: true
        TextField {
            id: name
            focus: true
            Layout.alignment: Qt.AlignHCenter
            placeholderText: qsTr("Имя")
            Layout.maximumWidth: 300
            Layout.preferredWidth: signinPage.width / 1.5
            onAccepted: {
                surname.focus = true;
                name.focus = false;
            }
            onTextChanged: {
                validateName()
            }
        }


        Text {
            id: name_error
            text: qsTr("Это поле не должно быть пустым")
            color: "#c22d23"
            font.pointSize: 10
            Layout.alignment: Qt.AlignHCenter
            visible: false
        }

        TextField {
            id: surname
            Layout.alignment: Qt.AlignHCenter
            placeholderText: qsTr("Фамилия")
            Layout.maximumWidth: 300
            Layout.preferredWidth: signinPage.width / 1.5
            onAccepted: {
                login_.focus = true;
                surname.focus = false;
            }
        }
        TextField {
            id: login_
            Layout.alignment: Qt.AlignHCenter
            placeholderText: qsTr("Логин")
            Layout.maximumWidth: 300
            Layout.preferredWidth: signinPage.width / 1.5
            onAccepted: {
                password.focus = true;
                login_.focus = false;
            }
            onTextChanged: {
                validateLogin()
            }
        }
        Text {
            id: login_error
            text: qsTr("Логин должен быть длиннее 4 символов")
            color: "#c22d23"
            font.pointSize: 10
            Layout.alignment: Qt.AlignHCenter
            visible: false
        }
        TextField {
            id: password
            Layout.alignment: Qt.AlignHCenter
            placeholderText: qsTr("Пароль")
            Layout.maximumWidth: 300
            echoMode: TextInput.Password
            Layout.preferredWidth: signinPage.width / 1.5
            onAccepted: {
                password.focus = false;
                password2.focus = true;
            }
            onTextChanged: {
                validatePassword()
            }
        }
        Text {
            id: password_error
            text: qsTr("Пароль должен быть длиннее 6 символов,\nсодержать цифры, большие и маленькие буквы ")
            color: "#c22d23"
            font.pointSize: 10
            Layout.alignment: Qt.AlignHCenter
            visible: false
        }
        TextField {
            id: password2
            Layout.alignment: Qt.AlignHCenter
            placeholderText: qsTr("Повторите пароль")
            Layout.maximumWidth: 300
            echoMode: TextInput.Password
            Layout.preferredWidth: signinPage.width / 1.5
            onAccepted: {
                password2.focus = false;
            }
            onTextChanged: {
                passwordsMatch()
            }
        }
        Text {
            id: password2_error
            text: qsTr("Пароли не совпадают")
            color: "#c22d23"
            font.pointSize: 10
            Layout.alignment: Qt.AlignHCenter
            visible: false
        }
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            ComboBox {
                id: day
                width: 100
                model: 31
                delegate: ItemDelegate {
                    text: index + 1
                }
                displayText: currentIndex + 1
            }
            ComboBox {
                id: month
                width: 100
                model: ["Январь", "Февраль", "Март", "Апрель",
                    "Май", "Июнь", "Июль", "Август", "Сентябрь",
                    "Октябрь", "Ноябрь", "Декабрь"]
                onCurrentIndexChanged: {
                    if(month.currentIndex == 1  &&
                            (year.currentValue%4 != 0 || year.currentValue%100 == 0)) {
                        day.model = 28
                    }
                    else if(month.currentIndex == 1  &&
                            (year.currentValue%4 == 0 && year.currentValue%100 != 0)) {
                        day.model = 29
                    }
                    else if(month.currentIndex == 3 || month.currentIndex == 5 ||
                            month.currentIndex == 8 || month.currentIndex == 11) {
                        day.model = 30
                    }
                    else {
                        day.model = 31
                    }
                }
            }
            ComboBox {
                id: year
                width: 100
                model: Array.from({ length: (2021 - 1900) / 1 + 1}, (_, i) => 1900 + i);
                currentIndex: 100
            }

        }
        CheckBox {
            id: control
            Layout.alignment: Qt.AlignHCenter
            checked: false
            text: qsTr("Я подтверждаю, что все введенные\nмною данные верны")
            indicator: Rectangle {
                implicitWidth: 22
                implicitHeight: 22
                x: control.leftPadding
                y: parent.height / 2 - height / 2
                radius: 3
                color: "transparent"
                border.color: "#6fda9c"

                Label {
                    x: 4
                    y: 5
                    text: "\uf00c"
                    color: "#6fda9c"
                    font: {
                        pointSize: 24
                        bold: true
                        weight: Font.Black
                        family: "Font Awesome 5 Free Solid"
                    }

                    visible: control.checked
                }
            }
            contentItem: Text {
                text: control.text
                font: control.font
                opacity: enabled ? 1.0 : 0.3
                color: "#6fda9c"
                verticalAlignment: Text.AlignVCenter
                leftPadding: control.indicator.width + control.spacing
            }
        }
        RowLayout{
            Layout.alignment: Qt.AlignHCenter
            Text {
                text: qsTr("Фото: ")
                color: "#6fda9c"
                font.pointSize: 14
            }

            TextField {
                id: pathToPhoto
                    enabled: false
                    Layout.maximumWidth: 300
                    Layout.preferredWidth: signinPage.width / 1.5
                    leftPadding: 10
            }
        }

        Button {
            Layout.alignment: Qt.AlignHCenter
            contentItem: Text {
                text: qsTr("       Фото       ")
                font.pointSize: 20
                minimumPointSize: 10
                fontSizeMode: Text.Fit
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }


            Layout.maximumWidth: 200
            Layout.preferredHeight: signinPage.height / 10
            Layout.preferredWidth: signinPage.width / 2
            onClicked: {
                fileOpenDialog.open()
            }
            background: Rectangle {
                radius: 20
                color: "#6fda9c"
            }
        }

        Button {
            id: sign
            enabled: control.checked ? true : false
            BackendImageConverter {
                id: imageConverter
                onImageConveted: {
                    console.log("converted image, sending to server...")
                    uploadImage(currentUserLogin, imageBase64)
                }
            }
            Layout.alignment: Qt.AlignHCenter
            contentItem: Text {
                text:qsTr("Зарегистрироваться")
                color: parent.enabled ? "white" : "#9da19e"
                font.pointSize: 20
                minimumPointSize: 10
                fontSizeMode: Text.Fit
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Layout.maximumWidth: 200
            Layout.preferredHeight: signinPage.height / 10
            Layout.preferredWidth: signinPage.width / 2
            onClicked: {
                if (checkAge()) {
                    if(validateLogin() & validateName() & validatePassword() & passwordsMatch()) {
                        loadVisible = true
                        if (addUser(name.text, surname.text, login_.text, password.text, "", false) && stack.top !== "map.qml") //pass empty img
                        {
                            imageConverter.scheduleToBase64("", pathToImage);
                            console.log("adduser returned true")
                            stack.push("map.qml")
                        }

                        else
                            console.log ("user was not registered") // todo: popup
                    }
                    else {
                        enabled: false
                    }
                }
            }
            background: Rectangle {
                radius: 20
                color:enabled ? "#6fda9c" : "#3d6e41"
            }
        }

    }

    FileDialog {
        id: fileOpenDialog
        title: "Select an image file"
        folder: shortcuts.pictures
        nameFilters: [ "Image files (*.png *.jpeg *.jpg)" ]
        onAccepted: {
            pathToImage = fileOpenDialog.fileUrl
            console.log("Path to file: " + fileOpenDialog.fileUrl + "TEST")
            pathToPhoto.text = String(fileOpenDialog.fileUrl).substring(8)
        }
    }
    function validateName() {
        if(name.text.length == 0)
        {
            name_error.visible = true
            sign.enabled = false
            return false;
        }
        else
        {
            name_error.visible = false
            sign.enabled = true
            return true;
        }
    }
    function validateLogin() {
        if(login_.text.length < 4)
        {
            login_error.visible = true
            sign.enabled = false
            return false;
        }
        else
        {
            login_error.visible = false
            sign.enabled = true
            return true;
        }
    }
    function validatePassword() {
        var strongRegex = new RegExp("^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.{6,})");
        if(!strongRegex.test(password.text))
        {
            password_error.visible = true
            sign.enabled = false
            return false;
        }
        else
        {
            password_error.visible = false
            sign.enabled = true
            return true;
        }
    }
    function passwordsMatch() {
        if(password2.text != password.text)
        {
            password2_error.visible = true
            sign.enabled = false
            return false;
        }
        else
        {
            password2_error.visible = false
            sign.enabled = true
            return true;
        }

    }
    function checkAge() {
            let birth_day = day.currentValue+1
            let birth_month = month.currentIndex+1
            let birth_year = year.currentValue
            let today_date = new Date();
            let today_year = today_date.getFullYear();
            let today_month = today_date.getMonth();
            let today_day = today_date.getDate();
            let age = today_year - birth_year;

            if ( today_month < (birth_month - 1))
            {
                age--;
            }
            if (((birth_month - 1) == today_month) && (today_day <= birth_day))
            {
                age--;
            }
            if(age < 14) {
                popup.popMessage = qsTr("Для пользования приложением необходимо достичь 14 лет")
                popup.open()
                return flase
            }
            return true
    }
}
