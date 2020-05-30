import QtQuick 2.5
import QtMultimedia 5.6
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12

Page {
    id : cameraUI
    background: Rectangle {color: "black"; anchors.fill: parent }
    state: "PhotoCapture"
    property var coordinates;
    property string imageBase64_ : "";
    property int create_marker_status: -1
    property string create_marker_id: ""
    property string last_image_path: ""
    property string name;
    property string type;
    property string subtype;
    property string description;
    property string from_time;
    property string to_time;
    property string peopleCount;
    property string expenses;
    states: [
        State {
            name: "PhotoCapture"
            StateChangeScript {
                script: {
                    camera.captureMode = Camera.CaptureStillImage
                    camera.start()
                }
            }
        },
        State {
            name: "PhotoPreview"
        }
    ]

    Camera {
        id: camera
        captureMode: Camera.CaptureStillImage

        imageCapture {
            onImageCaptured: {
                photoPreview.source = preview
                cameraUI.state = "PhotoPreview"
            }
            onImageSaved: { last_image_path = path }
        }
    }

    Item {
        property alias source : preview.source
        signal closed

        id : photoPreview
        anchors.fill : parent
        onClosed: cameraUI.state = "PhotoCapture"
        visible: cameraUI.state == "PhotoPreview"
        focus: visible

        Image {
            id: preview
            anchors.fill : parent
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
    }

    VideoOutput {
        id: viewfinder
        visible: cameraUI.state == "PhotoCapture"

        x: 0
        y: 0
        width: parent.width
        height: parent.height

        source: camera
        autoOrientation: true
    }
    Button
    {
        id: back_button
        y: 422
        text: qsTr("Назад")
        onClicked: stack.pop();
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 39
    }

    Button {
        id: position_button
        x: 461
        width: 143
        anchors.top: back_button.bottom
        text: qsTr("Поменять камеру")
        anchors.topMargin: -48
        onClicked: camera.position === Camera.BackFace ? camera.position = Camera.FrontFace : camera.position = Camera.BackFace
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 36
    }
    RoundButton {
        id: take_photo_button
        width: 117
        anchors.top: position_button.bottom
        anchors.topMargin: -48
        onClicked:
        {
            back_button.visible = false
            position_button.visible = false
            visible = false
            ok_button.visible = true
            new_photo_button.visible = true
            camera.imageCapture.capture();
        }
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter

    }
    Button {
        id: ok_button
        visible: false
        text: qsTr("Ок")
        onClicked:
        {
            function get_milliseconds_from_hours(time_str) {
                let date_obj = new Date()
                let time_splited = time_str.split(':')
                date_obj.setHours(parseInt(time_splited[0]), parseInt(time_splited[1]))
                return date_obj.getTime()
            }

            load.visible = true
            let add_place_request = {}
            add_place_request["method"] = "add_place"
            add_place_request["latitude"] = coordinates.latitude
            add_place_request["longitude"] = coordinates.longitude
            add_place_request["creator_login"] = mainWindow.currentUserLogin
            add_place_request["name"] = name
            add_place_request["category"] = type
            add_place_request["subcategory"] = subtype
            add_place_request["from_time"] = get_milliseconds_from_hours(from_time)
            add_place_request["to_time"] = get_milliseconds_from_hours(to_time)
            add_place_request["expected_people_number"] = peopleCount
            add_place_request["expected_expenses"] = expenses
            add_place_request["description"] = description
            add_place_request["creation_time"] = Date.now()

            var xhr = new XMLHttpRequest();
            xhr.responseType = 'json'
            xhr.open("POST", "http://" + serverIP, false)
            xhr.setRequestHeader("Content-type", "application/json")


            try {
                xhr.send(JSON.stringify(add_place_request));
                create_marker_status = xhr.status;
                create_marker_id = xhr.response["result"] //result of the response is a marker id
                load.visible = false
                imageConverter.scheduleToBase64(create_marker_id, last_image_path, "convert marker image")

            } catch(err) {
                console.log("add_place request failed: " + err.message)
            }

            stack.pop()
            stack.pop()
            stack.pop()
        }
    }
    Button {
        id: new_photo_button
        visible: false
        anchors.top: ok_button.bottom
        text: qsTr("Новое фото")
        onClicked:
        {
            ok_button.visible = false
            visible = false
            back_button.visible = true
            position_button.visible = true
            take_photo_button.visible = true
            cameraUI.state = "PhotoCapture"
            imageConverter.removeFile(last_image_path)
        }
    }
}


/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
