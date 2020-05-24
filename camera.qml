import QtQuick 2.5
import QtMultimedia 5.6
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12
import Cometogether.converter 1.0

Page {
    id : cameraUI
    background: Rectangle {color: "black"; anchors.fill: parent }
    state: "PhotoCapture"
    property var coordinates;
    property string imageBase64_ : "";
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
        text: qsTr("Назад")
        onClicked: stack.pop();
    }

    Button {
        id: position_button
        anchors.top: back_button.bottom
        text: qsTr("Поменять камеру")
        onClicked: camera.position === Camera.BackFace ? camera.position = Camera.FrontFace : camera.position = Camera.BackFace
    }
    Button {
        id: take_photo_button
        anchors.top: position_button.bottom
        text: qsTr("Сделать фото")
        onClicked:
        {
            back_button.visible = false
            position_button.visible = false
            visible = false
            ok_button.visible = true
            new_photo_button.visible = true
            camera.imageCapture.capture();
        }
    }

    BackendImageConverter {
        id: imageConverter
        onImageConveted: {
            imageConverter.removeFile(last_image_path)
            imageBase64_ = imageBase64;
            if (xhr.status !== 200) //HTTP 200 OK means place added
                console.log("Registration error ${xhr.status}: ${xhr.statusText}")
            else {
                 let xhr1 = new XMLHttpRequest();
                 xhr1.responseType = 'json'
                 xhr1.open("POST", "http://" + serverIP, true)
                 xhr1.setRequestHeader("Content-type", "application/json")
                 let upload_place_image_request = {}
                 upload_place_image_request["method"] = "upload_marker_image"
                 upload_place_image_request["id"] = response["result"] //result of the response is a marker id
                 console.log("img size: " + imageBase64_.length)
                 upload_place_image_request["image"] = imageBase64_
                 xhr1.onready = function(){
                     console.log("image for marker sent")
                 }
                 xhr1.send(JSON.stringify(upload_place_image_request))
            }
        }
    }
    Button {
        id: ok_button
        visible: false
        text: qsTr("Ок")
        onClicked:
        {
            imageConverter.scheduleToBase64("", last_image_path)
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

