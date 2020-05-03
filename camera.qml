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
    property string last_image_path: ""
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
            let previousItem = stack.get(cameraUI.StackView.index - 1);
            previousItem.imageBase64 = imageBase64;
            stack.pop()
        }
    }
    Button {
        id: ok_button
        visible: false
        text: qsTr("Ок")
        onClicked:
        {
            imageConverter.scheduleToBase64("", last_image_path)
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

