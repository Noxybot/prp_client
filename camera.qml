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
        width: parent.width*0.15 >  50 ? 50 : parent.width*0.15
        height: width
        onClicked: stack.pop();
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
        anchors.left: parent.left
        anchors.leftMargin: parent.width*0.12
        contentItem: Text {
            text: qsTr("\uf0a8")
            width: parent.width
            height: parent.height
            font.pointSize: 100
            minimumPointSize: 10
            fontSizeMode: Text.Fit
            anchors.centerIn: parent
            anchors.fill: parent
            font.family: "Font Awesome 5 Free Solid"
            font.bold: true
            color: "#6fda9c"
        }
        background: Rectangle{
            color: "transparent"
            height: parent.height
            width: height
        }
    }

    Button {
        id: position_button
        width: parent.width*0.15 >  50 ? 50 : parent.width*0.15
        height: width
        contentItem: Text {
            text: qsTr("\uf021")
            width: parent.width
            height: parent.height
            anchors.centerIn: parent
            anchors.fill: parent
            font.pointSize: 100
            minimumPointSize: 10
            fontSizeMode: Text.Fit
            font.family: "Font Awesome 5 Free Solid"
            font.bold: true
            color: "#6fda9c"
        }
        onClicked: camera.position === Camera.BackFace ? camera.position = Camera.FrontFace : camera.position = Camera.BackFace
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
        anchors.right: parent.right
        anchors.rightMargin: parent.width*0.1
        background: Rectangle{
            color: "transparent"
            height: parent.height
            width: height
        }
    }
    RoundButton {
        id: take_photo_button
        width: parent.width*0.3 >  100 ? 100 : parent.width*0.3
        height: width
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
        background: Rectangle{
            width: parent.width
            height: width
            radius: parent.radius
            color: "white"
        }
    }
    Button {
        id: ok_button
        visible: false
        width: parent.width*0.2 >  60 ? 60 : parent.width*0.2
        height: width
        contentItem: Text {
            text: qsTr("\uf058")
            width: parent.width * 0.7
            height: parent.height * 0.7
            anchors.centerIn: parent
            anchors.fill: parent
            font.pointSize: 100
            minimumPointSize: 10
            fontSizeMode: Text.Fit
            font.family: "Font Awesome 5 Free Regular"
            font.bold: true
            color: "#6fda9c"
        }
        anchors.right: parent.right
        anchors.rightMargin: parent.width*0.1
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
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
            add_place_request["from_time"] = from_time//get_milliseconds_from_hours(from_time)
            add_place_request["to_time"] = to_time//get_milliseconds_from_hours(to_time)
            add_place_request["expected_people_number"] = peopleCount
            add_place_request["expected_expenses"] = expenses
            add_place_request["description"] = description
            to_time = to_time.substring(1)
            console.log(to_time)
            let time = new Date().getHours() + 1;
            let minute = new Date().getMinutes();
console.log("time " + time)
            let first = to_time.split(" ");
            console.log("minute " + minute)
            let day2 = first[0];
            console.log("day " + day2)
            let hour2 = first[1].split(":")[0];
            console.log("hour " + hour2)
            let minute2 = first[1].split(":")[1];
            console.log("minute " + minute2)
            let difference=0;
            if(day2 === "Сегодня"){
                difference += (hour2 - time)*3600+(minute2-minute)*60;
            }
            else{
                difference += hour2*3600+minute2*60;
                difference += (24 - time-1)*3600+(60-minute)*60;
            }
            console.log("difference " + difference)
            difference = (difference < 0 ? difference*(-1):difference)
            add_place_request["expire_time"] =  difference;

            var xhr = new XMLHttpRequest();
            xhr.responseType = 'json'
            xhr.open("POST", "http://" + serverIP, false)
            xhr.setRequestHeader("Content-type", "application/json")


            try {
                xhr.send(JSON.stringify(add_place_request));
                create_marker_status = xhr.status;
                create_marker_id = xhr.response["result"] //result of the response is a marker id
                load.visible = false
                console.log("image_path"+last_image_path)
                imageConverter.scheduleToBase64(create_marker_id, last_image_path, "convert marker image")

            } catch(err) {
                console.log("add_place request failed: " + err.message)
            }

            stack.pop()
            stack.pop()
            stack.pop()
        }
        background: Rectangle{
            color: "transparent"
            height: parent.height
            width: height
        }
    }
    Button {
        id: new_photo_button
        visible: false
        width: parent.width*0.2 >  60 ? 60 : parent.width*0.2
        height: width
        contentItem: Text {
            text: qsTr("\uf057")
            width: parent.width * 0.7
            height: parent.height * 0.7
            anchors.centerIn: parent
            anchors.fill: parent
            font.pointSize: 100
            minimumPointSize: 10
            fontSizeMode: Text.Fit
            font.family: "Font Awesome 5 Free Regular"
            font.bold: true
            color: "#6fda9c"
        }
        anchors.left: parent.left
        anchors.leftMargin: parent.width*0.12
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
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
        background: Rectangle{
            color: "transparent"
            height: parent.height
            width: height
        }
    }
}


/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:12;anchors_height:125;anchors_width:133}
D{i:11;anchors_height:149}
}
##^##*/
