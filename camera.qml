import QtQuick 2.5
import QtMultimedia 5.6
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12

Page {
    id: root

    Camera {
            id: camera

            imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash

            exposure {
                exposureCompensation: -1.0
                exposureMode: Camera.ExposurePortrait
            }

            flash.mode: Camera.FlashRedEyeReduction

            imageCapture {
                onImageCaptured: {
                    photoPreview.source = preview  // Show the preview in an Image
                    console.log("Path to image: " + preview)
                }
            }
        }

        VideoOutput {
            source: camera
            anchors.fill: parent
            focus : visible // to receive focus and capture key events when visible
        }

        Image {
            id: photoPreview
        }
        Button
        {
            id: back
            text: qsTr("Назад")
            onClicked: stack.pop();
        }

      Button {
          id: pos
          anchors.top: back.bottom
          text: qsTr("Поменять камеру")
          onClicked: camera.position === Camera.BackFace ? camera.position = Camera.FrontFace : camera.position = Camera.BackFace
      }
      Button {
          anchors.top: pos.bottom
          text: qsTr("Сделать фото")
          onClicked:
          {

              camera.imageCapture.capture();

          }
      }
}
